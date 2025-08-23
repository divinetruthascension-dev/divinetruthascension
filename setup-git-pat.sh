/bin/bash
 setup-git-pat.sh
 Purpose: Configure Git repo with PAT and clone it

 --- 1. Install git if not present ---
pkg install -y git

 --- 2. Set global Git user Desmond McBride 
git config --global user.name divinetruthascension-dev 
git config --global user.email divinetruthascension@gmail.com 

 --- 3. Add remote repository using HTTPS and PAT ---
divinetruthascension-dev, divinetruthascension, and PAT below
GIT_USER=divinetruthascension-dev 
GIT_REPO=divinetruthascension 
GIT_PAT=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
GIT_URL="https://$https://github.com/settings/tokens $GIT_PAT@github.com/$GIT_USER /$GIT_REPO.git

 --- 4. Clone the repository ---
git clone $GIT_URL

 --- 5. Test Git authentication ---
cd $GIT_REPO || exit
git fetch
echo Repository cloned successfully. Current directory: $ pwd
