#!/bin/bash

<<COMMENT
Automation of KB 208808
For VxRail versions 7.0.350+ and 8.0+
root access is required
echo "" > KB208808.sh ; vim KB208808.sh ; bash KB208808.sh
COMMENT

clear

# Script version, init data:
script_version="2.40.118.1"
disp_date=$(date)
dump_file_path="/home/mystic/node_node.dump"

# Define colors:
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
NC='\033[0m' # No Color

# get current script name without extension
script_name=$(basename "$0")
script_name_without_extension="${script_name%.*}"
run_in_directory=$(pwd)

enable_logging() {
  # set up logging to file
  exec 3>&1 4>&2
  trap 'exec 2>&4 1>&3' 0 1 2 3
  exec > >(tee -a >(while read -r line; do echo -e "$(date +"%Y-%m-%dT%H:%M:%S%z"): ${line}"; done >> "${script_name_without_extension}.log")) 2>&1
}

disable_logging () {
  exec 1>&3 2>&4
}

pre_exit () {
  echo -e ""
  echo -e "Log file: ${script_name_without_extension}.log"
  echo -e "Done!"
  disable_logging
  echo -e ""
}
wait_n_seconds () {
  local seconds="$1"
  local countdown="$seconds"

  disable_logging
  while [ "$countdown" -gt 0 ]; do
      echo -n "Waiting for $countdown seconds..."
      sleep 1
      countdown=$((countdown - 1))
      echo -ne "\r"
  done
  echo -e ""
  enable_logging
}

rcs-restart () {
  if [ $usekubectl -eq 1 ]; then
    echo -e "...via kubectl..."
    kubectl delete pod $(kubectl get pods -o=name | grep rcs | sed "s/^.\{4\}//") 1>/dev/null &
    sleep 4
    echo -e "Waiting 40 seconds to stabilize..."
    wait_n_seconds 40
  else
    echo -e "...via docker..."
    docker service update func_rcs-service
    echo -e "Waiting 40 seconds to stabilize..."
    wait_n_seconds 40
  fi
}


# Define banner:
echo -e $CYAN"
#=======================================================================#
| Copyright (C) 2024 - All Rights Reserved, by Dell, Cork, Ireland.     |
|                                                                       |
| This software is furnished under a license and may be used and copied |
| only  in  accordance  with  the  terms  of such  license and with the |
| inclusion of the above copyright notice. This software or  any  other |
| copies thereof may not be provided or otherwise made available to any |
| other person. No title to and ownership of  the  software  is  hereby |
| transferred.                                                          |
|                                                                       |
| The information in this software is subject to change without  notice |
| and  should  not be  construed  as  a commitment by Dell.             |
|                                                                       |
| Dell  assumes  no  responsibility for the  use or  reliability of its |
| software on  equipment  which  is  not  supplied by Dell.             |
|                                                                       |"
printf "|%-70s |\n" " Execution time: $disp_date"
printf "|%-70s |"   " Script version: $script_version"

enable_logging

echo -e "
#=======================================================================#"

echo -e "\r\nAutomation of KB208808"$NC
echo -e "Running ${script_name} in ${run_in_directory}"
echo -e $RED
read -p "The use of this script has been authorized by VxRail Engineering and the customer has provided their consent: (Y/N) " -n 1 -r
echo -e $NC
if [[ ! $REPLY =~ ^[Yy]$ ]] ; then
  echo -e "Exiting...(code: 1)(no consent given)(reply:"$REPLY")"
  pre_exit
  exit 1
fi

echo -e ""
# check if root user:
if [[ ${EUID} -ne 0 ]]; then
  echo -e $RED"This script requires root access!"
  echo -e "Exiting...(code: 2)(root access required)"$NC
  pre_exit
  exit 2
fi

