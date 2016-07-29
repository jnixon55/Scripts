#!/bin/bash
#Must specify servername as an argument without domain. ie VA1IHGDHLT42

for HOST in $1; do
sshpass -e ssh nixonje@admin_nixonje#ihgint.global@$HOST.ihgext.global@myproxy.ihgint.global;
done
