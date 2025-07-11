import os

# Set the ownerId and home directory
owner_id = '59b63bef-1ad9-4208-9fca-1e18b6c391a0'
home_dir = os.path.expanduser('~')
owner_dir = os.path.join(home_dir, owner_id)

# Walk through all subdirectories (itemId directories)
for root, dirs, files in os.walk(owner_dir):
    # Only process immediate subdirectories of owner_dir
    if root == owner_dir:
        for item_id in dirs:
            item_dir = os.path.join(owner_dir, item_id)
            for file in os.listdir(item_dir):
                file_path = os.path.join(item_dir, file)
                if os.path.isfile(file_path):
                    os.remove(file_path)
                    print(f"Removed file: {file_path}")
