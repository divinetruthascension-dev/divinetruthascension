#!/bin/bash
# setup-github-ssh.sh
# Termux GitHub SSH setup

# 1. Ensure git and openssh are installed
pkg update -y
pkg install -y git openssh

# 2. Generate SSH key (if not exists)
SSH_KEY="$HOME/.ssh/id_rsa"
if [ ! -f "$SSH_KEY" ]; then
    echo "Generating new SSH key..."
    ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f "$SSH_KEY" -N ""
else
    echo "SSH key already exists."
fi

# 3. Start SSH agent and add key
eval "$(ssh-agent -s)"
ssh-add "$SSH_KEY"

# 4. Display SSH public key (copy this to GitHub)
echo ""
echo "----- COPY THIS SSH KEY TO GITHUB -----"
cat "$SSH_KEY.pub"
echo "--------------------------------------"
echo ""

# 5. Test GitHub SSH connection
echo "Testing GitHub SSH connection..."
ssh -T git@github.com

echo ""
echo "✅ SSH setup complete. Now you can clone/push/pull using SSH:"
echo "git clone git@github.com:username/repo.git"
#!/bin/bash
# setup-git-ssh.sh
# Configure GitHub remote to use SSH

cd ~/divinetruthascension

# Check if remote exists
REMOTE_URL=$(git remote get-url origin 2>/dev/null)

if [[ "$REMOTE_URL" == *"https://github.com"* ]]; then
    echo "Updating Git remote to SSH..."
    git remote set-url origin git@github.com:divinetruthascension-dev/DivineTruthAscension.git
else
    echo "Git remote already uses SSH."
fi

# Test connection
echo "Testing SSH connection to GitHub..."
ssh -T git@github.com
#!/bin/bash
# deploy-dta-ssh.sh
# Deploy DivineTruthAscension using SSH

cd ~/divinetruthascension

# Ensure repo is up to date
git fetch origin
git checkout main
git pull origin main

# Build or prepare project
echo "Building project..."
# Insert your build commands here (npm run build / any other)

# Push changes to GitHub
echo "Pushing to GitHub via SSH..."
git add .
git commit -m "Deploy update"
git push origin main

# Optional: deploy to Netlify (if using CLI with SSH)
echo "Deploying to Netlify..."
netlify deploy --prod
