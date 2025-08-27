#!/bin/bash

# =========================
# CONFIG
# =========================
# Path to your repo in shared storage
REPO_PATH="$HOME/storage/shared/divinetruthascension"
HOT_RELOAD_PORT=8080
NETLIFY_FOLDERS=("dist" "build" "public")

# =========================
# 0. Ensure required packages
# =========================
pkg update -y
pkg install python nodejs git -y
pip install --upgrade pip
pip install livereload

# =========================
# 1. Go to repo
# =========================
cd "$REPO_PATH" || { echo "Repo not found!"; exit 1; }

# =========================
# 2. Remove broken/empty submodules
# =========================
echo "Removing broken/empty submodules..."
git submodule status 2>/dev/null | while read -r line; do
    submodule_path=$(echo $line | awk '{print $2}')
    if [ ! -d "$submodule_path" ] || [ -z "$(ls -A "$submodule_path" 2>/dev/null)" ]; then
        echo "Removing submodule: $submodule_path"
        git submodule deinit -f "$submodule_path" 2>/dev/null
        git rm -f "$submodule_path" 2>/dev/null
        rm -rf .git/modules/"$submodule_path" 2>/dev/null
    fi
done

# Clean empty entries in .gitmodules
if [ -f ".gitmodules" ]; then
    grep -v '\[submodule' .gitmodules > .gitmodules.tmp
    mv .gitmodules.tmp .gitmodules
    git add .gitmodules
fi

# =========================
# 3. Commit and push changes
# =========================
git commit -m "Clean broken submodules" 2>/dev/null || echo "Nothing to commit"
git push origin main

# =========================
# 4. Build Node.js project if exists
# =========================
BUILD_FOLDER="."
for folder in "${NETLIFY_FOLDERS[@]}"; do
    if [ -d "$REPO_PATH/$folder" ]; then
        BUILD_FOLDER="$folder"
        break
    fi
done

if [ "$BUILD_FOLDER" = "." ] && [ -f "$REPO_PATH/package.json" ]; then
    echo "Node.js project detected: running npm install & build..."
    npm install
    npm run build
    for folder in "${NETLIFY_FOLDERS[@]}"; do
        if [ -d "$REPO_PATH/$folder" ]; then
            BUILD_FOLDER="$folder"
            break
        fi
    done
fi

echo "Serving folder: $BUILD_FOLDER"

# =========================
# 5. Start hot-reload server
# =========================
cd "$REPO_PATH/$BUILD_FOLDER"
echo "Launching hot-reload preview at http://127.0.0.1:$HOT_RELOAD_PORT..."
termux-open-url "http://127.0.0.1:$HOT_RELOAD_PORT"

python3 - <<EOF
from livereload import Server
import os

folder = os.getcwd()
server = Server()
server.watch(folder)
server.serve(root=folder, port=$HOT_RELOAD_PORT)
EOF