supportedversion=0
version=$(rpm -qa | grep -i marvin | awk -v FS="-" '{print $3}')
major=$(echo -e $version | awk -F "." '{print $1}')
minor=$(echo -e $version | awk -F "." '{print $2}')
build=$(echo -e $version | awk -F "." '{print $3}')
if [ $major -eq "7" ] && [ $minor -eq "0" ] && [ $build -ge "350" ]; then supportedversion=1; fi
if [ $major -eq "8" ]; then supportedversion=1; fi

if [ "$supportedversion" -ne "1" ]; then
  echo -e $RED"This script requires VxRail version 7.0.350+ or 8.0.000+"$NC
  echo -e $RED"Exiting...(code: 4)(version not supported:"$version")"$NC
  pre_exit
  exit 4
fi

echo -e "Found supported VxRail version: $version"

tmp=$(which kubectl)

if [ $? -eq 0 ]; then
  echo -e "Script will use kubectl..."
  usekubectl=1
  ignore=$(kubectl get pods -o wide)
  if [ $? -ne 0 ]; then
    echo -e $RED"kubectl issue found, please check if kubectl is working ok!"
    echo -e "Exiting...(code: 3)(kubectl issue found)"$NC
    pre_exit
    exit 3
  fi
else
  echo -e "Script will use docker..."
  usekubectl=0
fi

echo -e ""
echo -e "Checking if KB is in progress (searching for TMP in nodes.nodes)..."
TMPfound=$(psql -U postgres -d vxrail -tc "select * from node.node where type='TMP';")

skip_dump=0
if [ -z "$TMPfound" ]; then
  echo -e "No TMP nodes found! Continuing..."
  echo -e "Checking if dump exists..."

  if [ -f "$dump_file_path" ]; then
    echo -e ""
    echo -e "Dump exists from possible previous run"
    echo -e "Exiting...(code: 5)(dump exists)"
    pre_exit
    exit 5
  fi
else
  echo -e $RED"TMP nodes found:\r\n$TMPfound"
  echo -e "Process will skip table node.node dump!"$NC
  skip_dump=1
fi

