#!/bin/bash
source /etc/codenv.conf
[[ ! -e ~/.codenv/bash/ ]] && { cp -r $PREFIX/share/codenv/bash/ ~/.codenv/; } &>/dev/null
bash -rcfile ~/.codenv/bash/bashrc
