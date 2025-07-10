import os
from PIL import Image

# Set the ownerId and home directory
owner_id = '59b63bef-1ad9-4208-9fca-1e18b6c391a0'
home_dir = os.path.expanduser('~')
owner_dir = os.path.join(home_dir, owner_id)

# Walk through all subdirectories (brand+item directories)
for root, dirs, files in os.walk(owner_dir):
    # Only process immediate subdirectories of owner_dir
    if root == owner_dir:
        for brand_item in dirs:
            brand_item_dir = os.path.join(owner_dir, brand_item)
            # Get all image files (jpg, jpeg, png)
            image_files = [f for f in os.listdir(brand_item_dir) if f.lower().endswith(('.jpg', '.jpeg', '.png'))]
            image_files.sort()  # Sort for consistent renaming
            # Rename all to 1.jpg, 2.jpg, ... removing any original name
            for idx, old_name in enumerate(image_files, 1):
                ext = os.path.splitext(old_name)[1].lower()
                new_name = f"{idx}.jpg"
                old_path = os.path.join(brand_item_dir, old_name)
                new_path = os.path.join(brand_item_dir, new_name)
                # Convert to jpg if not already
                if ext != '.jpg':
                    img = Image.open(old_path).convert('RGB')
                    img.save(new_path, 'JPEG')
                    os.remove(old_path)
                    print(f"Converted and renamed {old_path} -> {new_name}")
                else:
                    os.rename(old_path, new_path)
                    print(f"Renamed {old_path} -> {new_name}")

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
                    img.save(jpg_path, 'JPEG')
                    print(f"Created jpg: {jpg_path}")
