#!/usr/bin/env bash
package_file='package.json'
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

if [ $LOCAL = $REMOTE ]; then
    printf "\xE2\x9C\x94 Up to date\n"
elif [ $LOCAL = $BASE ]; then
    printf "\xE2\x9D\x8C Need to pull\n"
    exit 0
elif [ $REMOTE = $BASE ]; then
    printf "\xE2\x9D\x8C Need to push\n"
    exit 0
else
    printf "\xE2\x9D\x8C \xE2\x9D\x8C \xE2\x9D\x8C Master and Develop have Diverged \xE2\x9D\x8C \xE2\x9D\x8C \xE2\x9D\x8C"
    exit 0
fi
printf "\xE2\x9D\x8C\xE2\x9D\x8C\xE2\x9D\x8C Master and Develop have Diverged \xE2\x9D\x8C\xE2\x9D\x8C\xE2\x9D\x8C\n"
echo -ne '#####                     (33%)\r'
sleep 1
echo -ne '#############             (66%)\r'
sleep 1
echo -ne '#######################   (100%)\r'
echo -ne '\n'
