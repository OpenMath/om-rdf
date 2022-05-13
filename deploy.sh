#!/bin/bash
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

target=$dir/target/generated-docs
deploy_branch=gh-pages
if [ "$1" ]; then token="$1"; fi
remote_url="https://$GITHUB_ACTOR:$token@github.com/$GITHUB_REPOSITORY"

# author, date and message for deployment commit
name=$(git log -n 1 --format='%aN')
email=$(git log -n 1 --format='%aE')
author="$name <$email>"
date=$(git log -n 1 --format='%aD')
message="Built from $(git rev-parse --short HEAD)"

# create temp dir and clone deploy repository
tempdir=$(mktemp -d -p .)
if ! git clone --single-branch --branch "$deploy_branch" "$remote_url" "$tempdir"; then exit; fi

# change to deploy repository
cd "$tempdir"
# remove existing files
git rm -rf . &>/dev/null
# copy generated files
cp -R "$target/." .

status=$(git status --porcelain)
# if there are any changes
if [ "$status" != "" ]
then
	git config user.email "$email"
	git config user.name "$name"
	git add --all && git commit --message="$message" --author="$author" --date="$date"
	git push -q origin $deploy_branch
fi
