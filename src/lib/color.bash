#!/bin/bash

get_color(){
doc <<EOD

    get_color
    ---------

    :param color: Color to return

    Returns either a color (just a normal echo) or a stablished color
    from the theme's palette.

    This is probably not very useful, and might be changed in a near future

EOD

eval $endoc

    [[ $1 < 254 ]] && {
        echo $1
    } || {
        echo ${colors[$1]}
    }

}

set_foreground(){
doc <<EOD

    set_foreground
    --------------

    Sets the current fg color.

    :param color: 0-255 or long name specified in colors variable

EOD

eval $endoc

    color=$(get_color ${1})
    [[ $color ]] && tput setaf $color
}

set_background(){
doc <<EOD

    set_background
    --------------

    Sets the current bg color.

    :param color: 0-255 or long name specified in colors variable

EOD

eval $endoc

    color=$(get_color ${1})
    [[ $color ]] && tput setbg $color
}

colorize(){

doc <<EOD

    colorize
    --------

    Colorizes a phrase.
    :param fg: Foreground color
    :param bg: Background color
    :param phrase: what to apply color on. This takes ${@} - $1 - $2 (2:)

    fg and bg are a number between 0-255 or the long name specified in the
    colors variable (stablished in the current theme).


EOD

eval $endoc

    set_foreground $1; shift
    set_background $2; shift

    echo -en "${@}"
    tput sgr0
}
