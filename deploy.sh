#!/bin/sh -ue

REMOTE_DIR="/home/mburr/git/unintuitive.org/www/boulder-stump"

cd $(dirname $0)

mkdir -p target/html

ORG_FILES=$(git status --short --untracked-files=no --porcelain | grep -v _0 |\
		grep '\.org$' | cut -d ' ' -f 3 | xargs ls -1t)

for ORG_FILE in $ORG_FILES ; do
    OUT_FILE="target/html/$(basename $ORG_FILE ".org").html"
    echo "Writing $OUT_FILE ..."
    pandoc -s $ORG_FILE -o $OUT_FILE
done

pandoc -s README.md -o target/html/index.html
cp -f index.css target/html/ # um.
rsync -xa target/html/ pu:"$REMOTE_DIR"/
echo "Web server updated."

if git status -s | grep -q ^ ; then
    git add *.org *.sh index.css README.md || echo "no add"
    git commit -qm 'deploy-bot' || echo "no commit"
    git push 2> /dev/null || echo "no push"
    echo "Changes pushed."
else
    echo "No changes found."
fi

## For reference:
#PATH=/usr/local/texlive/2021/bin/universal-darwin:$PATH pandoc --toc -s 0*.org -s Appendix.org -o /tmp/test.pdf && open /tmp/test.pdf
