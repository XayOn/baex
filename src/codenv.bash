#!/bin/bash
source /etc/codenv.conf
[[ ! -e ~/.codenv/vim/ ]] && { mkdir -p ~/.codenv/vim/ && cp -r $PREFIX/share/codenv/vim/ ~/.codenv/; } &>/dev/null
vim -u ~/.codenv/vim/vimrc ${@}
