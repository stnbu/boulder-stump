#!/bin/sh -ue

cd $(dirname $0)

mkdir -p preview/pdf preview/html

PATH="/usr/local/texlive/2021/bin/universal-darwin:$PATH"
sed -E 's/:noexport://' gog.org | less #| pandoc --toc -s - -o preview/pdf/gog.pdf ; echo "Created PDF."
open preview/pdf/gog.pdf

problem() {
    echo "PROBLEM! Job had non-zero status: ${1}"
}

if git status --untracked-files=no --short | grep -q ^ ; then
    git add gog.org *.sh index.css README.md  || problem "git add"
    git commit -qm 'deploy-bot'               || problem "git commit"
    git push 2> /dev/null                     || problem "git push"
    echo "Changes pushed."
else
    echo "No changes found."
fi
