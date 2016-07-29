#!bin/sh

# PID = Process ID
# STIME = start time of the process
# ETIME = elapsed time of the process
# SERVICE = Name of service
# 0 = OK
# 1 = WARNING
# 2 = CRITICAL
# 3 = UNKNOWN

SERVICE=apache2
PID=$(ps -ef | grep $SERVICE | head -1 | awk '{print $2}')
STIME=$(ps -eo pid,stime,etime | grep $PID | awk '{print $2}')
ETIME=$(ps -eo pid,stime,etime | grep $PID | awk '{print $3}')



if ps ax | grep -v grep | grep $PID > /dev/null

        then
        	echo "$SERVICE started at $STIME"
			STATUS=$(exit 0)	
	else

		echo "$SERVICE is not running"
		STATUS=$(exit 2)
fi		
		echo $STATUS
		exit $STATUS 

 
	 
	
