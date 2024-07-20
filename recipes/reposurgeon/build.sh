#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make
make install prefix=${PREFIX}
go-licenses save ./cutter --save_path=license-files_repocutter --ignore github.com/termie/go-shutil
go-licenses save ./mapper --save_path=license-files_repomapper --ignore github.com/termie/go-shutil
go-licenses save ./surgeon --save_path=license-files_reposurgeon --ignore github.com/termie/go-shutil
go-licenses save ./tool --save_path=license-files_repotool --ignore github.com/termie/go-shutil

mkdir -p ${PREFIX}/share/emacs/site-lisp
install -m 644 reposurgeon-mode.el ${PREFIX}/share/emacs/site-lisp/reposurgeon-mode.el
