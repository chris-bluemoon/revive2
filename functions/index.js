const functions = require("firebase-functions");
const admin = require("firebase-admin");
const stripe = require("stripe")(functions.config().stripe.secret);

admin.initializeApp();

exports.createPaymentIntent = functions.https.onCall(async (data, context) => {
  try {
    const amount = data.amount ?? data.data?.amount;

    if (!amount) {
      throw new functions.https.HttpsError("invalid-argument",
          "Amount is required");
    }

    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount * 100,
      currency: "THB",
    });

    return {clientSecret: paymentIntent.client_secret};
  } catch (error) {
    console.error("Error in createPaymentIntent:", error);
    throw new functions.https.HttpsError("Internal", error.message ||
      "Something went wrong");
  }
});
