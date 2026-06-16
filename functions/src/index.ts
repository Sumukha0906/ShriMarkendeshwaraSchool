import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

admin.initializeApp();

const db        = admin.firestore();
const messaging = admin.messaging();

// ─── Helpers ──────────────────────────────────────────────────────────────────

/** Split an array into chunks of size n */
function chunk<T>(arr: T[], n: number): T[][] {
  const out: T[][] = [];
  for (let i = 0; i < arr.length; i += n) out.push(arr.slice(i, i + n));
  return out;
}

/** Remove stale FCM tokens from a user doc */
async function removeStaleTokens(uid: string, stale: string[]) {
  if (stale.length === 0) return;
  await db.collection("users").doc(uid).update({
    fcmTokens: admin.firestore.FieldValue.arrayRemove(...stale),
  });
}

// ─── Per-user notification trigger ────────────────────────────────────────────
// Triggers when any notification doc is created for a specific user.
// maxInstances=500 so the 9AM attendance spike (10k notifications across
// ~30-min window) is handled without queue overflow.
export const onNotificationCreated = functions
  .runWith({ maxInstances: 500, timeoutSeconds: 30, memory: "256MB" })
  .firestore.document("notifications/{uid}/items/{docId}")
  .onCreate(async (snap, context) => {
    const uid  = context.params.uid as string;
    const data = snap.data();
    if (!data) return;

    const title = (data.title as string) ?? "EduConnect";
    const body  = (data.body  as string) ?? "";
    const type  = (data.type  as string) ?? "";

    const userDoc = await db.collection("users").doc(uid).get();
    if (!userDoc.exists) {
      functions.logger.warn(`User ${uid} not found — skipping FCM`);
      return;
    }

    const fcmTokens = (userDoc.data()?.fcmTokens as string[] | undefined) ?? [];
    if (fcmTokens.length === 0) return;

    const basePayload = {
      notification: { title, body },
      data: {
        type,
        docId:     snap.id,
        uid,
        studentId: (data.studentId as string) ?? "",
        classId:   (data.classId   as string) ?? "",
        status:    (data.status    as string) ?? "",
      },
      android: {
        notification: { channelId: "shalalink_default", priority: "high" as const, sound: "default" },
        priority: "high" as const,
      },
      apns: { payload: { aps: { sound: "default", badge: 1 } } },
    };

    // FCM multicast accepts max 500 tokens per call — chunk to be safe
    const staleTokens: string[] = [];
    for (const batch of chunk(fcmTokens, 500)) {
      const resp = await messaging.sendEachForMulticast({ ...basePayload, tokens: batch });
      resp.responses.forEach((r, i) => {
        if (!r.success && r.error) {
          const c = r.error.code;
          if (c === "messaging/registration-token-not-registered" ||
              c === "messaging/invalid-registration-token") {
            staleTokens.push(batch[i]);
          }
        }
      });
      functions.logger.info(`FCM batch sent to ${uid}: ${resp.successCount} ok, ${resp.failureCount} failed`);
    }

    await removeStaleTokens(uid, staleTokens);
  });

// ─── Batch attendance notification (HTTP) ─────────────────────────────────────
// Call this from the app/server instead of creating 30+ individual notification
// docs when marking a full class. Accepts a list of {uid, title, body, data}
// and sends FCM in one function invocation using multicast batches.
//
// POST /sendBatchAttendanceNotifications
// Body: { schoolId: string, notifications: Array<{ uid, title, body, studentId, classId, status }> }
// Auth: requires a valid Firebase ID token in Authorization header.
export const sendBatchAttendanceNotifications = functions
  .runWith({ maxInstances: 50, timeoutSeconds: 120, memory: "512MB" })
  .https.onCall(async (data, context) => {
    // Must be authenticated
    if (!context.auth) throw new functions.https.HttpsError("unauthenticated", "Login required.");

    const notifications: Array<{
      uid: string; title: string; body: string;
      studentId?: string; classId?: string; status?: string;
    }> = data.notifications ?? [];
    const schoolId: string = data.schoolId ?? "";

    if (notifications.length === 0) return { sent: 0 };
    if (notifications.length > 5000) {
      throw new functions.https.HttpsError("invalid-argument", "Max 5000 notifications per batch.");
    }

    // Fetch FCM tokens for all UIDs in parallel (batched to avoid too many reads)
    const uidChunks = chunk([...new Set(notifications.map((n) => n.uid))], 30);
    const tokenMap: Record<string, string[]> = {};

    await Promise.all(
      uidChunks.map(async (uids) => {
        const snaps = await Promise.all(uids.map((uid) => db.collection("users").doc(uid).get()));
        snaps.forEach((s, i) => {
          tokenMap[uids[i]] = (s.data()?.fcmTokens as string[] | undefined) ?? [];
        });
      })
    );

    // Group: token → notification payload (one token can appear for multiple students)
    let totalSent = 0;
    const staleByUid: Record<string, string[]> = {};

    // Build token→message map and send in multicast batches of 500
    const messages: admin.messaging.Message[] = [];
    for (const notif of notifications) {
      const tokens = tokenMap[notif.uid] ?? [];
      for (const token of tokens) {
        messages.push({
          token,
          notification: { title: notif.title, body: notif.body },
          data: {
            type:      "attendance",
            uid:       notif.uid,
            studentId: notif.studentId ?? "",
            classId:   notif.classId   ?? "",
            status:    notif.status    ?? "",
            schoolId,
          },
          android: {
            notification: { channelId: "shalalink_default", priority: "high" as const, sound: "default" },
            priority: "high" as const,
          },
          apns: { payload: { aps: { sound: "default", badge: 1 } } },
        });
      }
    }

    // sendEach accepts up to 500 messages per call
    for (const batch of chunk(messages, 500)) {
      const resp = await messaging.sendEach(batch);
      totalSent += resp.successCount;
      resp.responses.forEach((r, i) => {
        if (!r.success && r.error) {
          const code = r.error.code;
          if (code === "messaging/registration-token-not-registered" ||
              code === "messaging/invalid-registration-token") {
            // Find which uid owns this token to clean up
            const token = batch[i].token as string;
            for (const [uid, tokens] of Object.entries(tokenMap)) {
              if (tokens.includes(token)) {
                staleByUid[uid] = [...(staleByUid[uid] ?? []), token];
              }
            }
          }
        }
      });
      functions.logger.info(`Batch FCM: ${resp.successCount} ok, ${resp.failureCount} failed`);
    }

    // Clean up stale tokens
    await Promise.all(
      Object.entries(staleByUid).map(([uid, stale]) => removeStaleTokens(uid, stale))
    );

    functions.logger.info(`sendBatchAttendanceNotifications: ${totalSent} sent for school ${schoolId}`);
    return { sent: totalSent };
  });
