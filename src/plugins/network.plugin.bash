#!/bin/bash
document_description "Networking tools, manage your networking interfaces"

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
    awk '/Channel/ { print $2 }' <(iwlist $1 sc essid $2) 
}
get_ip(){
    document "get_ip" "If ip and gw provided, configures them, otherwise it tries to get one via dhcp" "[IP] [GW]" && return
    [[ ! $3 ]] && dhclient $1 || { ifconfig $1 $2; route add default gw $3; }; 
}

get_encryption(){ 
    document "get_encryption" "Returns encription for a specific essid" "WIFI ESSID" && return 
    a=$(iwlist $1 scanning | awk -F '[ :=]+' '/(ESS|WPA)/{ printf $3" " } /Encr/{ print $4 }'|command grep $2)
    echo $a > foo 
    awk '/IEEE/ { print}' <<< $a >> foo 
    
    [[ "$(awk '/IEEE/ { print}' <<< $a )" =~ (.*)WPA(.*) ]] && { echo wpa; return; }
    [[ "$(awk '/IEEE/ { print}' <<< $a )" =~ (.*)IEEE(.*) ]] && { echo wpa; return; }
    [[ "$(awk '/off/ { print $2 }' <<< $a )" =~ (.*)off(.*)  ]] && { echo "opn"; return; }
    echo "wep"
}




set_network(){ export cnetwork=$1; }

wireless_menu(){
    declare -a wireless_nets ndata;
    wireless_nets=($(awk '/ESSID:(.*)/ {a=$1; a=sub(/ESSID:/,""); a=sub(/"/, ""); a=sub(/"/, ""); print $a }' <(iwlist sc 2>/dev/null)))
    for network in ${wireless_nets[@]}; do ndata+=" -o $network -f $network"; done 
    mkmenu -s cnetwork -t Networks_available $(echo -ne ${ndata[@]});
    read -p "Enter password (empty for none or previosly entered ones): " pass
    read -p "Enter ip (empty for autoconf): " ip
    read -p "Enter gateway (empty for autoconf): " gateway
    configure_net $1 $cnetwork $pass $ip $gateway
}

configure_net(){ 
    document "configure_net" "Configure network, autodetecting encription" "INTERFACE NETWORK [ASCII_PASSWORD] [IP] [GATEWAY]" && return 
    encription_=$(get_encryption $1 $2)
    echo "Configuring $1 for network $2 with enc $encription_"
    configure_$encription_ ${@}; 
}

configure_wpa(){
    document "configure_wpa" "Configure a wpa connection" "INTERFACE NETWORK [ASCII_PASSWORD] [IP] [GATEWAY]" && return 
    mkdir -p ~/.jabashit/networks/wpa/ &>/dev/null; 
    wifi=$1; essid=$2; password=$3; ip=$4; gateway=$5;
    [[ -e ~/.jabashit/networks/wpa/$essid ]] || {
        [[ $pass == "" ]] && [[ $password != "" ]] && pass=$password || return;
        wpa_passphrase $essid $password > ~/.jabashit/networks/wpa/$essid 
        echo "Created passphrase file in ~/.jabashit/networks/wpa/$essid";
    }

    wpa_supplicant -i$wifi -c $HOME/.jabashit/networks/wpa/$essid -B && get_ip $wifi $ip $gateway
}

configure_opn(){
    document "configure_opn" "Configure a opn connection" "INTERFACE NETWORK [ASCII_PASSWORD] [IP] [GATEWAY]" && return 
    wifi=$1; essid=$2; ip=$3; gateway=$4;
    iwconfig $wifi essid $essid channel $(get_channel $wifi $essid); get_ip $wifi $ip $gateway;
}

configure_wep(){
    document "configure_wep" "Configure a wep connection" "INTERFACE NETWORK [ASCII_PASSWORD] [IP] [GATEWAY]" && return 
    mkdir -p ~/.jabashit/networks/wep/ &>/dev/null; 
    wifi=$1; essid=$2; password=$3; ip=$4; gateway=$5;
    [[ -e ~/.jabashit/networks/wep/$essid ]] &&  { pass=$(cat ~/.jabashit/networks/wep/$essid); }
    [[ $pass == "" ]] && { pass=$password; echo $password > ~/.jabashit/networks/wep/$essid; }
    iwconfig $wifi essid $essid key s:$pass channel $(get_channel $wifi $essid); get_ip $wifi $ip $gateway
}
