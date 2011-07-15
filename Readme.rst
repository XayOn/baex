About Jabashit
------------
Jabashit is a set of bash tools and functions designed to improve a terminal user's working speed
Right now, I'm working on it, and adding documentations, so don't be impatient, It'll be usable soon.
It's, actually, usable, it's just you'll have to figure out how to do it by yourself...
hint: 

::

    source general; help;

It also includes a set of nice bash configurations, wich, for using it, you'll just have to execute (as normal user):

::

    make conf

Then source it in your bashrc:

::

    source ~/.bash_configs/bashrc

Don't forget to modify it.

Now my favourite example, a menu creator:

::

    source PATH_TO_JABASHIT/plugins/general.plugin.bash
    load screen_display TUI
    mkmenu -t "Menu title" -o "Option Foo bar baz"  -f "echo" -o "Option baz stuff" -f "echo"

Now, we serve a directory:

::

    source PATH_TO_JABASHIT/plugins/general.plugin.bash
    load network
    serve_directory
    # And to stop it...
    stop_serving_directory


All right, what about writing a DIRECTORY to a cd?

::

    source PATH_TO_JABASHIT/plugins/general.plugin.bash
    load device_utils
    cdtool /dev/cdrom /home/foo/bar
    # And we delete a cdrw
    cdtool erase_dev /dev/cdrom 
    # And what about writing a simple iso image?
    cdtool write_iso /dev/cdrom image.iso
    # And to save a copy of the current cd
    cdtool save /dev/cdrom saved_image.iso

One of my favourites, set all output devices connected to the reso xrandr says its its best.

::

    source PATH_TO_JABASHIT/plugins/general.plugin.bash
    load screen_display
    set_auto_X11_reso


Hell, and I just mentioned half of them, and I've documented just a few!
