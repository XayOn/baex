
"_"
-----

Translate a string

This is an alias of gettext "$@"



arithmetic_avg
-------------------

Gets the arithmetic average



auto_termsize
-------------

Adds a trap on "winch" signal, so columns and lines global variables 
(COLUMNS, LINES) are updated in real time




cd_erase_disk
-------------

Erases the content of a rw drive

:param drive: cd/dvd drive



cd_save_disk
------------

Saves a cd/dvd to disk

:param drive: cd/dvd drive
:param file: destination file



cd_write_dir
------------

Creates an ISO image from a directory and then 
writes it into a cd/dvd

:param drive: cd/dvd drive
:param dir: directory to write on the cd/dvd



cd_write_iso
------------

Writes an ISO image to a cd/dvd drive

:param drive: cd/dvd drive
:param file: File to write cd/dvd image from



colorize
--------

Colorizes a phrase.

:param fg: Foreground color
:param bg: Background color
:param phrase: what to apply color on. This takes  -  -  (2:)

fg and bg are a number between 0-255 or the long name specified in the
colors variable (stablished in the current theme).




echo_at
--------

Echo into a specific location.

:param X: X position 
:param Y: Y position 
:param text: This behaves just like echo. It'll accept any parameter there.


screen_goto
-----------

Put the cursor in a specific position in the screen.

:param cols: Column to put it into
:param rows: Row to put it into





echo_center
-----------

Center text.

:param text: Just like echo.



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


get_color
---------

:param color: Color to return

Returns either a color (just a normal echo) or a stablished color
from the theme's palette.

This is probably not very useful, and might be changed in a near future



get_current_position
--------------------

Gets current position (X,Y) of the cursor on the screen.

:params result: Variable to store the result into.



handle_optical
--------------

Executes common actions on cd/dvd images.

Actually available actions:

* save_disk: Copies the content of a cd/dvd to an iso image
* write_iso: Writes an ISO image to a cd/dvd
* write_dir: Creates an ISO image and writes it into a cd/dvd
* erase_dev: Cleans a rw cd/dvd.

:param action: Action to execute
:param device: Device to execute actions on
:param file: File/Source/Destiny folder to execute actions on



longest_elemen_len
------------------

Given an array of strings, gets the longest element in them.

:param array: Array of strings to get the longest element
:returns: Longest element



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



mkemptyline
-----------

Creates a hollow line with the given character as delimitier by both sides

:param char: character



mkline
------

Creates a line with the given character.

:param char: character



repeat_char
-----------

Repeats a character N times. No newline added.

:param char: Character to repeat
:param times: Times to repeat it



require 
-------

:param list of libraries: List of libraries to load

Sources files on list_of_libraries.
Those files MUST be on current_path and have .bash extension

As I'm migrating this to a single-script (compiled) this will probably
not be needed anymore.



reset_row
---------

Puts cursor on col 0



screen_goto
-----------

Put the cursor in a specific position in the screen.

:param cols: Column to put it into
:param rows: Row to put it into




set_background
--------------

Sets the current bg color.

:param color: 0-255 or long name specified in colors variable



set_foreground
--------------

Sets the current fg color.

:param color: 0-255 or long name specified in colors variable



simple_menu
-----------

Creates a simple menu
:param title: Title
:param store: Where to store user choice
:params options: Options (all the rest of the parameters


split
-----

split a string using a specified separator

:param string: String to split
:param separator: Separator
:param return: Where to store return array



titled_box
----------

Creates a cool utf-8 box with enumerated options.
Does not print text options nor do anything to choose.

.. note::

    Caveat: only 1 line options supported... 
    and that depends on line size =(

:param title: Title
:param number_of_options: Number of options to create the box fo.



unique_process
--------------

Handles a pid file in /tmp with the process' name,
killing the proc that's there, and writing its own
pid to the pid file.

This way we can safely launch a program twice, and
not have them be at the same time.



wrap
----

Simply wraps an string with a start and an end.

:param start: start string
:param content: content string
:param end: end string


