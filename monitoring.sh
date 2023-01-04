#!/bin/bash

architecture=$(uname -a)
cpu=$(nproc)
vcpu=$(cat /proc/cpuinfo | grep processor | wc -l)
user_log=$(expr $(w | wc -l) - 2)

if [ $(lsblk | awk '{print $6}' | grep lvm | wc -l) -ne 0 ]
then 
	lvm='yes'
else 
	lvm='no'
fi
last_boot=$(who -b | awk '{print $3 " " $4}')

memory=$(free -m | grep Mem |awk '{print $3 "/" $4"MB"}' | tr -d \\n \
&& free -m  | grep Mem | awk '{printf " (%.2f", ( $3 / $4*100.0)}' | sed s/$/"%)"/)

disk=$(df -t ext4 --total -BM | grep total  | awk '{print $3}' | tr -d \\n  && echo -n '/' && df -t ext4 --total -BG | grep total | awk '{print $2}' | tr -d \\n && echo -n " (" && df -t ext4 --total | grep total | awk '{print $5}' | tr -d \\n && echo -n ')')

sudo=$(cat /var/log/sudo/sudo.log | grep COMMAND | wc -l | tr -d \\n && echo -n ' cmd')
tcp=$(netstat -at | grep ESTABLISHED | wc -l)
cpu_load=$(printf "%.2f%%" $(mpstat | grep all | awk '{print $3+$4+$5+$6+$7+$8+$9+$10+$11}' | tr -d \\n))
network=$(echo -n 'IP ' && hostname -i | tr -d \\n && echo -n ' (' && /usr/sbin/ifconfig -a | grep ether | awk '{print $2}'| tr -d \\n && echo -n ')')
wall \
"#Architecture: $architecture 
#CPU physical : $cpu 
#vCPU : $vcpu
#Memory Usage: $memory 
#Disk Usage: $disk
#CPU load: $cpu_load
#Last boot: $last_boot
#LVM use: $lvm
#Connexions TCP : $tcp
#User log: $user_log
#Network: $network
#Sudo : $sudo"
