import os
import shutil
import random
import glob
import firebase_admin
from firebase_admin import credentials, firestore, storage
import pandas as pd
import uuid

# Get the path to serviceAccountKey.json from the user's home directory
service_account_path = os.path.join(os.path.expanduser('~'), 'serviceAccountKey.json')
cred = credentials.Certificate(service_account_path)
firebase_admin.initialize_app(cred, {
    'storageBucket': 'revive-ff08d.firebasestorage.app'  # Replace with your actual bucket name
})

db = firestore.client()

# Load CSV
df = pd.read_csv('item.csv')

# Fill NaN with empty string for Firestore compatibility
df = df.fillna('')

# Instead of sample_jpgs, select random jpgs from $HOME/items/<dir>/filename
HOME_ITEMS_DIR = os.path.join(os.path.expanduser('~'), 'items')

def get_all_jpgs_from_home_items():
    jpg_files = []
    for root, dirs, files in os.walk(HOME_ITEMS_DIR):
        for file in files:
            if file.lower().endswith('.jpg'):
                jpg_files.append(os.path.join(root, file))
    return jpg_files

def ensure_owner_dir_in_bucket(bucket, owner_id):
    # Check if any blob exists with the prefix 'items/{owner_id}/'
    prefix = f'items/{owner_id}/'
    blobs = list(bucket.list_blobs(prefix=prefix, max_results=1))
    if not blobs:
        # Create a placeholder blob to ensure the directory exists
        placeholder_blob = bucket.blob(f'{prefix}.keep')
        placeholder_blob.upload_from_string('')
        print(f"Created placeholder for owner directory in bucket: {prefix}")

def create_local_item_dir_and_update_firestore(owner_id, item_id, brand, name):
    home_dir = os.path.expanduser('~')
    owner_dir = os.path.join(home_dir, owner_id)
    item_dir = os.path.join(owner_dir, item_id)
    os.makedirs(item_dir, exist_ok=True)
    # Use $HOME/items/<brand><name> as the source directory for jpgs
    brand_name_dir = os.path.join(HOME_ITEMS_DIR, f"{brand} {name}")
    jpg_files = []
    if os.path.isdir(brand_name_dir):
        jpg_files = [os.path.join(brand_name_dir, f) for f in os.listdir(brand_name_dir) if f.lower().endswith('.jpg')]
    image_paths = []
    num_images = min(4, len(jpg_files))
    # Copy up to 4 images
    for idx in range(1, num_images + 1):
        src = jpg_files[idx - 1]
        dst = os.path.join(item_dir, f'{idx}.jpg')
        shutil.copy(src, dst)
        firestore_path = f'items/{owner_id}/{item_id}/{idx}.jpg'
        image_paths.append(firestore_path)
    # If fewer than 4 images, create empty jpgs for the rest
    for idx in range(num_images + 1, 5):
        jpg_path = os.path.join(item_dir, f'{idx}.jpg')
        open(jpg_path, 'wb').close()
        firestore_path = f'items/{owner_id}/{item_id}/{idx}.jpg'
        image_paths.append(firestore_path)
    # Update the imageId field in Firestore for this item
    item_ref = db.collection('item').document(item_id)
    item_ref.update({'imageId': image_paths})
    print(f"Updated Firestore item {item_id} with imageId: {image_paths}")

    # Upload the images to Firebase Storage
    bucket = storage.bucket()
    ensure_owner_dir_in_bucket(bucket, owner_id)
    for idx, firestore_path in enumerate(image_paths, 1):
        local_path = os.path.join(item_dir, f'{idx}.jpg')
        if os.path.exists(local_path) and os.path.getsize(local_path) > 0:
            blob = bucket.blob(firestore_path)
            blob.upload_from_filename(local_path)
            print(f"Uploaded {local_path} to storage at {firestore_path}")
        else:
            print(f"Skipped upload for {local_path} (file does not exist or is empty)")

    return item_dir

