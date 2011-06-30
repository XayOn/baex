#!/bin/bash
# Screen Utilities
X11_screen_reso(){ xrandr | grep "*" |awk '{print $1}'; }
X11_best_screen_reso(){ xrandr |awk '/\+$/ {print $1}'; }
X11_screen_outputs(){ xrandr |awk '/ connected/ {print $1}';  }
set_auto_X11_reso(){ outputs=($(X11_screen_outputs)); a=($(X11_best_screen_reso)); b=0; for i in ${a[@]}; do output=${outputs[$b]}; xrandr --output $output --mode $i; ++ b; done; }

auto_screensize(){ trap 'COLUMNS=$(tput cols) LINES=$(tput lines)' WINCH; export AUTO_SCREENSIZE=1; }
screen_c(){  [[ "$AUTO_SCREENSIZE" ]] && echo $COLUMNS || tput cols; }
screen_l(){  [[ "$AUTO_SCREENSIZE" ]] && echo $LINES || tput lines; }
screen_goto(){ [[ "1" ]] && [[ "$2" ]] &&  echo -n -e "\033[${1};${2}H" || screen_goto_col $1; }
screen_goto_col(){ tput cuf $1; } 
print_at(){ screen_goto $(split $1 x); shift; echo $@; } 
echo_center(){ a=$2; [[ ! $a ]] && a=`screen_c`; print_at "`get_center $a ${#1}`" "$1"; }
mkline(){ [[ $2 ]] && { for i in `seq 0 $2`; do echo -n $1; done ; echo; } || {  eval printf "%.0s$1" {1..$(screen_c)}; }; }
