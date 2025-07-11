import { onCall } from "firebase-functions/v2/https";
import { initializeApp } from "firebase-admin/app";
import { getMessaging } from "firebase-admin/messaging";
import { defineSecret } from "firebase-functions/params";
import stripePackage from "stripe";

const stripeSecret = defineSecret("STRIPE_SECRET");

initializeApp();

export const createPaymentIntent = onCall(
  {
    secrets: [stripeSecret],
  },
  async (request) => {
    try {
      const stripe = stripePackage(stripeSecret.value());
      const amount = request.data.amount ?? request.data.data?.amount;

      if (!amount) {
        throw new Error("Amount is required");
      }

      const paymentIntent = await stripe.paymentIntents.create({
        amount: amount * 100,
        currency: "THB",
        payment_method_types: ["card"],
      });

      return { clientSecret: paymentIntent.client_secret };
    } catch (error) {
      console.error("Error in createPaymentIntent:", error);
      throw new Error(error.message || "Something went wrong");
    }
  },
);

export const sendNotification = onCall(async (request) => {
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