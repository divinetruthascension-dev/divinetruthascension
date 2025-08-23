#!/bin/bash
# ----------------------------------------
# 🔹 DivineTruthAscension Auto Deploy (Termux)
# Detects GitHub auth method (SSH / HTTPS with PAT)
# Uses Netlify auth token for deployment
# ----------------------------------------

set -e

PROJECT_DIR="$HOME/divinetruthascension"
LOG_FILE="$PROJECT_DIR/deploy.log"

echo "🌟 Starting auto deploy for DivineTruthAscension..." | tee "$LOG_FILE"

cd "$PROJECT_DIR"

# ------------------------
# 1️⃣ Ensure Node.js LTS
# ------------------------
if ! command -v node &> /dev/null; then
    echo "⚡ Node.js not found. Installing Node.js LTS..." | tee -a "$LOG_FILE"
    pkg install -y nodejs-lts
else
    echo "✅ Node.js is installed." | tee -a "$LOG_FILE"
fi

# ------------------------
# 2️⃣ Detect GitHub auth method
# ------------------------
GIT_SSH_TEST=$(ssh -T git@github.com 2>&1)
if echo "$GIT_SSH_TEST" | grep -q "successfully authenticated"; then
    echo "🔑 Using SSH for GitHub" | tee -a "$LOG_FILE"
    GIT_REMOTE_URL="git@github.com:divinetruthascension-dev/DivineTruthAscension.git"
else
    if [ -z "$GITHUB_PAT" ]; then
        echo "❌ GitHub PAT not set and SSH failed!" | tee -a "$LOG_FILE"
        exit 1
    fi
    echo "🔑 Using HTTPS PAT for GitHub" | tee -a "$LOG_FILE"
    GIT_REMOTE_URL="https://$GITHUB_PAT@github.com/divinetruthascension-dev/DivineTruthAscension.git"
fi

git remote set-url origin "$GIT_REMOTE_URL"

# ------------------------
# 3️⃣ Git sync
# ------------------------
echo "🌿 Syncing Git repository..." | tee -a "$LOG_FILE"
git add -A
git commit -m "Auto deploy commit" || echo "ℹ️ No changes to commit"
git pull --rebase || echo "ℹ️ Pull skipped"
git push || echo "ℹ️ Push skipped"

# ------------------------
# 4️⃣ Install npm dependencies
# ------------------------
if [ -f package.json ]; then
    echo "📦 Installing npm dependencies..." | tee -a "$LOG_FILE"
    npm install | tee -a "$LOG_FILE"
else
    echo "⚠️ package.json not found. Skipping npm install." | tee -a "$LOG_FILE"
fi

# ------------------------
# 5️⃣ Ensure public/index.html exists
# ------------------------
mkdir -p public
if [ ! -f public/index.html ]; then
cat <<EOL > public/index.html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Divine Truth Ascension</title>
</head>
<body>
<h1>Welcome to Divine Truth Ascension</h1>
</body>
</html>
EOL
echo "✅ Created public/index.html" | tee -a "$LOG_FILE"
fi

# ------------------------
# 6️⃣ Build project if npm build exists
# ------------------------
if npm run | grep -q "build"; then
    echo "🔨 Running npm build..." | tee -a "$LOG_FILE"
    npm run build | tee -a "$LOG_FILE"
else
    echo "ℹ️ No build script found. Skipping build." | tee -a "$LOG_FILE"
fi

# ------------------------
# 7️⃣ Netlify deploy using NETLIFY_AUTH_TOKEN
# ------------------------
if [ -z "$NETLIFY_AUTH_TOKEN" ]; then
    echo "❌ NETLIFY_AUTH_TOKEN environment variable not set!" | tee -a "$LOG_FILE"
    exit 1
fi

echo "🚀 Deploying to Netlify..." | tee -a "$LOG_FILE"
netlify deploy --prod --dir=public --auth="$NETLIFY_AUTH_TOKEN" | tee -a "$LOG_FILE"

echo "🎉 Auto deployment complete! Logs saved to $LOG_FILE"
