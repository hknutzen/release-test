#!/bin/bash

set -e
abort () { echo "Aborted: $*" >&2; exit 1; }

# Get recent changes.
DOC=$(sed -n "/^## \[Unreleased\]/I,/^## /p" CHANGELOG.md | grep -v '^## ')
# Abort if changes are only empty lines.
echo "$DOC" | grep -qv '^ *$'  || abort "CHANGELOG.md has no new entries"

# Check git
[ "$(git branch --show-current)" = "master" ] || abort "Not on master branch"
[ -z "$(git status --porcelain)" ] || abort "Uncommitted changes"
rev1=$(git rev-parse HEAD)
rev2=$(git ls-remote origin master | cut -f1)
[ $rev1 == $rev2 ] || abort "Need git pull/push"

# Update version
export VERSION="$(date +%F-%H%M)"
sed -i "/^## \[Unreleased\]/Ia \\\n## [$VERSION]" CHANGELOG.md
git add CHANGELOG.md
git commit -m$VERSION
git push
git tag $VERSION
git push --tags

# Build packages
rm -rf dist
mkdir dist
nfpm package -p deb -t dist/
nfpm package -p rpm -t dist/

# Create release on GitHub.
echo "$DOC" |
    gh release create $VERSION --notes-file - --title $VERSION dist/*
