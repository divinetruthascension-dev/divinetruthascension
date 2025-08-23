#!/data/data/com.termux/files/usr/bin/bash
# 🚀 DivineTruthAscension Auto Deploy + SSH + GitHub API
# Fully automated Termux script, mobile-friendly

# --- 1. Variables ---
REPO_URL=git@github.com:divinetruthascension-dev/your-repo.git"git@github.com:divinetruthascension-dev/DivineTruthAscension.git"  # Update
BRANCH="main"
PROJECT_DIR="$HOME/divinetruthascension"
LOG_DIR="$PROJECT_DIR/npm-logs"
SSH_KEY="$HOME/.ssh/id_rsa.pub"
GITHUB_TOKEN=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"YOUR_GITHUB_PERSONAL_ACCESS_TOKEN"  # Must have repo + admin:public_key

# --- 2. Ensure directories ---
mkdir -p "$PROJECT_DIR"
mkdir -p "$LOG_DIR"
cd "$PROJECT_DIR" || exit 1

# --- 3. Git setup ---
if [ ! -d ".git" ]; then
  echo "📂 Initializing Git repository..."
  git init
  git remote add origin "$REPO_URL"
fi

# --- 4. Node.js LTS & Netlify CLI locally ---
if ! command -v node >/dev/null 2>&1; then
  echo "⬇️ Installing Node.js LTS..."
  pkg install -y nodejs-lts
fi

if ! command -v netlify >/dev/null 2>&1; then
  echo "⬇️ Installing Netlify CLI locally..."
  npm install netlify-cli --prefix "$PROJECT_DIR/node_modules"
  export PATH="$PROJECT_DIR/node_modules/.bin:$PATH"
fi

# --- 5. SSH Key Setup ---
if [ ! -f "$SSH_KEY" ]; then
  echo "🔑 Generating SSH key..."
  ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -N ""
else
  echo "✅ SSH key already exists."
fi

PUB_KEY=$(cat "$SSH_KEY")

# --- 6. Add SSH key to GitHub automatically ---
echo "🔗 Adding SSH key to GitHub via API..."
API_RESPONSE=$(curl -s -X POST -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/user/keys \
  -d "{\"title\": \"Termux-DTA-$(date +%s)\", \"key\": \"$PUB_KEY\"}")

if echo "$API_RESPONSE" | grep -q "key"; then
  echo "✅ SSH key added successfully to GitHub."
else
  echo "⚠️ Failed to add SSH key. Response: $API_RESPONSE"
fi

# --- 7. Netlify login and deploy ---
if ! netlify status >/dev/null 2>&1; then
  netlify logout
  netlify login
fi

SITE_INFO=$(netlify sites:list --json 2>/dev/null)
if [ -z "$SITE_INFO" ]; then
  echo "⚠️ No Netlify sites found. Please create a site first."
  exit 1
fi

SITE_ID=$(echo "$SITE_INFO" | grep -oP '"id":\s*"\K[^"]+' | head -n 1)
PUBLIC_FOLDER="$PROJECT_DIR"
echo "🌐 Deploying to Netlify Site ID: $SITE_ID from folder: $PUBLIC_FOLDER"

# --- 8. Git add/commit/push ---
git add .
git commit -m "Auto-commit before Netlify deploy" || echo "⚠️ Nothing to commit."
git push -u origin "$BRANCH"

# --- 9. Deploy ---
netlify deploy --prod --dir="$PUBLIC_FOLDER" --site="$SITE_ID"

# --- 10. Latest npm log ---
LATEST_LOG=$(ls -t "$LOG_DIR" 2>/dev/null | head -n 1)
if [ -n "$LATEST_LOG" ]; then
  tail -n 50 "$LOG_DIR/$LATEST_LOG"
fi

echo "✅ Full automation complete: SSH key, GitHub push, Netlify deploy!"
