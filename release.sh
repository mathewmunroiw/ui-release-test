#!/usr/bin/env bash

## Check status of develop branch and ensure everything is committed and up to date
target_release_branch='master'
current_branch=$(git branch | grep \* | cut -d ' ' -f2)
current_version=$(echo $parameters | jq -r .["\"$environment\""].common.parameters)

echo "Current Branch [$current_branch]"

if [ "develop" != $current_branch ]; then
    printf "\xE2\x9D\x8C Not in develop\n"
    exit 0
fi

echo "Target Release Branch [$target_release_branch]"

if [ -z "$(git status --porcelain)" ];
then
    printf "\xE2\x9C\x94 Nothing to Commit\n"
else
    printf "\xE2\x9D\x8C Changes need commiting before releasing\n"
    exit 0
fi

UPSTREAM=${1:-'@{u}'}
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse "$UPSTREAM")
BASE=$(git merge-base @ "$UPSTREAM")

echo "upstream:$UPSTREAM"

if [ $LOCAL = $REMOTE ]; then
    printf "\xE2\x9C\x94 Up to date\n"
elif [ $LOCAL = $BASE ]; then
    printf "\xE2\x9D\x8C Need to pull\n"
    exit 0
elif [ $REMOTE = $BASE ]; then
    printf "\xE2\x9D\x8C Need to push\n"
    exit 0
else
    printf "\xE2\x9D\x8C\xE2\x9D\x8C\xE2\x9D\x8C Remote and Local Diverged \xE2\x9D\x8C\xE2\x9D\x8C\xE2\x9D\x8C\n"
    exit 0
fi

## Get app name and current version in package.json
package_file='package.json'
package=$(cat package.json)
app_name=$(echo $package | jq -r '."name"')
current_version=$(echo $package | jq -r '."version"')

echo "--------------"
echo "Application: $app_name"
echo "Current Version: v$current_version"

## Get npms next version using Major Release as option
suggested_next_version=$(npm version major)
##reset back to previous version (undo npm version major)
reset_head=$(git reset --hard HEAD^)
#delete tag that was made
delete_tag=$(git tag -d $suggested_next_version)
echo "what is the release version for '$app_name' [$suggested_next_version]:"
read user_provided_version

## Merge master into develop (this should not cause any conflicts)
