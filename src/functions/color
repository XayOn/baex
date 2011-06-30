#!/bin/bash
declare -A colors highlights
get_color(){ [[ $1 < 254 ]] && { echo $1; } || { echo ${colors[$1]} ; } ; }
colorize(){ a=($(split $1 ",")); fg=$(get_color ${a[1]}); bg=$(get_color ${a[2]}); ef=$(get_color ${a[0]}); 
[[ $bg ]] && tput setab $bg ; [[ ${fg} ]] && tput setaf $fg; [[ ${ef} != "0" ]] && tput $ef; echo -en "$2"; tput sgr0; }
