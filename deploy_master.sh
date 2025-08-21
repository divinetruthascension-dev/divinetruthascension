# Paste the script and save (CTRL+O, Enter, CTRL+X)#!/data/data/com.termux/files/usr/bin/bash
# ==========================================================
# DivineTruthAscension Master Deploy Script
# Fully automated deployment to GitHub + Netlify
# ==========================================================

# ---------------- CONFIGURATION ----------------
PROJECT_DIR="$HOME/storage/shared/DivineTruthAscension"
GITHUB_REPO="git@github.com:divinetruthascension-dev/divinetruthascension
NETLIFY_SITE_ID=ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF5O5B7QhZyOubLLzuk7vaS5wotcflL9CNfdkTaVKWaf divinetruthascension@gmail.com
NETLIFY_AUTH_TOKEN=          nfp_btXPyrG829hrPC65Q5dcnh15Z6LMU7Wzc41f
BRANCH="main"

# ---------------- START ----------------
echo "🚀 Starting DivineTruthAscension deployment..."

# Step 0: Go to project folder
cd "$PROJECT_DIR" || { echo "❌ Project directory not found!"; exit 1; }

# Step 1: Install dependencies if package.json exists
if [ -f package.json ]; then
    echo "📦 Installing npm dependencies..."
    npm install
fi

# Step 2: Build project (if package.json exists)
if [ -f package.json ]; then
    echo "🏗 Building project..."
    npm run build
fi

# Step 3: Ensure assets are up to date
if [ -d "assets" ]; then
    echo "🖼 Ensuring assets are included..."
    git add assets/
fi

# Step 4: Add all changes to Git
echo "📝 Adding changes to Git..."
git add .
git commit -m "Auto-deploy: $(date '+%Y-%m-%d %H:%M:%S')" || echo "⚠ No changes to commit."

# Step 5: Push to GitHub
echo "🌐 Pushing changes to GitHub..."
git push $GITHUB_REPO $BRANCH

# Step 6: Deploy to Netlify
echo "🚀 Deploying to Netlify..."
netlify deploy \
    --dir="$PROJECT_DIR" \
    --site=$NETLIFY_SITE_ID \
    --auth=$NETLIFY_AUTH_TOKEN \
    --prod

echo "✅ Deployment complete!"
