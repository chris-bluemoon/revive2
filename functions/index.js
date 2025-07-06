const { onCall } = require("firebase-functions/v2/https");
const { initializeApp } = require("firebase-admin/app");
const { getMessaging } = require("firebase-admin/messaging");
const { defineSecret } = require("firebase-functions/params");
const stripeSecret = defineSecret("STRIPE_SECRET");

initializeApp();

exports.createPaymentIntent = onCall(
  {
    secrets: [stripeSecret],
  },
  async (request) => {
    try {
      const stripe = require("stripe")(stripeSecret.value());
      const amount = request.data.amount ?? request.data.data?.amount;

      if (!amount) {
        throw new Error("Amount is required");
      }

      const paymentIntent = await stripe.paymentIntents.create({
        amount: amount * 100,
        currency: "THB",
        payment_method_types: ["promptpay","card"],
      });

      return { clientSecret: paymentIntent.client_secret };
    } catch (error) {
      console.error("Error in createPaymentIntent:", error);
      throw new Error(error.message || "Something went wrong");
    }
  },
);

exports.sendNotification = onCall(async (request) => {

  try {
    const deviceToken = request.data.token;
    const notiTitle = request.data.notiTitle;
    const notiBody = request.data.notiBody;

    if (!deviceToken) {
      throw new Error("Device token is required.");
    }

    if (!notiTitle || !notiBody) {
      throw new Error("Notification title or body is required.");
    }

    const message = {
      token: deviceToken,
      notification: {
        title: notiTitle,
        body: notiBody,
      },
    };
    const response = await getMessaging().send(message);
    console.log("Successfully sent message:", response);
    return { success: true, messageId: response };
  } catch (error) {
    console.error("Error sending message:", error);
    throw new Error("Notification failed to send.");
  }
});