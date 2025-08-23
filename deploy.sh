#!/data/data/com.termux/files/usr/bin/bash
# DivineTruthAscension Termux Full Setup & Deploy Script

# --------------------------
# Configuration
# --------------------------
PROJECT_DIR="$HOME/divinetruthascension"
PUBLIC_FOLDER="$PROJECT_DIR"  # Change if your build output is in another folder
SITE_ID="YOUR_NETLIFY_SITE_ID"  7b18fe4a-bed2-4d6a-aa93-9f0ed93a41e8
GIT_REMOTE_URL="git@github.com:USERNAME/DivineTruthAscension.git"  https://github.com/settings/keys:divinetruthascension-dev/DivineTruthAscension.git

# --------------------------
# Step 1: Update & Install Essentials
# --------------------------
pkg update -y && pkg upgrade -y
pkg install -y git openssh curl nodejs-lts npm

# --------------------------
# Step 2: Generate SSH Key (if none exists)
# --------------------------
SSH_KEY="$HOME/.ssh/id_rsa.pub"
if [ ! -f "$SSH_KEY" ]; then
  echo "Generating SSH key..."
  ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -N ""
  echo "Add this SSH key to your GitHub/GitLab account:"
  cat "$SSH_KEY"
  read -p "Press Enter after adding SSH key..."
fi

# --------------------------
# Step 3: Clone Project Repository (if folder missing)
# --------------------------
if [ ! -d "$PROJECT_DIR" ]; then
  git clone "$GIT_REMOTE_URL" "$PROJECT_DIR"
fi

# --------------------------
# Step 4: Navigate to project folder
# --------------------------
cd "$PROJECT_DIR" || { echo "Project folder not found!"; exit 1; }

# --------------------------
# Step 5: Install TailwindCSS & Dependencies
# --------------------------
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p

# Optional: Set Tailwind input/output (adjust if your structure differs)
INPUT_CSS="src/input.css"
OUTPUT_CSS="public/output.css"

if [ ! -f "$INPUT_CSS" ]; then
  mkdir -p src
  echo "@tailwind base;\n@tailwind components;\n@tailwind utilities;" > "$INPUT_CSS"
fi

# --------------------------
# Step 6: Build TailwindCSS
# --------------------------
npx tailwindcss -i "$INPUT_CSS" -o "$OUTPUT_CSS" --minify

# --------------------------
# Step 7: Install Netlify CLI
# --------------------------
npm install -g netlify-cli

# --------------------------
# Step 8: Authenticate Netlify CLI
# --------------------------
echo "Authenticating Netlify CLI..."
netlify logout
netlify login

# --------------------------
# Step 9: Link project to Netlify site
# --------------------------
netlify link --id "$SITE_ID"

# --------------------------
# Step 10: Deploy to Netlify
# --------------------------
echo "Deploying project to Netlify..."
netlify deploy --prod --dir="$PUBLIC_FOLDER" --site="$SITE_ID"

echo "✅ Full setup + Tailwind build + deployment complete!"
