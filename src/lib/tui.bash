titled_box(){
doc <<EOD

    titled_box
    ----------

    Creates a cool utf-8 box with enumerated options.
    Does not print text options nor do anything to choose.
    
    .. note::

        Caveat: only 1 line options supported... 
        and that depends on line size =(

    :param title: Title
    :param number_of_options: Number of options to create the box fo.

EOD

eval $endoc

    # We force the size trap
    auto_termsize

    wrap  "┌" "$(mkline ─)" "┐"

    mkemptyline "│"
    reset_row
    echo_center $1

    declare -xag menu_start menu_end
    get_current_position menu_start

    for n in $(seq 1 $2); do
        mkemptyline "│" 
        reset_row
        echo " $n │ "
    done

    get_current_position menu_end

    wrap  "└" "$(mkline ─)" "┘"
}

fill_titled_box(){
doc <<EOD

    fill_titled_box
    ---------------

    Fills a previously (the latest, in fact...) created box.

    .. note::

        This is kinda not-nice. Be careful.
        Also, as titled_box, supports only one line options depending
        on line-size.

    .. note::

        TODO: I could allow to pass menu_start and menu_end values
        as an option. This way I could fill previously created menus
        and make multi-menu windows =)
EOD

eval $endoc

    # We force the size trap
    auto_termsize

    opts=("${@}");

    for opt in ${!opts[@]}; do
        screen_goto $((${menu_start[0]} + ${opt} )) $((${menu_start[1]} + 7))
        echo ${opts[$opt]}
    done

    screen_goto ${menu_end}
}

simple_menu(){
doc <<EOD

    simple_menu
    -----------

    Creates a simple menu
    :param title: Title
    :param store: Where to store user choice
    :params options: Options (all the rest of the parameters
EOD

eval $endoc

    title=$1
    storage=$2
    shift 2
    declare -n RESULT=$storage

    opts=("${@}");
    titled_box $title "${#opts[@]}"
    fill_titled_box "${opts[@]}"
    echo

    read -p "Enter option: " RESULT
}
