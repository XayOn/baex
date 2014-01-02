#!/bin/bash
source $(source_yabatool)
load screen_display TUI
mkmenu -t "Menu title" -o "Option Foo bar baz"  -f "echo" -o "Option baz stuff" -f "echo"
