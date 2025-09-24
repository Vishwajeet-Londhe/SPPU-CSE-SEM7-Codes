import os
import shutil

# Simulate deleted files by putting them in this folder
deleted_folder = "DeletedFilesSimulation"

# Folder to store recovered files
recovered_folder = "RecoveredFiles"
os.makedirs(recovered_folder, exist_ok=True)

# Scan deleted folder for "deleted" files (simulated with .deleted extension)
for root, dirs, files in os.walk(deleted_folder):
    for file in files:
        if file.endswith(".deleted"):
            old_path = os.path.join(root, file)
            new_path = os.path.join(recovered_folder, file.replace(".deleted", ""))
            shutil.copy2(old_path, new_path)
            print(f"Recovered: {file} -> {new_path}")

print("Recovery simulation complete.")