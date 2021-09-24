
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
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          GITHUB_REPOSITORY: ${{ secrets.GITHUB_REPOSITORY }}
          GITHUB_ACTOR: ${{ secrets.GITHUB_ACTOR }}
          DEST_REPO: ${{ secrets.DEST_REPO }}
          DEST_REPO_TOKEN: ${{ secrets.DEST_REPO_TOKEN }}
```

