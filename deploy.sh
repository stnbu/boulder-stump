#!/bin/sh -ue

MODE="publish"

if [ "${1:-}" = "preview" ] ; then
    MODE="preview"
fi

REMOTE_DIR="/home/mburr/git/unintuitive.org/www/boulder-stump"

cd $(dirname $0)

mkdir -p target/${MODE}/html target/${MODE}/pdf

PATH="/usr/local/texlive/2021/bin/universal-darwin:$PATH"

SOURCE="./gog.org"

problem() {
    echo "PROBLEM! Job had non-zero status: ${1}"
}

commit() {
    if git status --untracked-files=no --short | grep -q ^ ; then
	git add *.org *.sh index.css README.md || problem "git add"
	git commit -qm 'deploy-bot'            || problem "git commit"
	git push 2> /dev/null                  || problem "git push"
	echo "Changes pushed."
    else
	echo "No changes found."
    fi
}

if [ "${MODE}" = "preview" ] ; then
    TMP_SOURCE="$(mktemp --suffix=.org)"
    sed -E 's/:noexport://' "${SOURCE}" > "${TMP_SOURCE}"
    SOURCE="${TMP_SOURCE}"
fi

pandoc --toc -s "${SOURCE}" -o target/${MODE}/pdf/gog.pdf ; echo "Created PDF."

if [ "${MODE}" = "preview" ] ; then
    emacsclient -n target/${MODE}/pdf/gog.pdf
    commit
    exit $?
fi

pandoc --toc -s "${SOURCE}" -o target/${MODE}/html/gog.html ; echo "Created HTML."
pandoc -s README.md -o target/${MODE}/html/index.html ; echo "Created index."
cp -f index.css target/${MODE}/html/ ; echo "Copied CSS."

rsync -xa target/${MODE}/html/ target/${MODE}/pdf/ pu:"$REMOTE_DIR"/ # dumpet together
echo "Web server updated."
commit
