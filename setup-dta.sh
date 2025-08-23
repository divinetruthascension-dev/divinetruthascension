#!/data/data/com.termux/files/usr/bin/bash

# === DivineTruthAscension Setup Script for Termux ===
# Author: Desmond McBride
# Purpose: Setup Node.js LTS, Netlify CLI, and deploy your project
# Notes: Mobile-friendly, no EOF, npm logs redirected

echo "📂 Creating npm log folder..."
mkdir -p ~/npm-logs
npm config set cache ~/npm-logs
npm config set loglevel verbose

echo "🟢 Installing Node.js LTS..."
pkg install nodejs-lts -y

echo "📦 Installing Netlify CLI locally..."
npm install netlify-cli --save-dev

echo "🔑 Checking Netlify login status..."
netlify status || netlify login

echo "📂 Linking local project folder to Netlify site..."
cd ~/divinetruthascension || { echo "❌ Project folder not found"; exit 1; }
netlify link || echo "⚠️ Make sure to enter your site ID if prompted"

echo "🚀 Deploying site to Netlify..."
netlify deploy --prod || echo "❌ Deploy failed. Check logs in ~/npm-logs"

echo "💻 Starting Netlify Dev server (optional)..."
netlify dev || echo "⚠️ Dev server not started. Use 'netlify dev' manually"

echo "✅ Setup & Deploy complete!"
echo "📁 Project folder: ~/divinetruthascension"
echo "📌 npm logs stored in ~/npm-logs"
echo "📌 Use 'netlify dev' to start local dev server anytime"
