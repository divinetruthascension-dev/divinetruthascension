#!/bin/bash
# ------------------------------------------------------
# DivineTruthAscension - Environment Check + GitHub PAT setup
# Mobile-friendly Termux version
# ------------------------------------------------------

set -e

echo "🔹 Checking system environment..."

# 1️⃣ Node.js & npm
if command -v node >/dev/null 2>&1; then
    echo "✅ Node.js installed: $(node -v)"
else
    echo "⚠️ Node.js not found. Please install Node.js LTS first."
fi

if command -v npm >/dev/null 2>&1; then
    echo "✅ npm installed: $(npm -v)"
else
    echo "⚠️ npm not found. Please install Node.js LTS first."
fi

# 2️⃣ Git
if command -v git >/dev/null 2>&1; then
    echo "✅ Git installed: $(git --version)"
else
    echo "⚠️ Git not found. Install with: pkg install git"
fi

# 3️⃣ Netlify CLI
if command -v netlify >/dev/null 2>&1; then
    echo "✅ Netlify CLI installed: $(netlify --version)"
else
    echo "⚠️ Netlify CLI not found. Install with: npm install -g netlify-cli"
fi

# 4️⃣ GitHub SSH setup
SSH_KEY="$HOME/.ssh/id_ed25519"
if [ ! -f "$SSH_KEY" ]; then
    echo "🔹 Generating SSH key for GitHub..."
    ssh-keygen -t ed25519 -C "divinetruthascension@gmail.com" -f "$SSH_KEY" -N ""
fi

echo "🔹 Your SSH public key (add this to GitHub SSH keys):"
cat "${SSH_KEY}.pub"

# 5️⃣ GitHub HTTPS with Personal Access Token (PAT)
echo
echo "🔹 Setup GitHub repository URL with PAT:"
echo "Enter your GitHub PAT (paste directly):"
read -s GITHUB_PAT

REPO_URL="https://divinetruthascension-dev:${GITHUB_PAT}@github.com/divinetruthascension-dev/DivineTruthAscension.git"
echo "🔹 Your HTTPS remote URL with PAT:"
echo "$REPO_URL"

# Optional: Test clone into a temp folder
echo "🔹 Testing repository access..."
TMP_DIR="$HOME/diva-test"
rm -rf "$TMP_DIR"
git clone "$REPO_URL" "$TMP_DIR" && echo "✅ Clone successful!" || echo "⚠️ Clone failed. Check your PAT."

echo
echo "🎉 Environment check complete!"
echo "Use SSH or HTTPS remote URL to push/pull changes."
