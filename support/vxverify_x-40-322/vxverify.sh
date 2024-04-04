#!/bin/bash
# Define global variables:
script_version="4.0.2"
disp_date=$(date)
runtime_user=$(whoami)

# Define colors
RED="\e[31m"
GREEN="\e[32m"
CYAN="\e[36m"
NC='\033[0m' # No Color

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

if [[ -z $vxv2_ltst ]] && [[ -z $vxv3_ltst ]]; then
  echo -e $RED "No runnable VxVerify executable found!" $NC
  exit 1
fi

# Detect VxRail version and choose optimal VxVerify executable:
vx_ver=$(rpm -qa | grep -i marvin | awk -v FS="-" '{print $3}')
if [[ $vx_ver == 4.0* ]]; then
  echo -e $RED "VxRail 4.0.x version is no longer supported, exiting. VxVerify 1 required" $NC
  exit 1
elif [[ $vx_ver == 7.0.000 ]]; then
  echo "VxRail 7.0.000 version detected, which is not supported by this menu. Run python vxverify2.pyc"
  exit 1
# elif [[ $vx_ver == 4.5* ]]
elif [[ $vx_ver == 4.5* ]] || [[ $vx_ver == 4.7* ]]; then
  echo "VxRail 4.x version detected & Python 2.7"
  if [[ -z $vxv2_ltst ]]; then
    echo -e $RED "No valid VxVerify executable found for current VxRail system!" $NC
    exit 1
  else
    vxv_exe=$vxv2_ltst
    vxv_py="python2 $vxv2_ltst -i"
    echo "Using " vxv_py
  fi
elif [[ $vx_ver == 7.0* ]] || [[ $vx_ver == 8.0.0* ]] || [[ $vx_ver == 8.0.1* ]] || [[ $vx_ver == 8.0.20* ]]; then
  echo "VxRail $vx_ver version detected & Python 3.6"
  if [[ -z $vxv3_ltst ]]; then
    echo -e $RED "No valid VxVerify executable found for current VxRail system!" $NC
    exit 1
  else
    vxv_exe=$vxv3_ltst
    vxv_py="python3.6 $vxv3_ltst -i"
    echo "Using " $vxv_py
  fi
elif [[ $vx_ver == 8.0.* ]]; then
  echo "VxRail $vx_ver version detected & Python 3.11"
  if [[ -z $vxv3_ltst ]]; then
    echo -e $RED "No valid VxVerify executable found for current VxRail system!" $NC
    exit 1
  else
    vxv_exe=$vxv3_ltst
    vxv_py="python3.11 $vxv4_ltst -i"
    echo "Using " $vxv_py
  fi
else
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
|  procedures including other tools, so fewer health-checks are needed. |
|                                                                       |"
printf "|%-70s |\n" " Execution time: $disp_date"
printf "|%-70s |" " Script version: $script_version"
echo "
| Only one VxVerify pyc should be present in this directory             |
| or the wrong one may be run                                           |
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
  "Unused5" "Unused6" "Unused7" "Quit")
