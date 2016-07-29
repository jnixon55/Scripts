#!/bin/sh

##############################################
### Uptime/Downtime API Jerome - 6/29/2016 ###
##############################################

serverlist=`ls -al ~/Dropbox/Documents/Scripts/server_list | awk '{print $5}'`
servers=`cut -f1 -d. ~/Dropbox/Documents/Scripts/server_list | awk '{print $1"*,"}'| tr -d '\n'`
hosts=${servers%?}


if [ "$serverlist" = 0 ]; then
          echo "Server List is empty!"
          exit 1
        else
          echo "Up Timing Monitors"
          #echo dash.ihg.com/api/ipsoft/hostDowntimeUptime.php?hosts=$hosts'&'action=uptime
          curl -L dash.ihg.com/api/ipsoft/hostDowntimeUptime.php?hosts=$host'&'action=uptime
fi
