# We source the general plugin, ONLY the general plugin
source ../plugins/general.plugin.bash
# Then, we use load to load each file we want 
load screen_display TUI
# Here we've loaded a fucking bunch of stuff, and my favourite one:
mkmenu -t "Menu title" -o "Option Foo bar baz"  -f "echo" -o "Option baz stuff" -f "echo"