echo -e ""
# check if UK found on any node in cluster
echo -e "Checking if UK is found on any node in cluster..."
found=0
for checkUK in $(curl -s --unix-socket /var/lib/vxrail/nginx/socket/nginx.sock -H "Content-Type: application/json" http://127.0.0.1/rest/vxm/internal/do/v1/host/query -d '{"query": "{ configuredHosts { name runtime { iDracAppRawData { eseKey } }} }" }' | jq | grep "eseKey" | awk -F: '{print $2}'); do
  if [[ "$checkUK" == "null" || -z "$checkUK" ]]; then
    found=$found
  else
    found=1
  fi
done

if [ $found -eq 0 ]; then
  if [ $skip_dump -eq 1 ]; then
    echo -e "No UK found and TMP nodes found!"
    echo -e "Trying to continue previous run..."
  else
    echo -e "No UK is found on any node in cluster!"
    echo -e "No need to run workaround. Please retry enable call home operation!"
    echo -e "Exiting...(code: 7)(no UK found in cluster)"
    pre_exit
    exit 7
  fi
else
  echo -e "UK found in cluster!"
fi

echo -e ""
echo -e "Getting primary node..."
primnode=$(psql -U postgres -d vxrail -tc "select sn from node.node where is_primary='t';" | sed 's/ //g')
count_primnode=$(echo -e $primnode | wc -w)
echo -e "Primary node found: $primnode"

if [ -z "$primnode" ]; then
  echo -e "Primary node not found!"
  echo -e "Exiting...(code: 30)(No primary node found)"
  pre_exit
  exit 30
fi

if [ $count_primnode -gt 1 ]; then
  echo -e "More than one primary node found!"
  echo -e "Exiting...(code: 31)(more than one primary node found)"
  pre_exit
  exit 31
fi

if [ $skip_dump -eq 0 ]; then
  echo -e ""
  echo -e "Dumping database, table node.node..."
  pg_dump -U postgres -d vxrail -t node.node > $dump_file_path
fi

echo -e ""
echo -e "Checking if UK exists on primary node..."
json_string='{"query": "{configuredHosts(sn: \"'"$primnode"'\") {name runtime {iDracAppRawData {eseKey}}}}"}'
prim_uk=$(curl -s --unix-socket /var/lib/vxrail/nginx/socket/nginx.sock -H "Content-Type: application/json" http://127.0.0.1/rest/vxm/internal/do/v1/host/query -d "$json_string" | jq  -r .data.configuredHosts[0].runtime.iDracAppRawData.eseKey)

if [[ "$prim_uk" == "null" || -z "$prim_uk" ]]; then
  echo -e $CYAN"No UK on primary node $primnode."$NC
else
  echo -e "Removing UK from primary node..."
  json_string='{"sn": "'"$primnode"'"}'
  taskrez=$(curl -sk -X DELETE --unix-socket /var/lib/vxrail/nginx/socket/nginx.sock -d "$json_string" http://127.0.0.1/rest/vxm/internal/do/v1/host/idrac/apprawdata/esekey -H "Content-Type: application/json")
  taskid=$(echo -e $taskrez | grep -o "........-....-....-....-............")

  echo -e "\r\nWaiting 5 seconds for UK removal to finish..."
  wait_n_seconds 5
  grep -ao "$taskid.*" /var/log/microservice_log/short.term.log

  echo -e "Checking if UK from primary node is removed..."
  json_string='{"query": "{configuredHosts(sn: \"'"$primnode"'\") {name runtime {iDracAppRawData {eseKey}}}}"}'
  prim_uk=$(curl -s --unix-socket /var/lib/vxrail/nginx/socket/nginx.sock -H "Content-Type: application/json" http://127.0.0.1/rest/vxm/internal/do/v1/host/query -d "$json_string" | jq  -r .data.configuredHosts[0].runtime.iDracAppRawData.eseKey)

  if [[ "$prim_uk" == "null" || -z "$prim_uk" ]]; then
    echo -e $CYAN"UK removed from primary node $primnode."$NC
  else
    echo -e $RED"Failed to remove UK from primary node $primnode."$NC
    echo -e $RED"Exiting...(code: 6)"$NC
    pre_exit
    exit 6
  fi

fi

if [ -z "$TMPfound" ]; then
  echo -e ""
  echo -e "Modifying database so enable call home will use Access Key PIN pair..."
  ignore=$(psql -U postgres -d vxrail -tc "ALTER TABLE node.node DROP CONSTRAINT node_type_check;")
  ignore=$(psql -U postgres -d vxrail -tc "ALTER TABLE node.node ADD CONSTRAINT node_type_check CHECK (type IN ('CLUSTER', 'SATELLITE', 'WITNESS','TMP'));")
  ignore=$(psql -U postgres -d vxrail -tc "Update node.node set type='TMP' where type='CLUSTER' and is_primary='f';")
else
  echo -e ""
  echo -e "Table node.node already modified..."
fi

echo -e ""
echo -e "Restarting Remote Connectivity Service..."
rcs-restart

echo -e ""
echo -e $RED"Please use the UI to enable call home...\r\nEnter 'continue' ${YELLOW}AFTER${RED} enable call home in GUI has finished, to continue applying workaround: "$NC
echo -e ""
while true; do
  read input
  if [[ $input == "continue" ]]; then
    break
  else
    echo -e "'$input' was entered... Please enter 'continue' to continue..."
  fi
done

echo -e ""$NC
echo -e "Restoring database..."
ignore=$(psql -U postgres -h localhost -d vxrail -c "DROP TABLE node.node;")
ignore=$(psql -U postgres -d vxrail < /home/mystic/node_node.dump)

echo -e ""
echo -e "Restarting Remote Connectivity Service..."
rcs-restart

echo -e ""
echo -e "Cleaning up..."
mv $dump_file_path ${dump_file_path}_$(date +%Y%m%d%H%M%S)
pre_exit

# The End
exit 0
# End
