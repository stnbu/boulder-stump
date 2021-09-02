#!/bin/sh -ue

REMOTE_DIR="/home/mburr/git/unintuitive.org/www/boulder-stump"

cd $(dirname $0)

for ORG_FILE in *.org ; do
    emacs "$ORG_FILE" --batch -f org-html-export-to-html --kill >/dev/null 2>&1
done

rsync -xa * pu:"$REMOTE_DIR"/
rm -rf 00*.html Appendix.html Spoilers.html # hope you didn't need any of these.

echo "Web server updated."

# whatamess
if git add *.org */*.org *.sh *.html index.css > /dev/null ; then
    git commit -qm 'deploy-bot' > /dev/null
    git push -q > /dev/null
    echo "Changes pushed."
else
    echo "No changes found."
fi


