#!/bin/sh -ue

cd $(dirname $0)

mkdir -p preview/pdf preview/html

PATH="/usr/local/texlive/2021/bin/universal-darwin:$PATH"
sed -E 's/:noexport://' gog.org > preview/pdf/.gog.org ## using stdin instead of file broke! somehow.
pandoc --toc -s preview/pdf/.gog.org -o preview/pdf/gog.pdf ; echo "Created PDF."
emacsclient -n preview/pdf/gog.pdf
