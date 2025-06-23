/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
const functions = require("firebase-functions");
// const stripe = require("stripe")(functions.config().stripe.secret);

exports.createPaymentIntent = functions
  // .runWith({timeoutSeconds: 60, memory: "256MB"})
  // .region("us-central1")
  .https
  .onCall(async (data, context) => {
    const stripe = require("stripe")(functions.config().stripe.secret);
    const amount = data.amount;

    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency: "THB",
    });

    return { clientSecret: paymentIntent.client_secret };
  });
