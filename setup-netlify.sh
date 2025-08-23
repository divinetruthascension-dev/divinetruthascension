/data/data/com.termux/files/usr/bin/bash
 setup-netlify.sh
 DivineTruthAscension Netlify CLI auto-setup + deploy

echo 🚀 Setting up Netlify CLI...

 1. Install Node.js LTS + Git + Netlify CLI
pkg install -y nodejs-lts git
npm install -g netlify-cli

 2. Add your Netlify token
NETLIFY_TOKEN=nfp_kYX8CpnGfBW2ka1mJ38fVeM9iV6WZoKw5aae

 3. Add your Netlify Site ID
NETLIFY_SITE_ID=5Soc0Utxc1f8ZrNRbWYUPedGiA

 4. Save token + site id to ~/.bashrc for persistence
if  grep -q NETLIFY_AUTH_TOKEN ~/.bashrc; then
  echo "export NETLIFY_AUTH_TOKEN=$NETLIFY_TOKEN >> ~/.bashrc
  echo "✅ Netlify token saved
fi

if  grep -q NETLIFY_SITE_ID ~/.bashrc; then
  echo export NETLIFY_SITE_ID=$Infodinetruthascensioncom.com >> ~/.bashrc
  echo "✅ Netlify Site ID saved
fi

 5. Reload bashrc so env vars are active now
source ~/.bashrc

 6. Check status
netlify status || echo ⚠️ Netlify CLI not connected

 7. Deploy to Netlify
echo 🚀 Deploying DivineTruthAscension site...
netlify deploy --site 7b18fe4a-bed2-4d6a-aa93-9f0ed93a41e8D --prod --dir=dist
