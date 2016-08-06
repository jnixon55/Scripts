Command Cheat Sheet

			###############################################
			###Display date and time in history command ###
			###############################################

--	export HISTTIMEFORMAT="%d/%m/%y %T "
--	export HISTTIMEFORMAT="%h/%d - %H:%M:%S "


			###################################################################
			### list which deleted files are still being accessed by a app  ###
			###################################################################

--	lsof / | sort -rnk 7 | more

			##############################################
			### find if service is running or restart ####
			##############################################

--	for N in pga-web-prod-{1..8}.cop.vgtf.net; do ssh $N sudo service nginx restart; done

--	for HOST in $(</home/jnixon/servers.txt ) ;do ssh -o BatchMode=yes -o ConnectTimeout=5 $HOST "uname -n;issec -b;echo -e '\n'"  2>/dev/null; done


--	for HOST in $(jlpprxpwls42.onefiserv.net) ;do ssh -o BatchMode=yes -o ConnectTimeout=5 $HOST "uname -n;df -h;echo -e '\n'"  2>/dev/null; done

			#####################################
			### Dell Service tag for esx host ###
			#####################################

--	dmidecode | grep serial

			########################
			###Device busy alert ###
			########################

-- fuser -km  <Path to dir>


			###################################
			###FINDNG RUNNING APACHE SERVERS###
			###################################

-- for A in `ls /etc/init.d/*aws`; do echo $A && $A status; done | grep not

-- for A in `ls /etc/init.d/*MS`; do echo $A && $A status; done | grep running

			##########################################################
			###command to check if ports are opened in the Network.###
			##########################################################

--	nc -vzw 3 10.224.163.145  1002 && nc -vzw 3 10.224.163.145  2001 && nc -vzw 3 10.224.163.145  3001 && nc -vzw 3 10.224.163.145  4040


			#####################
			###VMWARE COMMANDS###
			#####################

--	service vmware-vpxa restart && service mgmt-vmware restart && service vmware-webAccess restart

#	get a list of vm's
--	vim-cmd vmsvc/getallvms


			##################################
			### Finding cron for all users ###
			##################################

--	for user in $(ls /apps/home); do echo $user; crontab -u $user -l; done

--	ll /var/spool/cron/crontabs/ && grep . *


			###########################
			### Sorting large files ###
			###########################

--	sorted-du () { paste -d '#' <( du -ax "$1" ) <( du -hax "$1" ) | sort -n -k1,7 | cut -d '#' -f 2; }

		# Then run: sorted-du /
		#	You get human-readable, sorted output to find big files. substitute / for any filesytem


		##################################
		##### Verifying Key pairs   ######
		##################################

ssh-keygen -y -f <private key file>
		##################################
		### Show 10 Largest Open Files ###
		##################################


		lsof / | awk '{ if($7 > 1048576) print $7/1048576 "MB" " " $9 " " $1 }' | sort -n -u | tail


			###########################
			### find rename and zip ###
			###########################

			find /apps/apache/servers/hom/logs -type f -mtime +14 ! -name "*.gz" |
			while read fname
			do
			  newname=${fname}_`date +%F`
			  mv $fname $newname
			  gzip -v $newname
			done

			###########################
			### rename extensions   ###
			###########################

--	find . -depth -name "*.old.jpg" -exec sh -c 'mv "$1" "${1%.old.jpg}.jpg"' _ {} \;

			############################
			### History of all users ###
			############################

--	getent passwd | cut -d : -f 6 | sed 's:$:/.bash_history:' | grep -e "$pattern" /home/*/.bash_history | grep bavelar

			#####d#######################
			######## server list #######
			############################

-- curl -s "http://analyzer.turner.com/analyser/" | grep -o '<a href="[^<]*</a>' | sed 's|^<a href="||' | sed 's|"||' | sed 's|</a>||' | sed 's|.*>||' | sed 's|/||'


		###########################
		### NBA server restarts ###
		###########################

		for HOST in nbaprem{2,3,6,7}.56m.vgtf.net; do ssh $HOST 'sudo /etc/init.d/nbatksg status';done
		for HOST in nbapremcop{1,2,3,4}.cop.vgtf.net; do ssh $HOST 'sudo /etc/init.d/nbatksg status';done

		for HOST in nbaprem{4,5,8,9}.56m.vgtf.net; do ssh $HOST 'sudo /etc/init.d/nbatksg status';done
		for HOST in nbapremcop{5,6,7,8}.cop.vgtf.net; do ssh $HOST 'sudo /etc/init.d/nbatksg status';done


#Finding highest swap
		for PROCESS in /proc/*/; do
		 	swapused=$(awk 'BEGIN { total = 0 } /^Swap:[[:blank:]]*[1-9]/ { total = total + $2 } END { print total }' ${PROCESS}/smaps 2>/dev/null || echo 0)
		   	if [ $swapused -gt 0 ]; then
		     	/bin/echo -e "${swapused}k\t$(cat ${PROCESS}/cmdline)"
		   	fi
		 	done | grep opsware



cat ipaccess.20160217* > tmp.access.log
sed -n '/2016:11:30:45/, /2016:12:30:45/p' tmp.access.log | awk '{print $1, $13}' | sort -n | uniq -c | sort -n | tail


tail -1000000 tmp.access.log | awk '{print $1, $13}' | sort -n | uniq -c | sort -n | tail


# Sum size of files returned from FIND
find [path] [expression] -exec du -ab {} \; | awk '{total+=$0}END{print total}'

#Creating stanza in multipath.conf file (IHG)
cat add_luns | while read alias wwid
do
echo "multipath { "
echo -e ' \t '"uid 0"
echo -e ' \t'"gid 0"
echo -e ' \t '"wwid ${wwid}"
echo -e ' \t '"alias ${alias}"
echo -e ' \t'"mode 0600"
echo " } \n"
done > test.luns

### Animate .gif
gifview --animate --new-window root  animated.gif

#View traffic on a specified port
tcpdump -i venet0: -n -tttt port 80

# List the number connceted IPs
netstat -plan|grep :80|awk {'print $5'}|cut -d: -f 1|sort|uniq -c|sort -nk 1


# Checking the network interface status
cat /sys/class/net/eth0/operstate
cat /sys/class/net/eth0/carrier
ls /sys/class/net/

#Getting Thread count of a process
cat /proc/25643/status | grep Threads

yum downgrade chef-11.14.6-1.el5.x86_64


$ vagrant init tower http://vms.ansible.com/ansible-tower-2.4.5-virtualbox.box
$ vagrant up
$ vagrant ssh

#####################
##### Luns Scan #####
#####################

echo "- - -" > /sys/class/scsi_host/host0/scan

for HOST in $(</home/nixonje/Dropbox/Documents/Scripts/server_patch);do cat ~/.ssh/id_rsa.pub | ssh -o "StrictHostKeyChecking=no" -o "ConnectTimeout=5" $HOST 'mkdir ~/.ssh; cat >> ~/.ssh/authorized_keys'; done

####################################
### list users running processes ###
####################################

ps aux | awk '{ print $1 }' | sed '1 d' | sort | uniq

for h in `cat server_list`; do
scp /apps/appsupp/packages/BlueStripe/8.1.5/InstallBlueStripeCollector-Linux64.bin_8.1.5 nixonje@$h:/tmp;
done
