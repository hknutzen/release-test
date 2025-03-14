#!/bin/bash
# Prepare for release.

set -e

# Get directory where this script is located.
dir=$(dirname $(readlink -f $0))

# Compile all commands.
for c in */main.go; do
    d=$(dirname $c)
    ( cd $d; go build -o $dir/bin/ )
done
