#!/bin/bash
# =================================================
# DivineTruthAscension Setup Script (Termux)
# =================================================

set -e  # Stop on errors

echo "🚀 Starting DivineTruthAscension setup..."

# 1. Update Termux packages
pkg update -y
pkg upgrade -y

# 2. Install essential packages
pkg install -y git openssh nodejs-lts nano

# 3. Configure npm to use package-lock only
npm config set package-lock true

# 4. Fix invalid filenames in project folder
echo "🔹 Checking for invalid filenames..."
find . -name '*#*' | while read file; do
    newfile=$(echo "$file" | tr -d '#')
    mv "$file" "$newfile"
    echo "Renamed $file → $newfile"
done

# 5. Initialize Git if not already
if [ ! -d ".git" ]; then
    git init
    echo "Git repository initialized."
fi

# 6. Setup SSH keys
SSH_KEY="$HOME/.ssh/id_ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF5O5B7QhZyOubLLzuk7vaS5wotcflL9CNfdkTaVKWaf divinetruthascension@gmail.com
