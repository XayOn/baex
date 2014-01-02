Yet Another Bash Tool
------------------------

yabatool (yet-another-bash-tool) is a set of tools and functions designed to make bash scripting faster and cleaner

To view yabatool documentation, simply execute

::

    source $(source_yabatool); yabatool_api;

Usage examples
---------------

Now my favourite example, a menu creator:

::

    source $(source_yabatool)
    load screen_display TUI
    mkmenu -t "Menu title" -o "Option Foo bar baz"  -f "echo" -o "Option baz 
    stuff" -f "echo"

Now, we serve a directory:

::

    source $(source_yabatool)
    load network
    serve_directory
    # And to stop it...
    stop_serving_directory


All right, what about writing a DIRECTORY to a cd?

::

    source $(source_yabatool)
    load device_utils
    cdtool /dev/cdrom /home/foo/bar
    # And we delete a cdrw
    cdtool erase_dev /dev/cdrom 
    # And what about writing a simple iso image?
    cdtool write_iso /dev/cdrom image.iso
    # And to save a copy of the current cd
    cdtool save /dev/cdrom saved_image.iso

One of my favourites, set all output devices connected to the reso xrandr 
says its its best.

::

    source $(source_yabatool)
    load screen_display
    set_auto_X11_reso


Hell, and I just mentioned half of them, and I've documented just a few!
