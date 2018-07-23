#!/bin/bash
set -euo pipefail

# Colorize me baby
green() { printf '\e[1;32m%b\e[0m\n' "$@"; }
yellow() { printf '\e[1;33m%b\e[0m\n' "$@"; }
red() { printf '\e[1;31m%b\e[0m\n' "$@"; }

# Change to script dir
cd "$(dirname "$0")"
cd ..

if [ -z "$(command -v jq)" ]; then
    red "Missing jq, please install."
    yellow "Mac: 'brew install jq'"
    yellow "centos: 'yum install jq'"
    yellow "debian: 'apt-get install jq'"
    exit 1
fi

if [ -z "$(command -v sponge)" ]; then
    red "Missing sponge, please install."
    yellow "Mac: 'brew install moreutils'"
    yellow "centos: 'yum install moreutils'"
    yellow "debian: 'apt-get install moreutils'"
    exit 1
fi

# Clear out templates file
echo "[]" > ./templates.json

# Download external templates
green "Downloading external templates"
REPOS=$(jq -rs '.[][]' external-repos.json)
for URL in $(jq -rs '.[][]' external-repos.json); do
    echo "File: $URL"
    curl -sL $URL --output /tmp/dl-templates.json

    echo "Merging Files"
    jq -s '.[0] + .[1]' ./templates.json /tmp/dl-templates.json | sponge ./templates.json
    rm -f /tmp/dl-templates.json

    echo "Done"
    echo ""
done

# Combine local templates
green "Processing local templates files"

echo "Combining all local templates to one file"
jq -s '.' ./templates/*.json > /tmp/merged-templates.json

echo "Merging Files"
jq -s '.[0] + .[1]' ./templates.json /tmp/merged-templates.json | sponge ./templates.json
rm -f /tmp/merged-templates.json
echo "Done"


echo ""
green "All Done!"
