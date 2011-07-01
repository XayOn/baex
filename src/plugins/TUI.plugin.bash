#!/bin/bash
# TUI tools
. general
. color display_

declare -a menuopts menufuncs; 
start_menu(){ echo_center "$1" "$2"; menu_vwall $2; }
menu_failed_response(){ _ "Error, try again"; }
menu_wall(){ colorize none,${theme['menu_separator_color']} ${theme['menu_separator']}; }
menu_vwall(){ colorize none,${theme['menu_separator_color']} "${theme['menu_edge']}$(mkline "${theme['separator']}" $(($1 -2 )))${theme['menu_edge']}";echo; }
menu_entry(){ tput sc; menu_wall; colorize none,${theme['menu_number']} "$2)"; echo -n " "; colorize none,${theme['normal']} "$1"; tput rc; screen_goto_col $3; echo $(menu_wall);}
menu_get_response(){ read -p "`_ \"Enter option: \"`" response; (( $response > $1 )) && response=-127; }
mkmenu(){
    while getopts "o:f:t:" opt; do case $opt in o) menuopts[${#menuopts}]=$OPTARG;; f) menufuncs[${#menufuncs}]=$OPTARG;; t) title=$OPTARG;; esac; done
    status=0; menu_len=$(( $(max_len_in_array "${menuopts[@]}") + 5 ));(( $menu_len < ${#title} )) && menu_len=$((${#title} + 4 ));
    start_menu "$title" $menu_len
    for i in "${menuopts[@]}"; do ++ status; menu_entry "${i[@]}" $status $menu_len; done
    menu_vwall $menu_len
    while [ "1" ]; do
        menu_get_response ${#menuopts};
        [[ $response != -127 ]] && { ${menufuncs[$(( $response - 1 ))]}; break ; } || { menu_failed_response; }
    done 
}

