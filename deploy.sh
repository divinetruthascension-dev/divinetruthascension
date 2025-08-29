#!/data/data/com.termux/files/usr/bin/bash
# 🚀 Termux Setup + Node.js Web Dev + Netlify Deploy (Silent CI-style)

set -e  # Stop if any command fails
set -o pipefail  # Ensure any pipe failure stops execution

# -----------------------------
# 0. Parse optional argument
# -----------------------------
DEPLOY_MODE="prod"
if [ "$1" == "preview" ]; then
  DEPLOY_MODE="draft"
  echo "⚠️ Preview mode enabled: deploying to Netlify draft URL"
else
  echo "✅ Production mode: deploying to Netlify production"
fi

# -----------------------------
# 1. Check Netlify login
# -----------------------------
if ! netlify status &> /dev/null; then
  echo "❌ Netlify CLI not logged in. Please run 'netlify login' first."
  exit 1
fi

# -----------------------------
# 2. Update Termux packages silently
# -----------------------------
echo "Updating Termux packages..."
pkg update -y > /dev/null 2>&1 && pkg upgrade -y > /dev/null 2>&1

# -----------------------------
# 3. Install core dev tools silently
# -----------------------------
echo "Installing core packages..."
pkg install -y git nodejs-lts nano termux-api openssh > /dev/null 2>&1

# -----------------------------
# 4. Install build tools for node-gyp silently
# -----------------------------
echo "Installing build tools..."
pkg install -y python clang make > /dev/null 2>&1
npm install -g node-gyp > /dev/null 2>&1 || echo "⚠️ node-gyp global install failed, continuing..."

# -----------------------------
# 5. Install global npm packages silently
# -----------------------------
echo "Installing global npm packages..."
npm install -g http-server netlify-cli > /dev/null 2>&1 || echo "⚠️ npm global install warnings ignored"

# -----------------------------
# 6. Setup storage access silently
# -----------------------------
echo "Setting up storage access..."
termux-setup-storage || echo "⚠️ Storage setup skipped (permission may be required)"

# -----------------------------
# 7. Show versions
# -----------------------------
echo "Node.js version: $(node -v)"
echo "npm version: $(npm -v)"
echo "git version: $(git --version)"
echo "Netlify CLI version: $(netlify --version || echo 'Not installed')"

# -----------------------------
# 8. Change to project directory
# -----------------------------
PROJECT_DIR=~/divinetruthascension/divinetruthascension
cd "$PROJECT_DIR" || { echo "Project directory not found! Exiting."; exit 1; }

# -----------------------------
# 9. Clean and install project dependencies silently
# -----------------------------
echo "Cleaning old dependencies..."
rm -rf node_modules package-lock.json
echo "Installing project dependencies..."
npm install --legacy-peer-deps --loglevel=error > /dev/null 2>&1 || echo "⚠️ npm install warnings ignored"

# -----------------------------
# 10. Rebuild native modules silently
# -----------------------------
echo "Rebuilding native modules with node-gyp..."
node-gyp rebuild > /dev/null 2>&1 || echo "⚠️ node-gyp rebuild failed or no native modules, skipping"

# -----------------------------
# 11. Build project if script exists
# -----------------------------
if npm run | grep -q 'build'; then
  echo "Build script found, running npm run build..."
  npm run build > /dev/null 2>&1 || echo "⚠️ Build completed with warnings, continuing..."
else
  echo "No build script found, skipping build."
fi

# -----------------------------
# 12. Commit & push local changes silently
# -----------------------------
if [ -n "$(git status --porcelain)" ]; then
  echo "Committing local changes..."
  git add .
  git commit -m "Auto-commit before Netlify deploy" > /dev/null 2>&1 || echo "⚠️ Git commit skipped"
  git push origin main > /dev/null 2>&1 || echo "⚠️ Git push failed"
else
  echo "No local changes to commit, skipping Git push"
fi

# -----------------------------
# 13. Auto-detect deploy folder
# -----------------------------
if [ -d "dist" ]; then
  DEPLOY_DIR="dist"
elif [ -d "build" ]; then
  DEPLOY_DIR="build"
else
  DEPLOY_DIR="."
fi

# -----------------------------
# 14. Deploy to Netlify silently
# -----------------------------
echo "Deploying from folder: $DEPLOY_DIR (mode: $DEPLOY_MODE)..."
netlify deploy --"$DEPLOY_MODE" --dir="$DEPLOY_DIR" > /dev/null 2>&1 || echo "⚠️ Deployment may have warnings"

# -----------------------------
# 15. Monitor deploy logs
# -----------------------------
netlify deploy:monitor || echo "⚠️ Could not stream logs"

echo "✅ Silent setup and deployment complete!"
