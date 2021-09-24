
# Build and deploy jekyll site to a specified repo

Sample `.github/workflow/build.yml`
```
name: Jekyll Deploy

on:
  push:
    branches:
      - main

jobs:
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
      - name: GitHub Checkout
        uses: actions/checkout@v2
      - name: Bundler Cache
        uses: actions/cache@v2
        with:
          path: vendor/bundle
          key: ${{ runner.os }}-gems-${{ hashFiles('**/Gemfile.lock') }}
          restore-keys: |
            ${{ runner.os }}-gems-
      - name: Build and push to public repo
        uses: edk/deploy-jekyll-to-repo@main
        env:
          GITHUB_ACTOR: ${{ secrets.GITHUB_ACTOR }}
          DEST_REPO_GIT: ${{ secrets.DEST_REPO_GIT }}
          DEST_REPO_DEPLOY_KEY: ${{ secrets.DEST_REPO_DEPLOY_KEY }
```

## Secrets
put the public key in the target repo secrets, put the private key in the private repo secrets.
* (create deploy key)[https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key]  Also: https://docs.github.com/en/enterprise-server@2.22/developers/overview/managing-deploy-keys#deploy-keys
* (Add it to the destination repo secrets)[https://docs.github.com/en/actions/security-guides/encrypted-secrets]
* ensure DEST_REPO is the ssh repo path on Github.