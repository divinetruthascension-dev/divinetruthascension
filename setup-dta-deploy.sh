#!/data/data/com.termux/files/usr/bin/bash
# setup-dta-deploy.sh
# Description: Sets up and deploys DivineTruthAscension to Netlify

# -----------------------------
# 1️⃣ Ensure Netlify CLI is installed
# -----------------------------
echo "📦 Installing/updating Netlify CLI..."
npm install -g netlify-cli || echo "⚠️ Netlify CLI may already be installed"

# -----------------------------
# 2️⃣ Check Netlify login status
# -----------------------------
echo "🔑 Checking Netlify login status..."
if ! netlify status &>/dev/null; then
  echo "🚨 Netlify session not found or expired. Logging in..."
  netlify logout &>/dev/null
  netlify login
fi

# -----------------------------
# 3️⃣ Link project to Netlify
# -----------------------------
echo "🔗 Linking project folder to Netlify site..."
if [ -z "$SITE_ID" ]; then
  echo "❗ SITE_ID not set. Use netlify link interactively."
  netlify link
else
  netlify link --id "$SITE_ID"
fi

# -----------------------------
# 4️⃣ Build / prepare project folder
# -----------------------------
echo "🛠️ Preparing project folder..."
# Example: Tailwind CSS build
if [ -f "tailwind.config.js" ]; then
  echo "💨 Running Tailwind build..."
  npx tailwindcss -i ./src/input.css -o ./dist/output.css --minify
fi

# -----------------------------
# 5️⃣ Deploy to Netlify
# -----------------------------
echo "🚀 Deploying to Netlify..."
netlify deploy --prod --dir=.

# -----------------------------
# 6️⃣ Completion message
# -----------------------------
echo "✅ Deployment complete!"
echo "📂 Project folder: $(pwd)"
echo "💡 Use 'netlify dev' to start the local dev server"
