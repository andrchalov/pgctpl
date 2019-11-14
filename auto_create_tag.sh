#!/bin/sh

current_release=`cat version`

tag_page_status=`curl -s -o /dev/null -w "%{http_code}" https://github.com/${DRONE_REPO}/releases/tag/${current_release}`

if [ $tag_page_status == "404" ]
then
  sha=`cat .git/refs/heads/master`

  curl -X POST -d '{"tag":"'${current_release}'","message":"new version","object":"'${sha}'","type":"tree"}' \
    --header "Content-Type:application/json" \
    -u ${DRONE_REPO_OWNER}:${GITHUB_API_KEY} \
    "https://api.github.com/repos/${DRONE_REPO}/git/tags"

  curl -X POST -d '{"ref":"refs/tags/'${current_release}'","sha":"'${sha}'"' \
    --header "Content-Type:application/json" \
    -u ${DRONE_REPO_OWNER}:${GITHUB_API_KEY} "https://api.github.com/repos/${DRONE_REPO}/git/refs"
fi
