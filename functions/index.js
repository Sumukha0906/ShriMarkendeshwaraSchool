const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");

admin.initializeApp();
setGlobalOptions({ region: "asia-south1" });

exports.sendPushNotification = onDocumentCreated("notifications/{parentUid}/items/{notificationId}", async (event) => {
  const snap = event.data;
  if (!snap) return;

  const data = snap.data();
  const targetParentUid = event.params.parentUid;

  // 1. Fetch parent doc
  const userDoc = await admin.firestore().collection("users").doc(targetParentUid).get();
  
  // 2. Access the ARRAY 'fcmTokens' as shown in your database screenshot
  const tokens = userDoc.data()?.fcmTokens; 

  if (!tokens || !Array.isArray(tokens) || tokens.length === 0) {
    console.log(`No tokens found for parent ${targetParentUid}`);
    return;
  }

  // 3. Filter out any empty strings just in case
  const validTokens = tokens.filter(t => t && t.length > 0);

  const payload = {
    notification: {
      title: data.title || "EduConnect Update",
      body: data.body || "You have a new notification.",
    }
  };

  try {
    // 4. Send to all devices in the array
    const response = await admin.messaging().sendEachForMulticast({
      notification: payload.notification,
      tokens: validTokens,
    });
    
    console.log(`Successfully sent to ${response.successCount} devices for parent ${targetParentUid}`);
  } catch (error) {
    console.error(`Error sending to parent ${targetParentUid}:`, error);
  }
});