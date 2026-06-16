"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onNotificationCreated = void 0;
const admin = require("firebase-admin");
const functions = require("firebase-functions");
admin.initializeApp();
const db = admin.firestore();
const messaging = admin.messaging();
// ─── Send FCM push when a notification doc is created ─────────────────────
// Triggers on: notifications/{uid}/items/{docId}
exports.onNotificationCreated = functions.firestore
    .document("notifications/{uid}/items/{docId}")
    .onCreate(async (snap, context) => {
    var _a, _b, _c, _d, _e, _f, _g, _h;
    const uid = context.params.uid;
    const data = snap.data();
    if (!data)
        return;
    const title = (_a = data.title) !== null && _a !== void 0 ? _a : "EduConnect";
    const body = (_b = data.body) !== null && _b !== void 0 ? _b : "";
    const type = (_c = data.type) !== null && _c !== void 0 ? _c : "";
    // Fetch FCM tokens for this user
    const userDoc = await db.collection("users").doc(uid).get();
    if (!userDoc.exists) {
        functions.logger.warn(`User ${uid} not found — skipping FCM`);
        return;
    }
    const fcmTokens = (_e = (_d = userDoc.data()) === null || _d === void 0 ? void 0 : _d.fcmTokens) !== null && _e !== void 0 ? _e : [];
    if (fcmTokens.length === 0) {
        functions.logger.info(`No FCM tokens for user ${uid}`);
        return;
    }
    // Build the FCM message
    const message = {
        tokens: fcmTokens,
        notification: { title, body },
        data: {
            type,
            docId: snap.id,
            uid,
            studentId: (_f = data.studentId) !== null && _f !== void 0 ? _f : "",
            classId: (_g = data.classId) !== null && _g !== void 0 ? _g : "",
            status: (_h = data.status) !== null && _h !== void 0 ? _h : "",
        },
        android: {
            notification: {
                channelId: "educonnect_default",
                priority: "high",
                sound: "default",
            },
            priority: "high",
        },
        apns: {
            payload: {
                aps: {
                    sound: "default",
                    badge: 1,
                },
            },
        },
    };
    try {
        const response = await messaging.sendEachForMulticast(message);
        functions.logger.info(`FCM sent to ${uid}: ${response.successCount} ok, ${response.failureCount} failed`);
        // Remove stale tokens that returned a registration error
        const staleTokens = [];
        response.responses.forEach((resp, idx) => {
            if (!resp.success && resp.error) {
                const code = resp.error.code;
                if (code === "messaging/registration-token-not-registered" ||
                    code === "messaging/invalid-registration-token") {
                    staleTokens.push(fcmTokens[idx]);
                }
            }
        });
        if (staleTokens.length > 0) {
            await db.collection("users").doc(uid).update({
                fcmTokens: admin.firestore.FieldValue.arrayRemove(...staleTokens),
            });
            functions.logger.info(`Removed ${staleTokens.length} stale token(s) for ${uid}`);
        }
    }
    catch (err) {
        functions.logger.error(`FCM sendEachForMulticast failed for ${uid}`, err);
    }
});
//# sourceMappingURL=index.js.map