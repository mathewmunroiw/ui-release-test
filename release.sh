#!/usr/bin/env bash
package_file='package.json'
target_release_branch='master'
current_branch=$(git branch | grep \* | cut -d ' ' -f2)
current_version=$(echo $parameters | jq -r .["\"$environment\""].common.parameters)

echo "Current Branch [$current_branch]"
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
elif [ $REMOTE = $BASE ]; then
      printf "\xE2\x9D\x8C Need to push\n"
else
    echo "!WARNING! Diverged"
fi


echo -ne '#####                     (33%)\r'
sleep 1
echo -ne '#############             (66%)\r'
sleep 1
echo -ne '#######################   (100%)\r'
echo -ne '\n'
