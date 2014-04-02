#!/bin/bash
DISPLAY=:0.0

function screensaver_active() {
    if [[ "$(/usr/bin/gnome-screensaver-command -q)" == "The screensaver is inactive" ]]; then
        return 0
    else
        return 1
    fi
}

function get_active_window() {
    export WINDOW=$(xdotool getwindowname $(xdotool getactivewindow))
}

function get_location() {
    export LOCATION=$(iwconfig wlan0 | grep ESSID | cut -f2 -d'"')
}

function get_weather() {
    export WEATHER=$(weather nyc | tr '\n' ' ')
}

function get_resolution() {
    export RESOLUTION=$(xrandr -d :0 | head -1 | cut -f2 -d',' | cut -f3- -d' ')
}

function get_music() {
    PID=$(pidof banshee)

    if [[ -z $PID ]]; then
        return 1
    fi

    export DBUS_SESSION_BUS_ADDRESS=$(cat /proc/$(pidof banshee)/environ | tr '\0' '\n' | grep DBUS_SESSION_BUS_ADDRESS | cut -f2- -d'=')

    if [[ "$(banshee --query-current-state)" != "current-state: playing" ]]; then
        return 1
    fi

    export MUSIC=$(banshee --query-artist --query-album --query-title | tr '\n' ' ')
}

screensaver_active
if [[ $? -eq 1 ]]; then
    exit
fi

get_active_window
get_location
get_weather
get_resolution

STR="$(date +%s) %%% $WINDOW %%% $LOCATION %%% $WEATHER %%% $RESOLUTION"

get_music
if [[ $? -eq 0 ]]; then
    STR=$STR" %%% $MUSIC"
fi

echo $STR
