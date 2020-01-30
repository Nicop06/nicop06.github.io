#!/bin/sh

# Temporarily store uncommited changes
git stash

# Verify correct branch
git checkout develop

# Build new files
cabal new-run blog clean
cabal new-run blog build

# Get previous files
git fetch --all
git checkout -b master --track origin/master

# Overwrite existing files with new files
rsync -a --filter='P _site/'         \
         --filter='P _cache/'        \
         --filter='P dist/'          \
         --filter='P dist-newstyle/' \
         --filter='P .git/'          \
         --filter='P .gitignore'     \
         --filter='P .stack-work'    \
         --delete-excluded           \
         _site/ .

# Commit
git add -A
git commit -e -m "$(git log -1 --pretty=format:%B develop)"

# Push
git push origin master:master

# Restoration
git checkout develop
git branch -D master
git stash pop
