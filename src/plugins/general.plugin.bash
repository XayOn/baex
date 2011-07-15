#!/bin/bash
# General utils

get_source_path(){
    # Source: http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
    {
        SCRIPT_PATH="${BASH_SOURCE[0]}";
        if [ -h "${SCRIPT_PATH}" ]; then while [ -h "${SCRIPT_PATH}" ]; do SCRIPT_PATH=`readlink "${SCRIPT_PATH}"`; done; fi
        pushd . > /dev/null; cd `dirname ${SCRIPT_PATH}` > /dev/null; SCRIPT_PATH=`pwd`; popd  > /dev/null
    } &>/dev/null
    echo $SCRIPT_PATH;
}

source_path=`get_source_path`;
debug=0;
. $source_path/config
. $source_path/main.theme

document(){ [[ $helpbuilder ]] && { docs[$1]=" $1 $3\n\t$2"; return 0; } || return 1; }
document_files(){ for i in "$@"; do document_file $i; done; }
document_file(){
    export helpbuilder=1;
    [[ $1 ]] && a=$1 || a=$0
    for i in `command grep "document " $a|command grep -v 'document()'|grep -v document_file|command awk '{print $2}'|tr '"' ' '`; do 
        $i;
    done
    export helpbuilder=0;
}

help(){
    document_files ${!loaded[@]} $source_path/general.plugin.bash
    [[ ! $1 ]] && { command help; for i in "${docs[@]}"; do echo -en "$i"|head -n1; done; } || echo -e ${docs[$1]} || echo "Command not found"
}

++(){
    document "++" "Increases by one varname." "VAR_TO_INCREASE" && return
    export $1=$(( $1 + 1 )); 
}

_(){
    document "_" "Calls gettext for translation" "TEXT" && return
    gettext "$@";
}

max_len_in_array(){
    document "max_len_in_array" "Gets max lenght in array passed as argument" "array" && return 
    o=0; { for i in "${@}"; do (( ${#i} > $o )) && o=${#i}; done } &>/dev/null; 
    echo -n $o;
}

get_center(){
    document "get_center" "Gets the center , or, if specified a variable, where to start printing it to make it centered"\
        "number [string]" && return
    [[ $2 ]] && echo $(( ( $1 - $2 ) / 2 )) || echo $(( $1 / 2 )); 
}

split(){ 
    document "split" 'Returns an array replacing \$2 in \$1' "STRING SEPARATOR" && return
    echo $1|tr $2 " ";
}

# Overload . sourcing to allow tests, so we won't load twice the same lib.
declare -A loaded
.(){
    document "." "Reimplementation of . sourcing, loads from an array of files" "ARRAY_OF_FILES_TO_LOAD" && return
    for i in $@; do (( $debug == 1 )) && echo "Loading $i"; load $i; done; 
}

_load(){ source $1 && loaded[$1]=1 || load_failed "$@"; }
load(){
    document "load" "Load a specific file or a jabashit plugin" "file|pluginname" && return
    for i in "${@}"; do 
        [[ ! ${loaded[$i]} ]] && { 
            if [ -f $source_path/$i.plugin.bash ]; then _load $source_path/$i.plugin.bash; else _load $i; fi;
        }
    done;
}
load_failed(){ (( $debug == 1 )) && { _ "Failed loading: "; echo -e "\t$1"; }>&2; }
