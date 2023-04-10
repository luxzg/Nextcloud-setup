#   /home/administrator/suspend_until.sh

#!/bin/bash

# Auto suspend and wake-up script
#
# Puts the computer on standby and automatically wakes it up at specified time
#
# Written by Romke van der Meulen <redge.online@gmail.com>
# Minor mods fossfreedom for AskUbuntu : https://askubuntu.com/a/61717/1080682
#
# Takes a 24hour time HH:MM as its argument
# Example:
# suspend_until 9:30
# suspend_until 18:45

# ------------------------------------------------------
# Argument check
if [ $# -lt 1 ]; then
    echo "Usage: suspend_until HH:MM"
    exit
fi

# Check whether specified time today or tomorrow
DESIRED=$((`date +%s -d "$1"`))
NOW=$((`date +%s`))
if [ $DESIRED -lt $NOW ]; then
    DESIRED=$((`date +%s -d "$1"` + 24*60*60))
fi

# Set RTC wakeup time
# change "mem" for the suspend options "disk", "mem" or "off"
# find this by "man rtcwake"
rtcwake -l -m mem -t $DESIRED &

# feedback
echo "Suspending..."
