#!/bin/bash

set -e
abort () { echo "Error: $*" >&2; exit 1; }

# Check if new changes have been documented.
sed -n "/^## \[Unreleased\]/I,/^## /p" CHANGELOG.md |
    grep -v '^## ' |
    grep -qv '^ *$'  ||
    abort "CHANGELOG.md has no new entries"

version=$(date +%F-%H%M)

[ "$(git branch --show-current)" = "master" ] || abort "Not on master branch"
[ -z "$(git status --porcelain)" ] || abort "Uncommitted changes"

rev1=$(git rev-parse HEAD)
rev2=$(git ls-remote origin master | cut -f1)
[ $rev1 == $rev2 ] || abort "Need git pull/push"

# Update CHANGELOG.md
sed -i "/^## \[Unreleased\]/Ia \n## [$version]" CHANGELOG.md
