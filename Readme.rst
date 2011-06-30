About BaShit
------------
BaShit is a set of bash tools and functions designed to improve a terminal user's working speed
Right now, I'm working on it, and adding documentations, so don't be impatient, It'll be usable soon.
It's, actually, usable, it's just you'll have to figure out how to do it by yourself...
hint: 

::

    source general; help;

For confs, copy confs/* into $HOME/.bash_configs/ and source it in your bashrc:

File .bashrc:

::

    source ~/.bash_configs/bashrc


Et voilá.


Another example: to create a menu, go to functions/ dir, and try this:

::
    source TUI
    mkmenu -f "echo" -o "Print a blank line" -t "Dummy menu title"
