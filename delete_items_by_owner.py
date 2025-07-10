import os
import firebase_admin
from firebase_admin import credentials, firestore, storage
from google.api_core.exceptions import NotFound

# Get the path to serviceAccountKey.json from the user's home directory
service_account_path = os.path.join(os.path.expanduser('~'), 'serviceAccountKey.json')
cred = credentials.Certificate(service_account_path)
firebase_admin.initialize_app(cred, {
    'storageBucket': 'revive-ff08d.firebasestorage.app'  # Use your actual bucket name
})

db = firestore.client()

TARGET_TIME = '17:18:28'

# Loop through all documents and delete those with dateAdded time matching TARGET_TIME
count = 0
bucket = storage.bucket()
batch_size = 100
last_doc = None
while True:
    query = db.collection('item').order_by('dateAdded').limit(batch_size)
    if last_doc:
        query = query.start_after(last_doc)
    docs = list(query.stream())
    if not docs:
        break
    for doc in docs:
        date_added = doc.get('dateAdded')
        # Check if date_added is a string and ends with the target time
        if isinstance(date_added, str) and date_added.strip().endswith(TARGET_TIME):
            doc_dict = doc.to_dict()
            owner_id = doc_dict.get('ownerId', '59b63bef-1ad9-4208-9fca-1e18b6c391a0')
            item_id = doc.id
            # Remove all images referenced in imageId field
            image_ids = doc_dict.get('imageId', [])
            for image_path in image_ids:
                blob = bucket.blob(image_path)
                try:
                    blob.delete()
                    print(f"Deleted storage image: {image_path}")
                except NotFound:
                    print(f"Image not found in storage (skipped): {image_path}")
            # Also remove up to 4 images for .jpg, .jpeg, .png extensions
            for idx in range(1, 5):
                for ext in ['jpg', 'jpeg', 'png']:
                    storage_path = f'items/{owner_id}/{item_id}/{idx}.{ext}'
                    blob = bucket.blob(storage_path)
                    try:
                        blob.delete()
                        print(f"Deleted storage image: {storage_path}")
                    except NotFound:
                        print(f"Image not found in storage (skipped): {storage_path}")
            doc.reference.delete()
            print(f"Deleted document with id: {doc.id} (dateAdded: {date_added})")
            count += 1
        last_doc = doc

print(f"Deleted {count} documents where dateAdded time is '{TARGET_TIME}'")
