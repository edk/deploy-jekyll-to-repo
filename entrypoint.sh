#!/bin/bash

set -e
#set -x

TARG_DIR="${JEKYLL_DESTINATION:-_site}"
BRANCH="gh-pages"
export BUNDLE_BUILD__SASSC=--disable-march-tune-native

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

# using the ruby-2.7.2 docker image, the debian setup seems to ignore  the
# use specific ~/.ssh/config file.  So this workaround puts the directives
# into the glboal /etc/ssh/ssh_config instead
RUN echo "    IdentityFile /github/home/.ssh/deploy.key" >> /etc/ssh/ssh_config
RUN echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config

#echo "Host *" >> ~/.ssh/config
#echo "  IdentityFile ~/.ssh/deploy.key" >> ~/.ssh/config
#echo "  StrictHostKeyChecking no" >> ~/.ssh/config

# don't need keyscan if we're disabling strict hostkey checking
# ssh-keyscan github.com 2>&1 >> ~/.ssh/known_hosts

chmod 600 ~/.ssh/*
chmod 700 ~/.ssh

ssh -i ~/.ssh/deploy.key -T git@github.com || true

git config --global init.defaultBranch master
git init
git config user.name "${GITHUB_ACTOR}"
git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"
git add .
git commit -m "published by GitHub Actions"
git push --force git@github.com:${DEST_REPO_GIT} master:${BRANCH}
