#!/bin/bash

set -e
set -x

TARG_DIR="${JEKYLL_DESTINATION:-_site}"
REPO="https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
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

echo "pushing site to repo..."

cd ${TARG_DIR}

git init
git config user.name "${GITHUB_ACTOR}"
git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"
git add .
git commit -m "published by GitHub Actions"
git push --force ${REPO} master:${BRANCH}