def upload_images_and_update_firestore(owner_id, item_id, brand, name):
    # Use exact brand and name with spaces for directory matching
    brand_name_dir = os.path.join(HOME_ITEMS_DIR, f"{brand} {name}".strip())
    jpg_files = []
    webp_files = []
    avif_files = []
    png_files = []
    if os.path.isdir(brand_name_dir):
        jpg_files = [os.path.join(brand_name_dir, f) for f in os.listdir(brand_name_dir) if f.lower().endswith('.jpg')]
        webp_files = [os.path.join(brand_name_dir, f) for f in os.listdir(brand_name_dir) if f.lower().endswith('.webp')]
        avif_files = [os.path.join(brand_name_dir, f) for f in os.listdir(brand_name_dir) if f.lower().endswith('.avif')]
        png_files = [os.path.join(brand_name_dir, f) for f in os.listdir(brand_name_dir) if f.lower().endswith('.png')]
    else:
        print(f"WARNING: Directory not found for images: {brand_name_dir}")
    image_paths = []
    bucket = storage.bucket()
    ensure_owner_dir_in_bucket(bucket, owner_id)
    # Upload up to 4 images directly from source (jpg first, then webp/avif/png converted to jpg)
    all_images = jpg_files + webp_files + avif_files + png_files
    from PIL import Image
    import io
    def process_and_upload(src, firestore_path):
        # Open image
        with Image.open(src).convert('RGB') as img:
            # Enforce 3:4 aspect ratio (crop center)
            w, h = img.size
            target_ratio = 3/4
            current_ratio = w/h
            if abs(current_ratio - target_ratio) > 0.01:
                # Crop to center
                if current_ratio > target_ratio:
                    # Too wide
                    new_w = int(h * target_ratio)
                    left = (w - new_w) // 2
                    img = img.crop((left, 0, left + new_w, h))
                else:
                    # Too tall
                    new_h = int(w / target_ratio)
                    top = (h - new_h) // 2
                    img = img.crop((0, top, w, top + new_h))
            # Resize to max 1000px height (preserve 3:4)
            max_height = 1000
            if img.height > max_height:
                img = img.resize((int(max_height * 3 / 4), max_height), Image.LANCZOS)
            # Compress to <=100kB
            buf = io.BytesIO()
            quality = 90
            while True:
                buf.seek(0)
                buf.truncate()
                img.save(buf, format='JPEG', quality=quality, optimize=True)
                size_kb = buf.tell() / 1024
                if size_kb <= 100 or quality <= 60:
                    break
                quality -= 5
            buf.seek(0)
            blob = bucket.blob(firestore_path)
            blob.upload_from_file(buf, content_type='image/jpeg')
            print(f"Processed and uploaded {src} as jpg to storage at {firestore_path} (size: {size_kb:.1f} KB, quality: {quality})")
    for idx, src in enumerate(all_images[:4], 1):
        firestore_path = f'items/{owner_id}/{item_id}/{idx}.jpg'
        if src.lower().endswith(('.jpg', '.webp', '.avif', '.png')):
            process_and_upload(src, firestore_path)
            image_paths.append(firestore_path)
    # Only update Firestore if images were found and uploaded
    if image_paths:
        item_ref = db.collection('item').document(item_id)
        item_ref.update({'imageId': image_paths})
        print(f"Updated Firestore item {item_id} with imageId: {image_paths}")
    else:
        print(f"WARNING: No images found for {brand} {name} (item {item_id}), Firestore not updated.")
        with open('upload_error.txt', 'a') as errfile:
            errfile.write(f"{brand} {name}\n")
    return image_paths

# ...wherever you upload an item, call create_local_item_dir_and_update_firestore(owner_id, item_id)

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
    # Check if there are images before uploading to Firestore
    brand = data.get('brand', '')
    name = data.get('name', '')
    brand_name_dir = os.path.join(HOME_ITEMS_DIR, f"{brand} {name}".strip())
    has_images = False
    if os.path.isdir(brand_name_dir):
        jpg_files = [f for f in os.listdir(brand_name_dir) if f.lower().endswith('.jpg')]
        webp_files = [f for f in os.listdir(brand_name_dir) if f.lower().endswith('.webp')]
        if jpg_files or webp_files:
            has_images = True
    if has_images:
        db.collection('item').document(doc_id).set(data)
        print(f'Uploaded item with id: {doc_id}')
        # Upload images directly from source and update Firestore
        upload_images_and_update_firestore(
            data.get('ownerId', '59b63bef-1ad9-4208-9fca-1e18b6c391a0'),
            doc_id,
            brand,
            name
        )
    else:
        print(f"SKIPPED: No images found for {brand} {name} (item {doc_id}), item not uploaded to Firestore.")
        with open('upload_error.txt', 'a') as errfile:
            errfile.write(f"{brand} {name}\n")

print('Upload complete.')
