#!/bin/bash

longest_element(){
doc <<EOD

    longest_elemen_len
    ------------------

    Given an array of strings, gets the longest element in them.

    :param array: Array of strings to get the longest element
    :returns: Longest element

EOD

eval $endoc

    { # Make it silent.

        current=""
        for elem in "${@}"; do
            (( ${#elem} > ${#current} )) && current=${elem}
        done

    } &>/dev/null

    echo -n $current
}


arithmetic_avg(){

doc <<EOD

    arithmetic_avg
    -------------------

    Gets the arithmetic average

EOD

eval $endoc

    echo $(( ( $1 - $2 ) / 2 ))

}

split(){

doc <<EOD
    
    split
    -----

    split a string using a specified separator

    :param string: String to split
    :param separator: Separator
    :param return: Where to store return array

EOD

eval $endoc

    declare -ax $3
    declare -n RESULT=$3

    RESULT=( $(echo $1|tr $2 " ") )

}

make_associative(){
doc <<EOD

    make_associative 
    ----------------

    :param variable_to_store_results: Where to store result

    Exports a global variable <variable_to_store_results> containing
    an associative array from the text provided via stdin

    This expects two-column input as:

    ::

        foo bar
        baz stuff
        baz stuff stuff

EOD

eval $endoc


    declare -Axg $1
    declare -n RESULT=$1

    while read name value; do
        RESULT[$name]="${value}"
    done </dev/stdin
}
