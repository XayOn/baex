doc(){
    # This enables python-style docstrings for functions
    [[ $PRINT_DOCS == 1 ]] && {
        cat /dev/stdin 2>/dev/null
        return 1;
    }
}

endoc=""

show_docs(){
    # print all docs
    declare -F | while read _ _ function; do 
        [[ $function == "doc" ]] && continue
        [[ $function == "show_docs" ]] && continue
        PRINT_DOCS=1 endoc="return 0" $function | sed 's/^    //'
        echo
    done
}

require(){
doc <<EOD

    require 
    -------

    :param list of libraries: List of libraries to load

    Sources files on list_of_libraries.
    Those files MUST be on current_path and have .bash extension

    As I'm migrating this to a single-script (compiled) this will probably
    not be needed anymore.

EOD

eval $endoc

    for lib in ${@}; do source ${lib}.bash; done

}

_(){
doc <<EOD

    "_"
    -----

    Translate a string

    This is an alias of gettext "\$@"

EOD

eval $endoc

    gettext "$@"

}

unique_process(){
doc <<EOD

    unique_process
    --------------

    Handles a pid file in /tmp with the process' name,
    killing the proc that's there, and writing its own
    pid to the pid file.

    This way we can safely launch a program twice, and
    not have them be at the same time.

EOD
eval $endoc

    { kill -9 $(cat /tmp/${0}.pid); } &>/dev/null
    echo $$ > /tmp/${0}.pid

}
