#!/data/data/com.termux/files/usr/bin/bash
# DivineTruthAscension Multi-Site Auto Deploy

# ====== 1. Update system ======
pkg update -y && pkg upgrade -y

# ====== 2. Install dependencies ======
pkg install -y git curl wget jq nodejs-lts

# ====== 3. Install Netlify CLI ======
npm install -g netlify-cli

# ====== 4. Verify installs ======
echo "✅ Node version: $(node -v)"
echo "✅ NPM version: $(npm -v)"
echo "✅ Netlify CLI version: $(netlify --version)"

# ====== 5. Clone repo if missing ======
if [ ! -d "$HOME/divinetruthascension" ]; then
  git clone https://github.com/<your-username>/divinetruthascension.git ~/divinetruthascension
fi

cd ~/divinetruthascension || exit

# ====== 6. Install project dependencies ======
if [ -f package.json ]; then
  npm install || yarn install
fi

# ====== 7. Netlify auth ======
echo "🔑 Checking Netlify login..."
netlify status || netlify login

# ====== 8. Netlify Personal Access Token ======
NETLIFY_AUTH_TOKEN=nfp_kYX8CpnGfBW2ka1mJ38fVeM9iV6WZoKw5aae

# ====== 9. Detect Git branch ======
BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "📂 Current Git branch: $BRANCH"

# ====== 10. Set site name based on branch ======
if [ "$BRANCH" = "main" ]; then
  SITE_NAME="divinetruthascension"
elif [ "$BRANCH" = "dev" ]; then
  SITE_NAME="divinetruthascension-staging"
else
  echo "⚠️ Unknown branch ($BRANCH). Exiting..."
  exit 1
fi

# ====== 11. Fetch Site ID ======
echo "🔍 Fetching Site ID for: $SITE_NAME"
SITE_ID=$(curl -s -H "Authorization: Bearer $NETLIFY_AUTH_TOKEN" \
  https://api.netlify.com/api/v1/sites | jq -r ".[] | select(.name==\"$SITE_NAME\") | .id")

if [ -z "$SITE_ID" ]; then
  echo "❌ Could not fetch Site ID for $SITE_NAME."
  exit 1
fi

echo "✅ Found Site ID: $SITE_ID"

# ====== 12. Link & Deploy ======
netlify link --id $SITE_ID

echo "🚀 Deploying branch $BRANCH → $SITE_NAME..."
netlify deploy --prod
