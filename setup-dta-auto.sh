#!/data/data/com.termux/files/usr/bin/bash
# =====================================================
# Auto Setup script for DivineTruthAscension project on Termux
# Includes Node.js LTS, Git, Netlify CLI, TailwindCSS
# Automatically adds SSH key and Netlify PAT
# =====================================================

# 1. Update Termux packages
echo "🔄 Updating Termux packages..."
pkg update -y
pkg upgrade -y

# 2. Install required packages
echo "📦 Installing required packages..."
pkg install -y git curl wget nodejs-lts nano unzip openssh

# 3. Verify Node.js installation
echo "🟢 Node.js version:"
node -v
npm -v

# 4. Setup Git configuration
echo "🔧 Configuring Git..."
git config --global user.name "Desmond McBride"
git config --global user.email "divinetruthascension@gmail.com"

# 5. Generate SSH key if it doesn't exist
SSH_KEY="$HOME/.ssh/id_rsa.pub"
if [ ! -f "$SSH_KEY" ]; then
    echo "🔑 Generating SSH key..."
    ssh-keygen -t rsa -b 4096 -C "divinetruthascension@gmail.com" -f "$HOME/.ssh/id_rsa" -N ""
else
    echo "🔑 SSH key already exists."
fi

# Display SSH key for GitLab/GitHub
echo "📋 Add this SSH key to your Git provider:"
cat "$SSH_KEY"

# 6. Setup Netlify CLI
echo "🌐 Installing Netlify CLI..."
npm install -g netlify-cli

# 7. Add Netlify token (replace YOUR_NETLIFY_TOKEN below)
echo "🔐 Setting Netlify Personal Access Token..."
export NETLIFY_AUTH_TOKEN="YOUR_NETLIFY_TOKEN"

# 8. Create project folder and navigate
PROJECT_DIR="$HOME/divinetruthascension"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# 9. Link Netlify project (replace SITE_ID below)
echo "🔗 Linking Netlify project..."
# Uncomment and replace SITE_ID when ready:
# netlify link --id <SITE_ID>

# 10. Initialize TailwindCSS
echo "🎨 Installing TailwindCSS..."
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p

# 11. Ensure npm lockfile exists
echo "🔒 Creating package-lock.json..."
npm i --package-lock-only

# 12. Check deploy status
echo "🚀 Checking Netlify deploy status..."
netlify status

# 13. Final instructions
echo "✅ Setup complete!"
echo "🔹 SSH key displayed above, add it to GitHub/GitLab."
echo "🔹 Use 'netlify dev' to start the local dev server."
echo "🔹 Your project folder: $PROJECT_DIR"
