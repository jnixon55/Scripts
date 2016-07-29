#!/bin/bash


#awk '$2 = tolower($2)' /home/nixonje/Dropbox/Documents/Scripts/add_luns > /home/nixonje/Dropbox/Documents/Scripts/output.txt
tr '[:upper:]' '[:lower:]' < /home/nixonje/Dropbox/Documents/Scripts/add_luns > /home/nixonje/Dropbox/Documents/Scripts/output.txt
#Creating stanza in multipath.conf file (IHG)
cat /home/nixonje/Dropbox/Documents/Scripts/output.txt | while read alias wwid size
do
echo -e ' \t  ' "multipath { "
echo -e ' \t            '"#mpatht (${wwid}) VRAID size=${size}G"
echo -e ' \t            '"uid 0"
echo -e ' \t            '"gid 0"
echo -e ' \t            '"wwid \"${wwid}\""
echo -e ' \t            '"alias asm_${alias}"
echo -e ' \t            '"mode 0600"
echo -e ' \t  '" } \n"
done > /home/nixonje/Dropbox/Documents/Scripts/multipath.new
