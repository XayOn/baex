Baex
----

Baex (ba-ex) is a quite complete set of bash functions designed to help
in creating complex shell scripts.

This is specially useful when you need to depend only on bash, or you use
extensive use of system()/interact with a lot of unix-like tools.

API
---

Have a look at the `API documentation <./docs/api.rst>`_


Examples
--------

The API documentation is really complete. But I'm providing a clear example of
use here, a tool to operate on cd/dvd stuff.

::

    source build/baex.bash

    declare -a operations
    operations=(save_disk write_iso write_dir erase_dev)

    simple_menu "CD/DVD" cont \
        "Copy the content of a cd/dvd to an iso image" \
        "Write iso image to a cd/dvd" \
        "Write directory to cd/dvd" \
        "Erase rw cd/dvd"

    read -p "Options ([source] [destination]): " -a options

    handle_optical ${operations[${cont}]} ${options}

This is a fully-enabled shell script that makes a TUI for all usual
operations on cd/dvd drives.

Bit outdated, but hey... good things never get old.

.. image:: http://media4.giphy.com/media/p6VjEoV8i3HRS/200w.gif
