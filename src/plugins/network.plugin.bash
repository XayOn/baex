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

get_channel(){
    document "get_channel" "Returns channel for a specific network on a specific interface" "IFACE ESSID" && return
    awk '/Channel/ { print $2 }' <(iwlist $wifi sc $1) 
}
get_ip(){
    document "get_ip" "If ip and gw provided, configures them, otherwise it tries to get one via dhcp" "[IP] [GW]" && return
    [[ ! $3 ]] && dhclient $1 || { ifconfig $1 $2; route add default gw $3; }; 
}

get_encryption(){ 
    document "get_encryption" "Returns encription for a specific essid" "WIFI ESSID" && return
    enc=$(awk '/Encrypt/ { print $2 }' <(iwlist $wifi sc $1))
    [[ $enc =~ (.*)WPA(.*) ]] && { echo wpa; return; }
    [[ $enc =~ (.*)WEP(.*) ]] && { echo wep; return; }
    echo opn
}

wireless_menu(){
    declare -a wireless_nets ndata;
    wireless_nets=($( awk '/essid/ {print $2}' <(iwlist sc)))
    for network in ${wireless_nets[@]}; do ndata+="-o $network -f cnetwork=$network"; done
    mkmenu -t "Network selection" ${ndata[@]};
    read -p "Enter password (empty for none or previosly entered ones)" pass
    read -p "Enter ip (empty for autoconf)" ip
    read -p "Enter gateway (empty for autoconf)" gateway
    configure_net $1 $cnetwork $pass $ip $gateway
}

configure_net(){ 
    document "configure_net" "Configure network, autodetecting encription" "INTERFACE NETWORK [ASCII_PASSWORD] [IP] [GATEWAY]" && return
    configure_$(get_encryption $2 ) ${@}; 
}

configure_wpa(){
    document "configure_wpa" "Configure a wpa connection" "INTERFACE NETWORK [ASCII_PASSWORD] [IP] [GATEWAY]" && return 
    wifi=$1; essid=$2; password=$3; ip=$4; gateway=$5;
    [[ -e ~/.jabashit/networks ]] &&  { pass=$(cat ~/.jabashit/networks/wpa/$essid); }
    [[ $pass == "" ]] && [[ $password != "" ]] && pass=$password || exit;
    wpa_passphrase $essid $password > ~/.jabashit/networks/wpa/$essid
    wpa_supplicant -i$wifi -c~/.jabashit/networks/wpa/$essid -B && get_ip $ip $gateway
}

configure_opn(){
    document "configure_opn" "Configure a opn connection" "INTERFACE NETWORK [ASCII_PASSWORD] [IP] [GATEWAY]" && return 
    wifi=$1; essid=$2; ip=$3; gateway=$4;
    iwconfig $wifi essid $essid channel $(get_channel $essid); get_ip $wifi $ip $gateway;
}

configure_wep(){
    document "configure_wep" "Configure a wep connection" "INTERFACE NETWORK [ASCII_PASSWORD] [IP] [GATEWAY]" && return 
    wifi=$1; essid=$2; password=$3; ip=$4; gateway=$5;
    [[ -e ~/.jabashit/networks/wep ]] &&  { pass=$(grep $essid ~/.jabashit/networks/wep); }
    [[ $pass == "" ]] && { pass=$password; echo $essid $password >> ~/.jabashit/networks/wep; channel=$(get_channel $wifi $essid)
    iwconfig $wifi essid $essid key s:$pass channel $channel
    get_ip $wifi $ip $gateway
}
