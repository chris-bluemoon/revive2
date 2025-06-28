const {onCall} = require("firebase-functions/v2/https");
const {initializeApp} = require("firebase-admin/app");
const {defineSecret} = require("firebase-functions/params");
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
        });

        return {clientSecret: paymentIntent.client_secret};
      } catch (error) {
        console.error("Error in createPaymentIntent:", error);
        throw new Error(error.message || "Something went wrong");
      }
    },
);
