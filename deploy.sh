#!/bin/sh -ue

REMOTE_DIR="/home/mburr/git/unintuitive.org/www/boulder-stump"

cd $(dirname $0)

mkdir -p target/html

# Hopefully all git-controlled *.org files, hopefully in descending modification order.
ORG_FILES=$(git status --short --untracked-files=no --porcelain |\
		grep '\.org$' | cut -d ' ' -f 3 | xargs ls -1t)

for ORG_FILE in $ORG_FILES ; do
    OUT_FILE="target/html/$(basename $ORG_FILE ".org").html"
    echo "Writing $OUT_FILE ..."
    pandoc -s $ORG_FILE -o $OUT_FILE
done

cp -f index.css index.html target/html/ # um.

rsync -xa target/html/ pu:"$REMOTE_DIR"/

echo "Web server updated."

# whatamess
if git add *.org *.sh index.html index.css > /dev/null ; then
    git commit -qm 'deploy-bot' > /dev/null
    git push -q > /dev/null
    echo "Changes pushed."
else
    echo "No changes found."
fi


