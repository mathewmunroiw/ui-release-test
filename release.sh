#!/usr/bin/env bash
package_file='package.json'
target_release_branch='master'
current_branch=$(git branch | grep \* | cut -d ' ' -f2)
current_version=$(echo $parameters | jq -r .["\"$environment\""].common.parameters)

echo "Current Branch [$current_branch]"
echo "Target Release Branch [$target_release_branch]"
