import firebase_admin
from firebase_admin import credentials, firestore
import pandas as pd
import uuid

# Initialize Firebase
cred = credentials.Certificate('serviceAccountKey.json')  # Path to your service account key
firebase_admin.initialize_app(cred)
db = firestore.client()

# Load CSV
df = pd.read_csv('item.csv')

# Fill NaN with empty string for Firestore compatibility
df = df.fillna('')

for _, row in df.iterrows():
    doc_id = str(row['id'])
    # If id is missing or empty, generate a new unique id
    if not doc_id or doc_id == 'nan':
        doc_id = str(uuid.uuid4())
        print(f'Generated new id: {doc_id}')
    data = row.to_dict()
    data['id'] = doc_id  # Ensure the id is included in the document data
    # Ensure 'brand' is always uppercase
    if 'brand' in data and isinstance(data['brand'], str):
        data['brand'] = data['brand'].upper()
    # Ensure 'size' is uploaded as a string
    if 'size' in data:
        data['size'] = str(data['size'])
    # Convert 'hashtags' from comma-separated string to list
    if 'hashtags' in data and isinstance(data['hashtags'], str):
        data['hashtags'] = [tag.strip() for tag in data['hashtags'].split(',') if tag.strip()]
    # Ensure 'imageId' is uploaded as a list (even if empty or single string)
    if 'imageId' in data:
        if isinstance(data['imageId'], str):
            if data['imageId'].strip() == '':
                data['imageId'] = []
            else:
                data['imageId'] = [img.strip() for img in data['imageId'].split(',') if img.strip()]
        elif not isinstance(data['imageId'], list):
            data['imageId'] = []
    db.collection('item').document(doc_id).set(data)
    print(f'Uploaded item with id: {doc_id}')

print('Upload complete.')
