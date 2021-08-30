#!/bin/sh -ue

REMOTE_DIR="/home/mburr/git/unintuitive.org/www/boulder-stump"

cd $(dirname $0)

for ORG_FILE in *.org ; do
    emacs "$ORG_FILE" --batch -f org-html-export-to-html --kill >/dev/null 2>&1
done

rsync -xa * pu:"$REMOTE_DIR"/
rm -rf *.html # hope you didn't need any of these.

echo "Web server updated."

git add *.org || true
git commit -qm 'deploy-bot'
git push -q


echo "Changes pushed."
