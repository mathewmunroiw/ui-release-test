#!/usr/bin/env bash
package_file='package.json'
target_release_branch='master'
current_branch=$(git branch | grep \* | cut -d ' ' -f2)
current_version=$(echo $parameters | jq -r .["\"$environment\""].common.parameters)

echo "Current Branch [$current_branch]"
echo "Target Release Branch [$target_release_branch]"

if [ -z $(git status --porcelain) ];
then
    echo "\xE2\x9C\x94 Nothing to Commit"
else
    echo "PLEASE COMMIT YOUR CHANGE FIRST!!!"
    echo $(git status --porcelain)
fi

UPSTREAM=${1:-'@{u}'}
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse "$UPSTREAM")
BASE=$(git merge-base @ "$UPSTREAM")

if [ $LOCAL = $REMOTE ]; then
    echo "Up-to-date"
elif [ $LOCAL = $BASE ]; then
    echo "Need to pull"
elif [ $REMOTE = $BASE ]; then
    echo "Need to push"
else
    echo "Diverged"
fi


echo -ne '#####                     (33%)\r'
sleep 1
echo -ne '#############             (66%)\r'
sleep 1
echo -ne '#######################   (100%)\r'
echo -ne '\n'
