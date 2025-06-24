const admin = require('firebase-admin');
const csv = require('csvtojson');
const fs = require('fs');

// Replace with your Firebase service account key file
const serviceAccount = require('/Users/yx/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

const csvFilePath = process.argv[2];

csv()
  .fromFile(csvFilePath)
  .then(async (jsonArray) => {
    const batch = db.batch();
    jsonArray.forEach((item) => {
      // Convert 'hashtags' field to array if it exists and is not empty
      if (item.buyPrice) item.buyPrice = parseFloat(item.buyPrice);
      if (item.rrp) item.rrp = parseFloat(item.rrp);
      if (item.rentPriceWeekly) item.rentPriceWeekly = parseFloat(item.rentPriceWeekly);
      if (item.rentPriceDaily) item.rentPriceDaily = parseFloat(item.rentPriceDaily);
      if (item.rentPriceMonthly) item.rentPriceMonthly = parseFloat(item.rentPriceMonthly);
      if (item.minDays) item.minDays = parseInt(item.minDays, 10);
      if (item.hashtags && typeof item.hashtags === 'string') {
        item.hashtags = item.hashtags.split('|').filter(Boolean);
      }
      if (item.imageId && typeof item.imageId === 'string') {
        item.imageId = item.imageId.split('|').filter(Boolean);
      }

      // Remove undefined or empty fields
      Object.keys(item).forEach((key) => {
        if (item[key] === undefined || item[key] === '') {
          delete item[key];
        }
      });

      const docRef = db.collection('item').doc();
      batch.set(docRef, item);
    });
    await batch.commit().then(() => {
      console.log('Batch committed!');
    });
    console.log('Import complete');
    process.exit(0);
  })
  .catch((err) => {
    console.error('Error:', err);
    process.exit(1);
  });
