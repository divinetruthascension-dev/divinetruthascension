#!/data/data/com.termux/files/usr/bin/bash
# Auto GitHub SSH setup for Termux

set -e

echo "🔑 Checking for existing SSH key..."
if [ ! -f ~/.ssh/id_rsa ]; then
  echo "⚡ No SSH key found. Generating new key..."
  ssh-keygen -t rsa -b 4096 -C "divinetruthascension@gmail.com" -f ~/.ssh/id_rsa -N ""
else
  echo "✅ SSH key already exists at ~/.ssh/id_rsa"
fi

echo "🚀 Starting ssh-agent..."
eval "$(ssh-agent -s)"

echo "➕ Adding SSH key to agent..."
ssh-add ~/.ssh/id_rsa

echo "📋 Your public key (copy this to GitHub: Settings → SSH and GPG Keys):"
echo "-------------------------------------------------------------"
cat ~/.ssh/id_rsa.pub
echo "-------------------------------------------------------------"

echo "🔍 Testing GitHub connection..."
ssh -T git@github.com || true

echo "✅ Done! Paste the above key into GitHub before retrying deploy."
