#!/bin/bash
function usage(){
echo <<EOH
    Usage: $0 [devel|publish|management] [files]
    Example: $0 devel python file.py file2.py
EOH

exit 1
}

source /etc/codenv.conf
[[ ! -e ~/.codenv/vim/ ]] && { mkdir -p ~/.codenv/vim/ && cp -r $PREFIX/share/codenv/vim/ ~/.codenv/; } &>/dev/null

cpath=~/.codenv/vim/

case "$1" in
    devel) opts="+TlistToggle";shift;;
    publish) opts="";shift;;
    management) opts="~/.codenv/work.timelog ";shift;;
    help) usage;;
esac

vim -u ~/.codenv/vim/vimrc $opts +TlistToggle ${@}
