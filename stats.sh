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

function get_music() {
    PID=$(pidof banshee)

    if [[ -z $PID ]]; then
        return 1
    fi

    DBUS=$(cat /proc/$(pidof banshee)/environ | tr '\0' '\n' | grep DBUS_SESSION_BUS_ADDRESS | cut -f2- -d'=')

    if [[ "$($DBUS banshee --query-current-state)" != "current-state: playing" ]]; then
        return 1
    fi

    export MUSIC=$($DBUS banshee --query-artist --query-album --query-title)
}

screensaver_active
if [[ $? -eq 1 ]]; then
    exit
fi

get_active_window
get_location
get_weather
get_music

if [[ $? -eq 1 ]]; then
    echo "$(date +%s) %%% $WINDOW %%% $LOCATION %%% $WEATHER"
else
    echo "$(date +%s) %%% $WINDOW %%% $LOCATION %%% $WEATHER %%% $MUSIC"
fi
