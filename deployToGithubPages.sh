#!/bin/sh

# If a command fails then the deploy stops
set -e

printf "\033[0;32mDeploying updates to GitHub...\033[0m\n"

# Build the project.
hugo

mkdir deploy-target
mv public/* deploy-target

# Add changes to git.
cd deploy-target
git init
git remote add origin git@github.com:Z4HD/Z4HD.github.io.git
git add --all

# Commit changes.
msg="Rebuilding site $(date -I)"
if [ -n "$*" ]; then
	msg="$*"
fi
git commit -m "$msg"

# Push source and build repos.
git push --force origin master

# Clean up
cd ..
rm -rf deploy-target
rm -rf public
rm -rf resources