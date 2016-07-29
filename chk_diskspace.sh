#!/bin/sh
#set -x
#Simple script to check disk space on remote host -  jnixon 8/17/2015

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
YELLOW='\033[0;33m'

echo  "${GREEN}#######################################"
echo  "${GREEN}#######    CHECK DISK SPACE     #######"
echo  "${GREEN}#######################################\n"

printf "${YELLOW}Please Enter the Server Name or IP Address:${NC}\n "

read ServerName

for HOST in "$ServerName"

	do

SIZE=$(ssh -o BatchMode=yes -o ConnectTimeout=5 $HOST "uname -n;df -h .;echo -e " | grep -v '^Filesystem' | awk 'NF=6{print $5}NF==5{print $3}{}' | sed 's/%//g')

SIZE2=$(echo "$SIZE" | tr '\n' '\000')

	done

	if [ $SIZE -ge 75 ]; then

  		printf "${RED}Partition Size on / Is Above Threshold: ${YELLOW}$SIZE2%%\n"

		exit 1

	else

			printf "${GREEN}DISK IS BELOW THRESHOLD: ${YELLOW}${SIZE2}%%\n"
echo
		exit 0
	fi

#echo "This is a test $ServerName"
#test ip 10.60.33.173
