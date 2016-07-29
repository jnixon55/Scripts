#!/bin/sh
#set -x
#Simple script to check if a process is running on remote host -  jnixon 8/17/2015

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
YELLOW='\033[0;33m'

echo  "${GREEN}#######################################"
echo  "${GREEN}#######     CHECK PROCESSES     #######"
echo  "${GREEN}#######################################\n"

printf "${YELLOW}Please Enter the Server Name or IP Address:${NC}\n "

read ServerName

echo

printf "${YELLOW}Enter Process Name:${NC}\n "


read PROC



SIZE=$(ssh -o BatchMode=yes -o ConnectTimeout=5 $ServerName ps cax)

echo

echo "$SIZE" |grep -q $PROC && echo "${GREEN}Process is running"  && exit 0
echo
echo "$SIZE" |grep -q $PROC || echo "${RED}Process is not Running!!" && exit 1
echo
## && is "and" meaning success and || is or, meaning failure.

#test ip 10.60.33.173
