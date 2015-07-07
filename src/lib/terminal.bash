#!/bin/bash
# Screen Utilities
auto_termsize(){
doc <<EOD

    auto_termsize
    -------------

    Adds a trap on "winch" signal, so columns and lines global variables 
    (COLUMNS, LINES) are updated in real time


EOD
    export COLUMNS=$(tput cols)
    export LINES=$(tput lines)
    trap 'export COLUMNS=$(tput cols) export LINES=$(tput lines)' WINCH
}

screen_goto(){ 
doc <<EOD

    screen_goto
    -----------

    Put the cursor in a specific position in the screen.

    :param cols: Column to put it into
    :param rows: Row to put it into


EOD
eval $endoc

    tput cup $1 $2
}

echo_at(){
doc <<EOD

    echo_at
    --------

    Echo into a specific location.

    :param X: X position 
    :param Y: Y position 
    :param text: This behaves just like echo. It'll accept any parameter there.

EOD

    screen_goto $1 $2
    shift 2
    echo $@
} 

echo_center(){

doc <<EOD

    echo_center
    -----------

    Center text.

    :param text: Just like echo.

EOD
eval $endoc

    # We force the screen trap.
    auto_termsize

    # Get current row
    get_current_position pos

    echo_at  ${pos[0]} $(arithmetic_avg  $COLUMNS  ${#1}) ${@}
}

get_current_position(){
doc <<EOD

    get_current_position
    --------------------

    Gets current position (X,Y) of the cursor on the screen.

    :params result: Variable to store the result into.

EOD

eval $endoc

    declare -axg $1 pos
    declare -n res=$1

    echo -en "\033[6n"; IFS=";" read -s -r -d R -a pos
    res=($((${pos[0]:2} - 1)) $((${pos[1]} - 1)))
}


repeat_char(){
doc <<EOD

    repeat_char
    -----------

    Repeats a character N times. No newline added.

    :param char: Character to repeat
    :param times: Times to repeat it

EOD

eval $endoc

    eval printf "$1%.0s" {1..$2}
}

mkline(){
doc <<EOD

    mkline
    ------

    Creates a line with the given character.

    :param char: character

EOD

eval $endoc

    repeat_char "$1" $(($COLUMNS - 3)) 
}

mkemptyline(){
doc <<EOD

    mkemptyline
    -----------

    Creates a hollow line with the given character as delimitier by both sides

    :param char: character

EOD

eval $endoc
    echo -en $1
    repeat_char "\" \"" $(($COLUMNS - 3)) 
    echo -en $1

    #get_current_position current_pos
    #screen_goto $(( ${current_pos[0]} - 1 )) 0
}

reset_row(){
doc << EOD

    reset_row
    ---------

    Puts cursor on col 0

EOD

eval $endoc

    tput cub $COLUMNS
    tput cuf 2

}

wrap(){
doc <<EOD

    wrap
    ----

    Simply wraps an string with a start and an end.

    :param start: start string
    :param content: content string
    :param end: end string

EOD

eval $endoc

    echo -en $1
    echo -en $2
    echo -e  $3

}
