#!/bin/bash
isdown(){ 
    document "isdown" "Check if a webpage is down using downforeveryoneorjustme" "URL" && return 
    wget -O -  "http://www.downforeveryoneorjustme.com/$1" 2>/dev/null | grep "not just you";
}

browse(){
    document "browse" "Launch browser-specific tasks" "[source] [pipe] [edit] [$PAGE]" && return
    [[ $1 == "source" ]] && wget -O - $2 | $BROWSER;
    [[ $1 == "pipe"   ]] && [[ $2 ]] && { cat $2 | $BROWSER; } || { cat /dev/stdin |$BROWSER; }
    [[ $1 == "edit"   ]] && browse "source" $2 | $EDITOR 
}

serve_directory(){
    document "serve_directory" "Start a simple server here" "" && return
    python -m SimpleHTTPServer &
    dirserve_pid=$!;
}

stop_serving_directory(){ 
    document "stop_serving_directory" "Stop last simple server" "" && return
    kill $dirserve_pid; 
}
