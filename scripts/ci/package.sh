#!/bin/sh

COMMIT_MSG=$(git log -1 --pretty=%B)
COMMIT_SUB=$(git log -1 --pretty=%s)
COMMIT_HASH=$(git log -1 --pretty=%H)


R CMD install devtools
R CMD build EscolesCovid
if [  $? != 0 ]; then
    echo "Error packaging it"
    exit -1
fi

FILE_GENERATED=$(ls -la | grep EscolesCovid | head -n 1)
echo "$FILE_GENERATED"

curl -F message="$COMMIT_MSG" -F hash=$COMMIT_HASH -F file=@./$FILE_GENERATED $SERVER/upload_version/$TOKEN > "out.html"
if [  $? != 0 ]; then
    echo "Error pushing the package"
    exit -1
fi

out_content=$(cat out.html)
if [ "$out_content" != "Upload" ]; then
    echo "$out_content"
    exit -1
fi