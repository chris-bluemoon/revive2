import os
from PIL import Image
import io

# Set the ownerId and home directory
owner_id = '59b63bef-1ad9-4208-9fca-1e18b6c391a0'
home_dir = os.path.expanduser('~')
owner_dir = os.path.join(home_dir, owner_id)

def compress_jpg_to_target_size(img, out_path, target_kb=100, min_quality=20):
    quality = 95
    while quality >= min_quality:
        buffer = io.BytesIO()
        img.save(buffer, format='JPEG', quality=quality, optimize=True)
        size_kb = buffer.tell() / 1024
        if size_kb <= target_kb:
            with open(out_path, 'wb') as f:
                f.write(buffer.getvalue())
            return True
        quality -= 5
    # Save at lowest quality if still too big
    img.save(out_path, 'JPEG', quality=min_quality, optimize=True)
    return False

# Walk through all subdirectories (brand+item directories)
for root, dirs, files in os.walk(owner_dir):
    # Only process immediate subdirectories of owner_dir
    if root == owner_dir:
        for brand_item in dirs:
            brand_item_dir = os.path.join(owner_dir, brand_item)
            # Get all image files (jpg, jpeg, png)
            image_files = [f for f in os.listdir(brand_item_dir) if f.lower().endswith(('.jpg', '.jpeg', '.png'))]
            image_files.sort()  # Sort for consistent renaming
            for idx, old_name in enumerate(image_files, 1):
                ext = os.path.splitext(old_name)[1].lower()
                new_name = f"{idx}.jpg"
                old_path = os.path.join(brand_item_dir, old_name)
                new_path = os.path.join(brand_item_dir, new_name)
                # Open image and convert to RGB
                img = Image.open(old_path).convert('RGB')
                compress_jpg_to_target_size(img, new_path, target_kb=100)
                if ext != '.jpg':
                    os.remove(old_path)
                    print(f"Converted, compressed, and renamed {old_path} -> {new_path}")
                else:
                    if old_path != new_path:
                        os.remove(old_path)
                        print(f"Renamed and compressed {old_path} -> {new_path}")
                    else:
                        print(f"Compressed {old_path}")

# Walk through all subdirectories (itemId directories)
for root, dirs, files in os.walk(owner_dir):
    # Only process immediate subdirectories of owner_dir
    if root == owner_dir:
        for item_id in dirs:
            item_dir = os.path.join(owner_dir, item_id)
            for jpg_name in ['1.jpg', '2.jpg']:
                jpg_path = os.path.join(item_dir, jpg_name)
                # Create a 500x1000px blank red jpg file
                if not os.path.exists(jpg_path):
                    img = Image.new('RGB', (500, 1000), color='red')
                    compress_jpg_to_target_size(img, jpg_path, target_kb=100)
                    print(f"Created and compressed jpg: {jpg_path}")
