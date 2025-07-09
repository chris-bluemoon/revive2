import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase
cred = credentials.Certificate('serviceAccountKey.json')  # Path to your service account key
firebase_admin.initialize_app(cred)
db = firestore.client()

TARGET_TIME = '17:18:28'

# Loop through all documents and delete those with dateAdded time matching TARGET_TIME
count = 0
for doc in db.collection('item').stream():
    date_added = doc.get('dateAdded')
    # Check if date_added is a string and ends with the target time
    if isinstance(date_added, str) and date_added.strip().endswith(TARGET_TIME):
        doc.reference.delete()
        print(f"Deleted document with id: {doc.id} (dateAdded: {date_added})")
        count += 1

print(f"Deleted {count} documents where dateAdded time is '{TARGET_TIME}'")