select opt in "${options[@]}"; do
  case $opt in
  "Upgrade healthcheck")
    echo "Upgrade healthcheck selected."
    read -p "Enter target version: " targetver

    # Ask for VC admin credentials:
    read -p "Enter VC SSO credentials? (Y/N)" -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo
      read -p "VC SSO user [default: administrator@vsphere.local]: " vcusr # if NULL use "root" as default value
      if [[ -z "$vcusr" ]]; then
        vcusr="administrator@vsphere.local"
      fi
      echo "Enter VC SSO password:"
      read -s vcpass
    else
      echo
      echo "Running VxVerify without VC SSO credentials..."
    fi

    # Ask for VC root credentials:
    read -p "Run recommended option with VC root credentials? (Y/N)" -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo
      read -p "VC root user [default: root]: " rootusr # if NULL use "root" as default value
      if [[ -z "$rootusr" ]]; then
        rootusr=root
      fi
      echo "Enter VC root password:"
      read -s rootpass
    else
      echo
      echo "Running VxVerify without VC root credentials..."
    fi

    if [ -n "$vcusr" ] && [ -n "$rootusr" ]; then
      echo "VC SSO user AND VC root user present."
      $vxv_py -g "$targetver" -r "$rootusr" -w "$rootpass" -u "$vcusr" -p "$vcpass" "$@"
    fi
    if [ -z "$vcusr" ] && [ -n "$rootusr" ]; then
      echo "VC SSO user NOT present, but VC root user present."
      $vxv_py -g "$targetver" -r "$rootusr" -w "$rootpass" "$@"
    fi
    if [ -n "$vcusr" ] && [ -z "$rootusr" ]; then
      echo "VC SSO user present, but VC root user NOT present."
      $vxv_py -g "$targetver" -u "$vcusr" -p "$vcpass" "$@"
    fi
    #        if [ -z "$vcusr" ] && [ -z "$rootusr" ]; then echo "VC SSO user AND VC root user NOT present."; python $vxv_exe -i -g "$targetver" "$@"; fi
    if [ -z "$vcusr" ] && [ -z "$rootusr" ]; then
      echo "VC SSO user AND VC root user NOT present."
      $vxv_py -g "$targetver" "$@"
    fi
    break
    ;;

  "Core upgrade healthcheck")
    echo "Core upgrade healthcheck selected."
    read -p "Enter target version: " targetver

    # Ask for VC admin credentials:
    echo
    read -p "VC SSO user [default: administrator@vsphere.local]: " vcusr # if NULL use "root" as default value
    if [[ -z "$vcusr" ]]; then
      vcusr="administrator@vsphere.local"
    fi
    echo "Enter VC SSO password:"
    read -s vcpass

    # Ask for VC root credentials:
    echo
    read -p "VC root user [default: root]: " rootusr # if NULL use "root" as default value
    if [[ -z "$rootusr" ]]; then
      rootusr=root
    fi
    echo "Enter VC root password:"
    read -s rootpass

    echo "VC SSO user AND VC root user present."
    $vxv_py -c "$targetver" -r "$rootusr" -w "$rootpass" -u "$vcusr" -p "$vcpass" "$@"
    grep 'VIB:' vxtii.txt
    break
    ;;

  "General healthcheck")
    echo "Running general VxRail health tests (test profile 5)..."
    # Ask for VC admin credentials:
    read -p "Enter VC SSO credentials? (Y/N)" -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo
      read -p "VC SSO user [default: administrator@vsphere.local]: " vcusr # if NULL use "root" as default value
      if [[ -z "$vcusr" ]]; then
        vcusr="administrator@vsphere.local"
      fi
      echo "Enter VC SSO password:"
      read -s vcpass
    else
      echo
      echo "Running VxVerify without VC SSO credentials..."
    fi

    # Ask for VC root credentials:
    read -p "Run recommended option with VC root credentials? (Y/N)" -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo
      read -p "VC root user [default: root]: " rootusr # if NULL use "root" as default value
      if [[ -z "$rootusr" ]]; then
        rootusr=root
      fi
      echo "Enter VC root password:"
      read -s rootpass
    else
      echo
      echo "Running VxVerify without VC root credentials..."
    fi
    if [ -n "$vcusr" ] && [ -n "$rootusr" ]; then
      echo "VC SSO user AND VC root user present."
      $vxv_py -n 5 -r "$rootusr" -w "$rootpass" -u "$vcusr" -p "$vcpass" "$@"
    fi
    if [ -z "$vcusr" ] && [ -n "$rootusr" ]; then
      echo "VC SSO user NOT present, but VC root user present."
      $vxv_py -n 5 -r "$rootusr" -w "$rootpass" "$@"
    fi
    if [ -n "$vcusr" ] && [ -z "$rootusr" ]; then
      echo "VC SSO user present, but VC root user NOT present."
      $vxv_py -n 5 -u "$vcusr" -p "$vcpass" "$@"
    fi
    if [ -z "$vcusr" ] && [ -z "$rootusr" ]; then
      echo "VC SSO user AND VC root user NOT present."
      $vxv_py -n 5 "$@"
    fi
    grep 'VIB:' vxtii.txt
    #            python $vxv_exe -i -n 5 "$@"

    break
    ;;

  "Core post-upgrade check")
    echo "Core post-upgrade healthcheck selected, running VxVerify with Profile 8 option."

    # Ask for VC admin credentials:
    read -p "Enter VC SSO credentials? (Y/N)" -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo
      read -p "VC SSO user [default: administrator@vsphere.local]: " vcusr # if NULL use "root" as default value
      if [[ -z "$vcusr" ]]; then
        vcusr="administrator@vsphere.local"
      fi
      echo "Enter VC SSO password:"
      read -s vcpass
    else
      echo
      echo "Running VxVerify without VC SSO credentials..."
    fi

    # Ask for VC root credentials:
    read -p "Run recommended option with VC root credentials? (Y/N)" -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo
      read -p "VC root user [default: root]: " rootusr # if NULL use "root" as default value
      if [[ -z "$rootusr" ]]; then
        rootusr=root
      fi
      echo "Enter VC root password:"
      read -s rootpass
    else
      echo
      echo "Running VxVerify without VC root credentials..."
    fi
    if [ -n "$vcusr" ] && [ -n "$rootusr" ]; then
      echo "VC SSO user AND VC root user present."
      $vxv_py -n 8 -r "$rootusr" -w "$rootpass" -u "$vcusr" -p "$vcpass" "$@"
    fi
    if [ -z "$vcusr" ] && [ -n "$rootusr" ]; then
      echo "VC SSO user NOT present, but VC root user present."
      $vxv_py -n 8 -r "$rootusr" -w "$rootpass" "$@"
    fi
    if [ -n "$vcusr" ] && [ -z "$rootusr" ]; then
      echo "VC SSO user present, but VC root user NOT present."
      $vxv_py -n 8 -u "$vcusr" -p "$vcpass" "$@"
    fi
    if [ -z "$vcusr" ] && [ -z "$rootusr" ]; then
      echo "VC SSO user AND VC root user NOT present."
      $vxv_py -n 8 "$@"
    fi
    break
    ;;

  "Quit")
    break
    ;;
  *) echo "invalid option $REPLY" ;;
  esac
done
