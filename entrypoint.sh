#!/bin/bash

set -e
#set -x

TARG_DIR="${JEKYLL_DESTINATION:-_site}"
BRANCH="gh-pages"
export BUNDLE_BUILD__SASSC=--disable-march-tune-native

if [ -z "$DEST_REPO_GIT" ]; then
  echo "Missing required variable: DEST_REPO_GIT"
  exit 1
fi
if [ -z "$DEST_REPO_DEPLOY_KEY" ]; then
  echo "Missing required variable: DEST_REPO_DEPLOY_KEY"
  exit 1
fi

echo "Installing gems"

# By placing gems into thsi path, we can cache it in the workflow file with github actions/cache
bundle config path vendor/bundle
bundle install --jobs 4

echo "Building site..."

if [ ! -z $YARN_ENV ]; then
  echo "Installing js packages via yarn"
  yarn
fi

JEKYLL_ENV=production NODE_ENV=production bundle exec jekyll build

echo "pushing site to ${DEST_REPO_GIT}:$BRANCH..."

cd ${TARG_DIR}

mkdir -p ~/.ssh/
echo "$DEST_REPO_DEPLOY_KEY" > ~/.ssh/deploy.key

# When using the ruby-2.7.2 docker image, the debian setup seems to ignore the
# user-specific ~/.ssh/config file.  This workaround puts the directives
# into the glboal /etc/ssh/ssh_config instead.
echo "    IdentityFile /github/home/.ssh/deploy.key" >> /etc/ssh/ssh_config
echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config

# ssh doesn't like to work with insecure data files.
chmod 600 ~/.ssh/*
chmod 700 ~/.ssh

# Tests the ssh key to make sure it's usable, but it won't stop the script if not.
# Hopefully the ssh output will point to the source of the later failure.
ssh -i ~/.ssh/deploy.key -T git@github.com || true

git config --global init.defaultBranch master
git init
git config user.name "${GITHUB_ACTOR}"
git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"
git add .
git commit -m "published by GitHub Actions"
git push --force git@github.com:${DEST_REPO_GIT} master:${BRANCH}
