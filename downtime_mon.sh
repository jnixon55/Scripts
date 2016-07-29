#!/bin/bash


########################################
### Downtime API Jerome - 6/29/2016  ###
########################################

serverlist=`ls -al ~/Dropbox/Documents/Scripts/server_list | awk '{print $5}'`
servers=`cut -f1 -d. ~/Dropbox/Documents/Scripts/server_list | awk '{print $1"*,"}'| tr -d '\n'`
hosts=${servers%?}


if [ $serverlist = 0 ]; then
          echo "List is empty!"
          exit 1
        elif [ ! "$1" ]; then
          echo "Please specify duration. ie: downtime_mon.sh 10"
        else
          echo "Downtiming Monitors for $1 mins..."
          #echo dash.ihg.com/api/ipsoft/hostDowntimeUptime.php?hosts=$hosts'&'action=downtime'&'duration=$1
          curl -L dash.ihg.com/api/ipsoft/hostDowntimeUptime.php?hosts=$hosts'&'action=downtime'&'duration=$1
fi
