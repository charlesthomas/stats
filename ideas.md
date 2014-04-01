Ideas
=====

Is the screensaver active?
--------------------------

    /usr/bin/gnome-screensaver-command -q


What was I actually working on?
-------------------------------

    xdotool getwindowname $(xdotool getactivewindow)


Can I find out what the weather was like at the time?
-----------------------------------------------------


What music was I listening to at the time?
------------------------------------------
This is much more complicated than I remembered, but I figured it out with
``banshee``.

### Command

    banshee --query-artist --query-album --query-title

### Problem 1

This opens a *new* ``banshee`` instance. We want to run the against the
*current* instance.

### Stealing Some Old Code

Luckily for me, I solved this problem once before; I wrote a script that would
automatically pause ``banshee`` when I locked my screen, called
[music_pauser](https://bitbucket.org/charlesthomas/music_pauser).

### Solution: DBUS_SESSION_BUS_ADDRESS

By exporting this value correctly, the ``banshee`` commands will operate on the
correct instance. Here's how to find the correct value:

1. Find the process ID of the current ``banshee`` instance:

    pidof banshee

1. Find the environment variables that process is using:

    cat /proc/$(pidof banshee)/environ

1. Pull out the value of the DBUS_SESSION_BUS_ADDRESS variable:

    cat /proc/$(pidof banshee)/environ | tr '\0' '\n' | grep DBUS_SESSION_BUS_ADDRESS | cut -f2- -d'='

### All Together

    DBUS_SESSION_BUS_ADDRESS=$(cat /proc/$(pidof banshee)/environ | tr '\0' '\n'
    | grep DBUS_SESSION_BUS_ADDRESS | cut -f2- -d'=') banshee --query-artist
    --query-album --query-title

### Problem 2

``banshee`` will return data for the above command after it has stopped playing

### Solution: ``banshee --query-current-state``

This will return "current-state: playing" if ``banshee`` is actually playing
music.

    DBUS_SESSION_BUS_ADDRESS=$(cat /proc/$(pidof banshee)/environ | tr '\0' '\n'
    | grep DBUS_SESSION_BUS_ADDRESS | cut -f2- -d'='); if [[ "$(banshee
    --query-current-state)" == "current-state: playing" ]]; then banshee
    --query-artist --query-album --query-title; fi

***THIS DOESN'T ACTUALLY WORK*** ``bash`` doesn't like this syntax. I think not
exporting the variable is throwing off the ``if``.

### Problem 3

Actually using either of the above while ``banshee`` is not running (as opposed
to not playing), will launch a ``banshee`` instance.

### Solution: Break this out of a single line, check ``pidof banshee`` first,
and stop execution if it's null.
