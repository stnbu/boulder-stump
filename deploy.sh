#!/bin/sh -ue

REMOTE_DIR="/home/mburr/git/unintuitive.org/www/d76bd92cf6e5f593cab2824e7774eaca544838ef8d358db5a0df5c200d74f3b2/boulder-stump"

cd $(dirname $0)

git add *.org || true
git commit -m 'deploy-bot'
git push

for ORG_FILE in *.org ; do
    emacs "$ORG_FILE" --batch -f org-html-export-to-html --kill >/dev/null 2>&1
done

rsync -xa * pu:"$REMOTE_DIR"/
rm -rf *.html # hope you didn't need any of these.
echo "Happy!"
