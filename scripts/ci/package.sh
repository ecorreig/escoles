#!/bin/sh

COMMIT_MSG=$(git log -1 --pretty=%B)
COMMIT_SUB=$(git log -1 --pretty=%s)
COMMIT_HASH=$(git log -1 --pretty=%H)


tar -czvf /tmp/package.tgz $FILES
if [  $? != 0 ]; then
    echo "Error packaging it"
    exit -1
fi

curl -k -F message="$COMMIT_MSG" -F hash=$COMMIT_HASH -F file=@/tmp/package.tgz $SERVER/upload_version/$TOKEN > "out.html"
if [  $? != 0 ]; then
    echo "Error pushing the package"
    exit -1
fi

out_content=$(cat out.html)
if [ "$out_content" != "Upload" ]; then
    echo "$out_content"
    exit -1
fi