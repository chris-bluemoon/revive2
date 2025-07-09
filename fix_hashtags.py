import firebase_admin
from firebase_admin import credentials, firestore

cred = credentials.Certificate('serviceAccountKey.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

count = 0
for doc in db.collection('item').stream():
    hashtags = doc.get('hashtags')
    if isinstance(hashtags, str):
        hashtags_list = [tag.strip() for tag in hashtags.split(',') if tag.strip()]
        doc.reference.update({'hashtags': hashtags_list})
        print(f"Fixed hashtags for doc {doc.id}: {hashtags_list}")
        count += 1

print(f"Fixed {count} documents with string hashtags.")