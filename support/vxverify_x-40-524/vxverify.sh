#!/bin/bash
# Define global variables:
script_version="4.0.5a"
disp_date=$(date)
runtime_user=$(whoami)

# Check if running on VxRail system, exit if not:
vxr_rpm=$(rpm -qa | grep marv | grep marvin)
if [[ -z $vxr_rpm ]]; then
  echo -e "$RED" "VxRail system not detected via RPM check!" $NC
  exit 1
fi

# Get latest vxverify_2 and vxverify_3 from current directory
# Using "ls -v" --> natural sort of (version) numbers within text
vxv2_vers=$(ls -v vxverify_2*.pyc 2>/dev/null)
vxv2_ltst=$(echo $vxv2_vers | awk '{print $NF}')

vxv3_vers=$(ls -v vxverify_3*.pyc 2>/dev/null)
vxv3_ltst=$(echo $vxv3_vers | awk '{print $NF}')
# echo "Lastest vxverify3: " $vxv3_ltst # debug print

vxv4_vers=$(ls -v vxverify_4*.pyc 2>/dev/null)
vxv4_ltst=$(echo $vxv4_vers | awk '{print $NF}')

#if [[ -z $vxv2_ltst ]] && [[ -z $vxv3_ltst ]]; then
#  echo -e $RED "No runnable VxVerify executable found!" $NC
#  exit 1
#fi

# Detect VxRail version and choose optimal VxVerify executable:
vx_ver=$(rpm -qa | grep -i marvin | awk -v FS="-" '{print $3}')
vx_v1=$(echo $vx_ver | awk -F. '{print $1}')
vx_v2=$(echo $vx_ver | awk -F. '{print $2}')
vx_v3=$(echo $vx_ver | awk -F. '{print $3}')
echo "VxRail version: " $vx_v1 "." $vx_v2 "." $vx_v3  # debug print

if [[ $vx_ver == 4.0* ]]; then
  echo -e $RED "VxRail 4.0.x version is no longer supported, exiting. VxVerify 1 required" $NC
  exit 1
elif [[ $vx_ver == 4.5* ]] || [[ $vx_ver == 4.7* ]] || [[ $vx_ver == 7.0.000 ]]; then
  echo "VxRail 4.x version detected & Python 2.7 -> VxVerify2"
  if [[ -z $vxv2_ltst ]]; then
    echo -e $RED "No valid VxVerify2 executable found for current VxRail system!" $NC
    exit 1
  else
    vxv_py="python2 $vxv2_ltst"
    echo "Using:" vxv_py
    echo "VxRail 4.5 and 4.7 software releases reached End of Service Life in 2022."
    echo "Please ensure that you are updating to 7.x code or 8.x code."
  fi
elif [[ $vx_v1 -eq 7 ]]; then  # VxRail 7.x
  if [[ $vx_v3 -lt 520 ]]; then
    echo "VxRail $vx_ver version detected & Python 3.6 -> VxVerify3"
    if [[ -z $vxv3_ltst ]]; then
      echo -e $RED "No valid VxVerify3 executable found for current VxRail system!" $NC
      exit 1
    else
      vxv_py="python3.6 $vxv3_ltst"
      echo "Using " $vxv_py
    fi
  else
    echo "VxRail $vx_ver version detected & Python 3.11 -> VxVerify4"
    if [[ -z $vxv4_ltst ]]; then
      echo -e $RED "No valid VxVerify4 executable found for current VxRail system!" $NC
      exit 1
    else
      vxv_py="python3.11 $vxv4_ltst"
      echo "Using " $vxv_py
    fi
  fi
elif [[ $vx_v1 -eq 8 ]]; then  # VxRail 8.x
  if [[ $vx_v3 -lt 210 ]]; then
    echo "VxRail $vx_ver version detected & Python 3.6 -> VxVerify3"
    if [[ -z $vxv3_ltst ]]; then
      echo -e $RED "No valid VxVerify3 executable found for current VxRail system!" $NC
      exit 1
    else
      vxv_py="python3.6 $vxv3_ltst"
      echo "Using " $vxv_py
    fi
  else
    echo "VxRail $vx_ver version detected & Python 3.11 -> VxVerify4"
    if [[ -z $vxv4_ltst ]]; then
      echo -e $RED "No valid VxVerify4 executable found for current VxRail system!" $NC
      exit 1
    else
      vxv_py="python3.11 $vxv4_ltst"
      echo "Using " $vxv_py
    fi
  fi

else  # Unrecognized VxRail version
  echo -e $RED "Unrecognized VxRail version detected: " $vx_ver $NC
  exit 1
fi

# Define banner:
echo "
#=======================================================================#
| Copyright (C) 2023 - All Rights Reserved, by Dell, Cork, Ireland.     |
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
|                                                                       |
| Note: Core profiles are intended for use by Dell teams following      |
| procedures including other tools, so fewer health-checks are needed.  |
|                                                                       |"
printf "|%-70s |\n" " Execution time: $disp_date"
printf "|%-70s |" " Script version: $script_version"
echo "
| Only one of each VxVerify 2, 3 & 4 pyc should be present in this      |
| directory, or the wrong version may be run by this script.            |
#=======================================================================#"

if [ "$runtime_user" != "root" ]; then
  echo -e $CYAN "Not running as root will prevent some tests from being run." $NC
fi
echo
echo "#==================================================#"
echo "|         VxVerify Menu Driven launcher            |"
echo "#==================================================#"
#echo
PS3='Please enter your choice: '
options=("Upgrade healthcheck"
  "Core upgrade healthcheck"
  "General healthcheck"
  "Core post-upgrade check"
  "Unused5"
  "Write VxStat UUID file"
  "Help" "Quit")
select opt in "${options[@]}"; do
  case $opt in
  "Upgrade healthcheck")
    echo "Upgrade healthcheck selected."
    read -p "Enter target version: " targetver
    echo "Enter 'None' for user or password if these are unknown, but some tests will not be able to run."

    $vxv_py -i -g "$targetver" "$@"
    break
    ;;

  "Core upgrade healthcheck")
    echo "Core upgrade healthcheck selected."
    read -p "Enter target version: " targetver
    echo "Enter 'None' for user or password if these are unknown, but some tests will not be able to run."

    $vxv_py -i -c "$targetver" "$@"
    grep 'VIB:' vxtii.txt
    break
    ;;

  "General healthcheck")
    echo "Running general VxRail health tests (test profile 5)..."
    echo "Enter 'None' for user or password if these are unknown, but some tests will not be able to run."

    $vxv_py -i -n 5 "$@"
    break
    ;;

  "Core post-upgrade check")
    echo "Core post-upgrade healthcheck selected, running VxVerify with Profile 8 option."
    echo "Enter 'None' for user or password if these are unknown, but some tests will not be able to run."

    $vxv_py -i -n 8 "$@"
    grep 'VIB:' vxtii.txt
    break
    ;;

  "Write VxStat UUID file")
    echo "Creating file to cross reference VM names with UUID, for use with VxStat: stats_uuid_~.json"
    $vxv_py -m -x 22 "$@"
    break
    ;;

  "Help")
    echo "Help text for VxVerify."
    echo "Note that username, password and test profile options are handled by vxverify.sh, rather than added arguments"
    echo "Other arguments, such as -d or -s can be added to the command line and are passed directly to VxVerify. E.g. ./vxverify.sh -d"
    $vxv_py -h
    break
    ;;

  "Quit")
    break
    ;;
  *) echo "invalid option $REPLY" ;;
  esac
done
