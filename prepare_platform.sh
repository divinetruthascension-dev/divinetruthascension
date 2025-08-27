#!/bin/bash

# =========================
# CONFIG
# =========================
MAIN_REPO="$HOME/storage/shared/divinetruthascension"
SOURCE_REPO="$HOME/storage/shared/DivineTruthAscension"
ZIP_FILE="$MAIN_REPO/divinetruthascension-v2.zip"
HTTP_PORT=8080

# =========================
# 0. Go to main repo
# =========================
cd "$MAIN_REPO" || { echo "Main repo not found!"; exit 1; }

# =========================
# 1. Remove broken/empty submodules
# =========================
echo "Cleaning broken/empty submodules..."
git submodule status 2>/dev/null | while read -r line; do
    submodule_path=$(echo $line | awk '{print $2}')
    if [ ! -d "$submodule_path" ] || [ -z "$(ls -A "$submodule_path" 2>/dev/null)" ]; then
        echo "Removing submodule: $submodule_path"
        git submodule deinit -f "$submodule_path" 2>/dev/null
        git rm -f "$submodule_path" 2>/dev/null
        rm -rf .git/modules/"$submodule_path" 2>/dev/null
    fi
done

# Clean .gitmodules
if [ -f ".gitmodules" ]; then
    grep -v '\[submodule' .gitmodules > .gitmodules.tmp
    mv .gitmodules.tmp .gitmodules
    git add .gitmodules
fi

# =========================
# 2. Remove large zip files
# =========================
if [ -f "$ZIP_FILE" ]; then
    echo "Removing large zip file: $ZIP_FILE"
    git rm -f "$ZIP_FILE"
fi

# =========================
# 3. Merge missing files from source repo
# =========================
if [ -d "$SOURCE_REPO" ]; then
    echo "Merging missing files from $SOURCE_REPO..."
    rsync -av --ignore-existing "$SOURCE_REPO/" "$MAIN_REPO/"
else
    echo "Source repo not found: $SOURCE_REPO"
fi

# =========================
# 4. Commit and push changes
# =========================
git add .
git commit -m "Fix submodules, remove zip, merge missing files from DivineTruthAscension" 2>/dev/null || echo "Nothing new to commit"
git push origin main

# =========================
# 5. Start local preview server
# =========================
echo "Starting local preview server on port $HTTP_PORT..."
http-server -p $HTTP_PORT
