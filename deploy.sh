#!/bin/sh -ue

REMOTE_DIR="/home/mburr/git/unintuitive.org/www/boulder-stump"

cd $(dirname $0)

mkdir -p target/html target/pdf

PATH="/usr/local/texlive/2021/bin/universal-darwin:$PATH"
pandoc --toc -s book.org -o target/pdf/book.pdf ; echo "Created PDF."
pandoc --toc -s book.org -o target/html/book.html ; echo "Created HTML."
pandoc -s README.md -o target/html/index.html ; echo "Created index."
cp -f index.css target/html/ ; echo "Copied CSS."

rsync -xa target/html/ target/pdf/ pu:"$REMOTE_DIR"/ # dumpet together
echo "Web server updated."

problem() {
    echo "PROBLEM! Job had non-zero status: ${1}"
}

if git status --untracked-files=no --short | grep -q ^ ; then
    git add book.org *.sh index.css README.md || problem "git add"
    git commit -qm 'deploy-bot' || problem "git commit"
    git push 2> /dev/null || problem "git push"
    echo "Changes pushed."
else
    echo "No changes found."
fi
