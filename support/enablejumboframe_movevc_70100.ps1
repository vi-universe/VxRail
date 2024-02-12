param(
    [int]$MTU,
    [string]$vCenterServer,
    [string]$vxmIP,
    [string]$vcUser,
    [string]$vcPwd,
    [string]$vxVDS,
    [string]$vxCluster,
    [switch]$hostMode,
    [string]$addHostName,
    [switch]$vcNotInCluster,
    [switch]$skipValid,
    [string]$validIP,
    [int]$retryTimes = 3,
    [string]$VMK = "vmk2"


)

Import-Module Posh-SSH

function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Information', 'Warning', 'Error')]
        [string]$Severity = 'Information'
    )

    switch ($Severity) {
        'Information' {
            Write-Host $Message -ForegroundColor Green
        }
        'Warning' {
            Write-Host $Message -ForegroundColor Yellow
        }
        'Error' {
            Write-Host $Message -ForegroundColor Red
        }
        Default {}
    }

    $log_file = ".\\LogFile.csv"

    [pscustomobject]@{
        Time     = (Get-Date -f g)
        Severity = $Severity
        Message  = $Message
    } | Export-CSV -Path $log_file -Append -NoTypeInformation
}

# Usage: ensure there are no vSAN component resyncing
# Param:
#   -vxRailCluster   ---- [cluster] vxRail Cluster
# Return: null
function Confirm-NovSanComponent {
    [CmdletBinding()]
    Param (
        $vxRailCluster, $Maximum
    )
    Write-Log "`nCheck vSAN Component are resyncing..."

    $retry_times = 0

    do {

        try {
            if ((Get-VsanResyncingComponent -Cluster $vxRailCluster -ErrorAction Stop).Length -eq 0) {
                Write-Log "`tNo vSAN Component are resyncing now."
                return
            }
            Write-Log "Please ensure there are no vSAN components are resyncing"
            Start-Sleep -s 5

        }
        catch {
            Write-Log $PSItem.ToString() "Error"
            Write-Log "`tCheck No vSAN Component failed." "Error"

        }

        $retry_times++

    } while ($retry_times -lt $Maximum)


    if ($retry_times -eq $Maximum) {
        write-Log "`tvSAN Component are still resyncing now or Check No vSAN Component failed." "Error"
        exit 1
    }

}

# Usage: Backup VDS configuration to download path
# Param:
#   -vDSwitch  ---- [vDSwitch]
# Return: full path of backup file
function BackUp-VDSwitch {
    [CmdletBinding()]
    Param (
        $vDSwitch
    )
    Write-LOg "Backup vDSwitch configuration..."
    $FileDate = get-date -format yyyyMMdd"_"HHmm

    #TO-DO modify download path
    $vDSConfigPath = ".\"
    try {
        Export-VDSwitch -VDSwitch $vDSwitch -Description "VDSwitch configuration" -Destination ($vDSConfigPath + "vDSbackup" + $FileDate + ".zip") -Force | out-null
        Write-LOg "Backup vDSwitch configuration Successfully."
    }
    catch {
        Write-Log $PSItem.ToString() "Error"
        exit 1
    }
}

# Usage: enable/disable  esxi's ssh
# Param:
#   -ESXi   ---- [vmhost] the vmhost need to be changed
#   -enable ---- [$true|$false] $true: enable ssh | $false: disable ssh
# Return: null
function Set-ESXiSSH {
    [CmdletBinding()]
    Param (
        $ESXi, [switch]$enable
    )
    if ($enable) {
        Write-Log "Enable ssh of ESXi Host:$($ESXi.Name)"
        $($interface.VMHost)
        #Start the SSH Service
        if ($ESXi | Get-VMHostService | Where-Object { $_.Key -eq "TSM-SSH" -and $_.Running -ne $true}) {
            $ESXi | Get-VMHostService | Where-Object { $_.Key -eq "TSM-SSH"} | Start-VMHostService -Confirm:$false | Out-Null
        }
    }
    else {
        Write-Log "disable ssh of ESXi Host:$($ESXi.Name)"
        #Stop the SSH Service
        if ($ESXi | Get-VMHostService | Where-Object { $_.Key -eq "TSM-SSH" -and $_.Running -ne $false}) {
            $ESXi | Get-VMHostService | Where-Object { $_.Key -eq "TSM-SSH"} | Stop-VMHostService -Confirm:$false | Out-Null
        }
    }
}

# Usage: set vDS's mtu
# Param:
#   -vDSwitch   ---- [vDSwitch]
#   -mtu        ---- [int] mtu to be set
# Return: null
function Set-vDSMTU {
    [CmdletBinding()]
    Param (
        $vDSwitch, [int]$mtu,$Maximum
    )
    Write-Log "Enable jumbo frames on the vDS... Please wait.. It will take a few minutes..."

    $retry_times = 0

    do {
        try {
            Set-VDSwitch -VDSwitch $vDSwitch -Mtu $mtu -ErrorAction Stop
            Write-Log "Successfully enable Jumbo Frames on vDS"
            return
        }
        catch {

            Write-Log "Enable jumbo frames on vDS failed. Retry..." "Error"
        }
        $retry_times++
    } while ($retry_times -lt $Maximum)

    if ($retry_times -eq $Maximum) {
        Write-Log "Enable jumbo frames on vDS failed." "Error"
        exit 1
    }
}

# Usage: poweron/poweroff virtual machine
# Param:
#   -vm   ---- [vm] the virtual machine to be changed power
#   -power   ---- [$true|$false] $true: poweron | $false: poweroff
# Return: null
function set-VMPower {
    [CmdletBinding()]
    Param (
        $vm, [switch]$power, $Maximum
    )
    $vmName = $vm.Name
    $statusTmp = If ($power) {"on"} else {"off"}
    Write-Log "`tStart to power $($statusTmp) virtual machine: $($vmName) ..."

    $retry_times = 0

    do {
        try {
			$MyVM = Get-VM $vm
            $status = $MyVM.PowerState
			Write-Log "Current status : $status"
            if ($power) {
                if($status -eq "PoweredOn"){
                    return
                }
                Start-VM -VM $vm -Confirm:$False   -ErrorAction Stop
            }
            else {
                if($status -eq "PoweredOff"){
                    return
                }
                Stop-VM -VM $vm -Confirm:$False  -ErrorAction Stop
            }
            Write-Log "`tPowered $($statusTmp) virtual machine: $($vmName)"
            return
        }
        catch {
            Write-Log $PSItem.ToString() "Error"
            Write-Log "`tRetry to  power $($statusTmp) virtual machine: $($vmName) " "Warning"

        }
        Start-Sleep -s 10
        $retry_times++

    } while ($retry_times -lt $Maximum)

    if ($retry_times -eq $Maximum) {
        Write-Log "`tStart to power $($statusTmp) virtual machine: $($vmName) failed" "Error"
        exit 1
    }
}

function Set-InterfacsMTU{

    [CmdletBinding()]
    Param (
        $Cluster,$Interfaces, $Mtu, $Maximum
    )

    foreach ($interface in $vmkInterfaces) {
        # Configure the interface to the requested MTU
        $retry_times = 0
        do {
            if ($interface.Mtu -ne $MTU) {
                try {
                    if ($retry_times -gt 0) {
                        Start-Sleep -s 10
                        Write-log "Checking '$($interface.VMHost.Name)' connection state..." "Information"
                        do {
                            $curvmHost = VMware.VimAutomation.Core\Get-Cluster $cluster | Get-VMHost -Name $interface.VMHost.Name

                            Write-log "'$($curvmHost.Name)' is '$($curvmHost.ConnectionState)'" "Information"

                            if ($curvmHost.ConnectionState -ne "Connected") {
                                Start-Sleep -s 5
                            }
                        } while ($curvmHost.ConnectionState -ne "Connected")
                    }
                    Write-Log "- Configuring interface '$($interface.PortGroupName)' on '$($interface.VMHost)' to MTU $mtu"
                    Set-VMHostNetworkAdapter -VirtualNic $interface -Mtu $mtu -Confirm:$False -ErrorAction Stop
                    Write-Log "- Configured interface '$($interface.PortGroupName)' on '$($interface.VMHost)' to MTU $mtu"
                    break
                }
                catch {
                    Write-Log $PSItem.ToString() "Error"
                    Write-Log "- Re-Configuring interface '$($interface.PortGroupName)' on '$($interface.VMHost)' to MTU $mtu"

                }
            }
            else {
                Write-Log "Host:$($interface.VMHost.Name)->Interface:$($interface.Name)->MTU:$($interface.Mtu) is same with MTU:$($MTU)" "Information"
                break
            }

            $retry_times++

        } while ($retry_times -lt $Maximum)

        if ($retry_times -eq $Maximum) {
            Write-Log "- Failed to configure interface '$($interface.PortGroupName)' on '$($interface.VMHost)' to MTU $MTU"
            exit 1
        }
    }
}

function Set-VMKernelMTU {
    [CmdletBinding()]
    Param (
        $cluster, $mtu, $vswitch, $Maximum,$vcNotInCluster,$vcip
    )
    Write-Log "Enable jumbo frames on the vmkernel portgroup..."
    Write-Log "- Configuring VMKernel PortGroups.."
    try {
        #$vmkInterfaces = Get-VMHostNetworkAdapter -VMKernel -VirtualSwitch $vswitch -VMHost (VMware.VimAutomation.Core\Get-Cluster $cluster | Get-VMHost)  -ErrorAction Stop
        if($vcNotInCluster){
            $vmHosts = VMware.VimAutomation.Core\Get-Cluster $cluster | Get-VMHost

            foreach ($vmhost in $vmHosts) {
                $vmkInterfaces = Get-VMHostNetworkAdapter -VMKernel -VirtualSwitch $vswitch -VMHost $vmhost -ErrorAction Stop
                Set-InterfacsMTU -Cluster $cluster -Interfaces $vmkInterfaces -Mtu $mtu -Maximum $Maximum
            }
        }
        else {
            $vCenter = Get-VM | Where-Object -FilterScript { $_.Guest.Nics.IPAddress -contains $vcip }
            $vmHosts = VMware.VimAutomation.Core\Get-Cluster $vxCluster | Get-VMHost | Where-Object -FilterScript { $_.Name -ne $vCenter.VMHost.Name }
            Write-Log "Move internal VC from $($vCenter.VMHost.Name) to $($vmHosts[0].Name)"
			$retry_times = 0

			do{
				try{
						if ($retry_times -gt 0) {
							Start-Sleep -s 10

						Move-VM -VM $vCenter -destination $vmHosts[0].Name -ErrorAction Stop
						break
					}
				}

			   catch {
					Write-Log $PSItem.ToString() "Error"
					Write-Log "Retry to move internal VC from $($vCenter.VMHost.Name) to $($vmHosts[0].Name)." "Warning"
				}

				$retry_times++

			} while ($retry_times -lt $Maximum)

			if ($retry_times -eq $Maximum) {
				Write-Log $PSItem.ToString() "Error"
				Write-Log "Move internal VC from $($vCenter.VMHost.Name) to $($vmHosts[0].Name) failed" "Error"
				exit 1
			}

            #modify managment vmkernel first
            Write-Log "Config internal VC from $($vCenter.VMHost.Name) to $($vmHosts[0].Name)"
            $vcVMHost = VMware.VimAutomation.Core\Get-Cluster $vxrailCluster | Get-VMHost -Name $vCenter.VMHost.Name -ErrorAction Stop
            $vmkInterfaces = (Get-VMHostNetworkAdapter -VMKernel -VirtualSwitch $vDSwitch -VMHost $vcVMHost) | Where-Object {$_.ManagementTrafficEnabled -eq 'True'}  -ErrorAction Stop

            Set-InterfacsMTU -Cluster $cluster -Interfaces $vmkInterfaces -Mtu $mtu -Maximum $Maximum
			Write-Log "Check all host are connected to VCenter..." "Information"

			Start-Sleep -s 130

			do {
				$allhost_connected = $true

				$vmHostsAll = VMware.VimAutomation.Core\Get-Cluster $vxrailCluster | Get-VMHost

				foreach ($vmhostConnect in $vmHostsAll) {
					$allhost_connected = $allhost_connected -and ($vmhostConnect.ConnectionState -eq "Connected")
					Write-log "'$($vmhost.Name)' is '$($vmhost.ConnectionState)'" "Information"
				}
				if ($allhost_connected -eq $false) {
					Start-Sleep -s 5
				}
			} while ($allhost_connected -eq $false)

            Write-Log "Move internal VC from $($vmHosts[0].Name) to $($vCenter.VMHost.Name)"
			$retry_times = 0

			do{
				try{
						if ($retry_times -gt 0) {
							Start-Sleep -s 10

						Move-VM -VM $vCenter -destination $vCenter.VMHost.Name -ErrorAction Stop

						break
					}
				}
			   catch {
					Write-Log $PSItem.ToString() "Error"
					Write-Log "Retry to move internal VC from $($vmHosts[0].Name) to $($vCenter.VMHost.Name)."  "Warning"
				}
				$retry_times++

			} while ($retry_times -lt $Maximum)

			if ($retry_times -eq $Maximum) {

				Write-Log "Move internal VC from $($vmHosts[0].Name) to $($vCenter.VMHost.Name) failed" "Error"
				exit 1
			}

            foreach ($vmhost in $vmHosts) {
                $vmkInterfaces = Get-VMHostNetworkAdapter -VMKernel -VirtualSwitch $vswitch -VMHost $vmhost -ErrorAction Stop
                Set-InterfacsMTU -Cluster $cluster -Interfaces $vmkInterfaces -Mtu $mtu -Maximum $Maximum
            }

			Write-Log "Check all host are connected to VCenter..." "Information"

			do {
				$allhost_connected = $true
				$vmHostsAll = VMware.VimAutomation.Core\Get-Cluster $vxrailCluster | Get-VMHost

				foreach ($vmhostConnect in $vmHostsAll) {
					$allhost_connected = $allhost_connected -and ($vmhostConnect.ConnectionState -eq "Connected")
					Write-log "'$($vmhostConnect.Name)' is '$($vmhostConnect.ConnectionState)'" "Information"
				}
				if ($allhost_connected -eq $false) {
					Start-Sleep -s 5
				}
			} while ($allhost_connected -eq $false)

            $vmkInterfaces = (Get-VMHostNetworkAdapter -VMKernel -VirtualSwitch $vDSwitch -VMHost $vcVMHost) | Where-Object {$_.ManagementTrafficEnabled -ne 'False'}  -ErrorAction Stop
            Set-InterfacsMTU -Cluster $cluster -Interfaces $vmkInterfaces -Mtu $mtu -Maximum $Maximum
        }
    }
    catch {
        Write-Log $PSItem.ToString() "Error"
        Write-Log "- Re-Configuring interface '$($interface.PortGroupName)' on '$($interface.VMHost)' to MTU $mtu" Error
        exit 1
    }
}

function Set-HostVMKernelMTU {
    [CmdletBinding()]
    Param (
        $cluster, $mtu, $vswitch, $vmhost
    )
    Write-Log "Enable jumbo frames on the vmkernel portgroup..."
    Write-Log "- Configuring VMKernel PortGroups.."

    $vmkInterfaces = Get-VMHostNetworkAdapter -VMKernel -VirtualSwitch $vswitch -VMHost $vmhost
    foreach ($interface in $vmkInterfaces) {
        # Configure the interface to the requested MTU
        try {
            Set-VMHostNetworkAdapter -VirtualNic $interface -Mtu $mtu -Confirm:$False
            Write-Log "- Configured interface '$($interface.PortGroupName)' on '$($interface.VMHost)' to MTU $mtu"
        }
        catch {

            Write-Log "- Failed to configure interface '$($interface.PortGroupName)' on '$($interface.VMHost)' to MTU $MTU" "Error"
            exit 1
        }
    }
}

# Usage: get vmhost's info
# Param:
#   -ESXi   ---- [vmhost] esxi host
# Return:
#   -hostinfo   ---- [directory] key: {esxi's name, managementIP, powerstate, manufacturer, model}
function Get-vmhostInfo {
    [CmdletBinding()]
    Param (
        $ESXi
    )
    $hostInfo = $ESXi |
        select-Object Name, @{n = "ManagementIP"; e = {Get-VMHostNetworkAdapter -VMHost $_ -VMKernel |
                Where-Object {$_.ManagementTrafficEnabled} |
                ForEach-Object {$_.Ip}}
    }, PowerState, Manufacturer, Model
    return $hostInfo
}

# Usage: get vmhost's info
# Param:
#   -hosts   ---- [array] esxi host(s)
#   -mtu     ---- [int] mtu set before
#   -vcip    ---- [String] vc ip address
#   -vmk     ---- [String] source vmk interface used by vmkping
# Return: null
function Test-Jumboframe {
    [CmdletBinding()]
    Param (
        $hosts, $ip, [int]$mtu, $vmk
    )
    foreach ($vmhost in $hosts) {
        try {
            Write-Log "Testing jumbo frame on host:'$($vmhost.Name)'...."
            $hostIP = -join ((get-vmhostInfo -ESXi $vmhost).managementIP)
            ##$hostCredential = Get-Credential root -Message "Please input the password of host: $hostIP"
            #$User = "root"
            #$PWord = ConvertTo-SecureString -String "Testesx123!" -AsPlainText -Force
            #$hostCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord
            $hostSSH = New-SSHSession -Force -ComputerName $hostIP -Credential $hostCredential  -ConnectionTimeOut 100 -ErrorAction Stop
            $cmd = $(Invoke-SSHCommand -SSHSession $hostSSH -Command "vmkping -I $vmk -s $mtu -d $ip")
			Write-Log "Command excute result: $cmd"
			$res=$cmd.ExitStatus
            if ($res -eq 0) {
                Write-Log "Enable jumbo frames successfully."
            }
            else {
                Write-Log "Test jumbo frame on host:'$($vmhost.Name) failed. Please check it manually.'  ." "Error"
            }

            Remove-SSHSession -SSHSession (Get-SSHSession) -Verbose -ErrorAction Stop
        }
        catch {
            Write-Log $PSItem.ToString() "Error"
        }
    }
}

function setVMKernelPortGroupsMTU {
    Write-Host "Finding and configuring VMKernel PortGroups.."
    # Get a list of all VMKernel ports on the ESXi hosts attached to the requested cluster
    $vmkInterfaces = Get-VMHostNetworkAdapter -VMKernel -VMHost (VMware.VimAutomation.Core\Get-Cluster $Cluster | Get-VMHost);

    # Go through all found vmkernel interfaces
    foreach ($interface in $vmkInterfaces) {
        # Next is some logic to determine whether to change the MTU of the current interface
        $skip = $True
        if ($NFS -eq $True -and $interface.PortGroupName -like "*nfs*") { $skip = $False }
        if ($iSCSI -eq $True -and $interface.PortGroupName -like "*iscsi*") { $skip = $False }
        if ($VSAN -eq $True -and $interface.PortGroupName -like "*vsan*") { $skip = $False }
        if ($vMotion -eq $True -and $interface.PortGroupName -like "*vmotion*") { $skip = $False }
        if ($skip -eq $True) { continue }

        # Configure the interface to the requested MTU
        if (Set-VMHostNetworkAdapter -VirtualNic $interface -Mtu $MTU -Confirm:$False) {
            Write-Host "- Configured interface '$($interface.PortGroupName)' on '$($interface.VMHost)' to MTU $MTU" -foregroundcolor "green"
        }
        else {
            Write-Host "- Failed to configure interface '$($interface.PortGroupName)' on '$($interface.VMHost)' to MTU $MTU" -foregroundcolor "red"
        }
    }
}

function setStandardvSwitchesMTU {
    Write-Host "Finding and configuring all Standard vSwitches.."
    # Get a list of all vSwitches on the ESXi hosts that are in the requested DRS cluster
    $vswitches = Get-VirtualSwitch -Standard -VMHost (VMware.VimAutomation.Core\Get-Cluster $Cluster | Get-VMHost);

    # Go through all found vSwitches
    foreach ($vswitch in $vswitches) {
        if (Set-VirtualSwitch $vswitch -Mtu $MTU -Confirm:$False) {
            Write-Host "- Configured Standard vSwitch '$($vswitch.Name)' to MTU $MTU" -foregroundcolor "green"
        }
        else {
            Write-Host "- Failed to configure vSwitch '$($vswitch.Name)' to MTU $MTU" -foregroundcolor "red"
        }
    }
}

function setDistributedvSwitchesMTU {
    Write-Host "Finding and configuring all Distributed vSwitches.."
    # Get a list of all Distributed vSwitches on the ESXi hosts that are in the requested DRS cluster
    $vswitches = Get-VDSwitch -VMHost (VMware.VimAutomation.Core\Get-Cluster $Cluster | Get-VMHost);

    # Go through all found vSwitches
    foreach ($vswitch in $vswitches) {
        if (Set-VDSwitch $vswitch -Mtu $MTU -Confirm:$False) {
            Write-Host "- Configured Distributed vSwitch '$($vswitch.Name)' to MTU $MTU" -foregroundcolor "green"
        }
        else {
            Write-Host "- Failed to configure Distributed vSwitch '$($vswitch.Name)' to MTU $MTU" -foregroundcolor "red"
        }
    }
}


function Usage {
    Write-Host ""
    Write-Host "Usage: .\$scriptName "
    Write-Host "   -vCenterServer       <vCenter Server>        - IP for vCenter Server"
    Write-Host "   -vcUser              <VCenter User>          - Name for VCenter User"
    Write-Host "   -vcPwd               <VCenter User Password> - Password for vCenter User"
    Write-Host "   -vxVDS               <vDS Name>              - Name of Virtual Distributed Switch"
    Write-Host "   -vxCluster           <Cluster Name>          - Name of VxRail Cluster"
    Write-Host "   -hostMode            <host mode>             - Change host vmkernels"
    Write-Host "   -addHostName         < Name>                 - Name of the host for hostMode"
    Write-Host "   -MTU                 <MTU Size>              - Optional MTU size(1280-9000)"
    Write-Host "   -validIP             [Valid IP]              - IP used by vmkping for Jumbo Frame validation"
    Write-Host "   -skipValid           -Skip Validation (if -skipValid is selected, -validIP can be ignored)"
    Write-Host "   -vcNotInCluster      -vCenter Server is not as a VM in the selected Cluster"
    Write-Host "   -retryTimes          [Retry Times]           - times to retry steps failed in the script(minimum value is 3)"
    Write-Host "   -VMK                 [vmk interface]         - source vmk interface used by vmkping to test Jumbo frames(default value is vmk2)"
    Write-Host ""
    Write-Host 'For example:\n enablejumboframe.ps1 -skipValid -MTU 1500 -vCenterServer 192.168.101.201 -vcUser "administrator@vsphere.local" -vcPwd "12345678!" -vxVDS "VMware HCIA Distributed Switch" -vxCluster "VxRail-Virtual-SAN-Cluster-d5fff3cd-49dc-4230-8aa1-071050aa4fc0"'
    exit 0;
}


$logo = @"
 _    __     ____        _ __   ____                           __
| |  / /  __/ __ \____ _(_) /  / __ \_________  ________  ____/ /_  __________
| | / / |/_/ /_/ / __ `/ / /  / /_/ / ___/ __ \/ ___/ _ \/ __  / / / / ___/ _ \
| |/ />  </ _, _/ /_/ / / /  / ____/ /  / /_/ / /__/  __/ /_/ / /_/ / /  /  __/
|___/_/|_/_/ |_|\__,_/_/_/  /_/   /_/   \____/\___/\___/\__,_/\__,_/_/   \___/

"@
Write-Host $logo


if ($help) {
    Usage
    exit 0
}

# confirm user has set mtu on physical switch
Write-Host -ForegroundColor Yellow "Firstly, on the physical switch, please set all ports to new physical MTU.
Note:
The MTU setting on the physical switch needs to be larger than the virtual switch to accommodate packet header and footer overhead.
Please ensure that physical MTU is a little larger than virtual switch one.`n"

#check arguments

if ($retryTimes -lt 3){
    Usage;
    exit 0;
}

if (($MTU -lt 1280) -or ($MTU -gt 9000)) {
    #Write-Host "Using a MTU size of less than 1500 or greater than 9000 is usually not advised." -foregroundcolor "yellow"
    Write-Log "Using a MTU size of less than 1280 or greater than 9000 is not allowed." "Warning"
    Usage;
    exit 0;
}

if ($vCenterServer -eq "" -or $vxCluster -eq "" -or $vxVDS -eq "" -or $vcUser -eq "" -or $vcPwd -eq "") {
    Usage;
    exit 0;
}

if( $null  -eq ($vCenterServer -as [ipaddress]) -or ($vCenterServer -as [ipaddress]) -eq $false){
    Usage;
    exit 0;
}

if ($hostMode) {
    if ($addHostName -eq "") {
        Write-Log "`nPlease supply a host to change vmkernels mtu." "Error"
        Usage;
        exit 0;
    }
}

if ($skipValid -eq $false) {
    if ($validIP -eq "") {
        Write-Log "Please supply IP for vmkping for jumbo frame validataion" "Error"
        Usage
        exit 1
    }
}

Write-Log "Close all vc connection..." "Information"

#TODO handle all connection
try{
    Disconnect-VIServer -Server * -Force -Confirm:$false
}
catch {
    Write-Log "No vc connection found." "Warning"
}

#connect VC
Write-Log "Connect to VCenter $vCenterServer..." "Information"
try {
    Connect-VIServer -Server $vCenterServer -Protocol https -User $vcUser -Password $vcPwd -ErrorAction Stop
    if ($global:DefaultVIServers.count -eq 0) {
        Write-Log "Failed to connect to such servers." "Error"
        exit 1
    }
}
catch {
    Write-Log $PSItem.ToString() "Error"
    Write-Log "Failed to connect to vCenter: Incorrect IP / Username / Password"  "Error"
    exit 1
}


#TODO IP
$vcIP = $Global:DefaultViServers.Name
$vCenterVersion = $Global:DefaultViServers.Version
Write-Log "VCenter $vcIP " "Information"
Write-Log "VCenter Version $vCenterVersion " "Information"
Write-Log "VCenter Version $vCenterVersion " "Information"

#------------------------------------------------------#
if ($vcNotInCluster -eq $false) {

    $vCenter = Get-VM | Where-Object -FilterScript { $_.Guest.Nics.IPAddress -contains $vcIP }
}

$vxm = Get-VM | Where-Object -FilterScript { $_.Guest.Nics.IPAddress -contains $vxmIP }
$systemVM = @($vCenter, $vxm)
$vcls = Get-VM | Where-Object -FilterScript { $_.Name -like "vCLS*" }
Write-Log "vcls: $vcls"
$vcls | ForEach-Object {$systemVM += $_}
Write-Log "systerm VM: $systemVM"

# ensure vc version is 6.5+
if ($vCenterVersion -lt "6.5.0") {
    Write-Log "Please connect to a vCenter Server running at least v6.5.0 server before running this Cmdlet." "Error"
    exit 1
}
else {
    Write-Log "`tConnected to vCenter: $Global:DefaultViServers, v$vCenterVersion" "Information"
}

# Begin Setting Check
# get the VxRail Cluster
Write-Log "`nChecking VxRail Cluster Name" "Information"
$vxrailCluster = VMware.VimAutomation.Core\Get-Cluster -Name $vxCluster

if (!$vxrailCluster) {
    Write-Log "There is no cluster named $vxCluster" "Error"
    Exit 1
}
else {
    Write-Log "Checking VxRail Cluster Name ---------- Pass" "Information"
}

# get the vDs
Write-Log "Checking VxRail VDSwitch Name" "Information"

$vDSwitch = Get-VDSwitch -Name $vxVDS

if (!$vDSwitch) {
    Write-Log "There is no virtual distributed switch named $vxVDS" "Error"
    Exit 1
}
else {
    Write-Log "Checking VxRail VDSwitch Name ---------- Pass" "Information"
}

Write-Log "`nChecking VxRail VDSwitch MTU..." "Information"
$changeVDSMTU = $false

if ($vDSwitch.Mtu -eq $MTU) {
    Write-Log "`tChecking VxRail VDSwitch MTU is equal to $MTU" "Information"
    $changeVDSMTU = $true
}

if ($hostMode) {
    if ($addHostName -eq "") {
        Write-Log "`nPlease supply a host to change vmkernels mtu." "Error"
        Usage;
        exit 0;
    }
    else {
        try {
            $Maximum = $retryTimes
            $addVMHost = VMware.VimAutomation.Core\Get-Cluster $vxrailCluster | Get-VMHost -Name $addHostName -ErrorAction Stop
            if ($addVMHost) {
                Write-Log "`nChecking Host:$addHostName in Maintaince Mode" "Information"
                if ($addVMHost.ConnectionState -eq "Maintenance") {
                    $vmkInterfaces = Get-VMHostNetworkAdapter -VMKernel -VirtualSwitch $vDSwitch -VMHost $addVMHost  -ErrorAction Stop

                    foreach ($interface in $vmkInterfaces) {

                        if (-not ($interface.Mtu -eq $MTU)) {
                            Write-Log "Host:$($addVMHost.Name)->Interface:$($interface.Name)->MTU:$($interface.Mtu) is different from $($MTU)" "Warning"

                            if ($vDSwitch.Mtu -lt $MTU) {
                                Write-Log "vDS's MTU:$($vDSwitch.Mtu) is smaller than $($MTU). Please change vDS MTU firstly." "Warning"
                                exit 1
                            }
                            else {
                                $retry_times = 0
                                do {
                                    try {
                                        if ($retry_times -gt 0) {
                                            Start-Sleep -s 10
                                            Write-log "Checking '$($interface.VMHost.Name)' connection state..." "Information"
                                            do {
                                                $curvmHost = VMware.VimAutomation.Core\Get-Cluster $vxrailCluster | Get-VMHost -Name $interface.VMHost.Name

                                                Write-log "'$($curvmHost.Name)' is '$($curvmHost.ConnectionState)'" "Information"

                                                if ($curvmHost.ConnectionState -ne "Maintenance") {
                                                    Start-Sleep -s 5
                                                }
                                            } while ($curvmHost.ConnectionState -ne "Maintenance")
                                        }
                                        Write-Log "- Configuring interface '$($interface.PortGroupName)' on '$($interface.VMHost)' to MTU $mtu"
                                        #Set-HostVMKernelMTU -cluster $vxrailCluster -vswitch $vDSwitch -vmhost $addVMHost -mtu $MTU  -ErrorAction Stop
                                        Set-VMHostNetworkAdapter -VirtualNic $interface -Mtu $mtu -Confirm:$False -ErrorAction Stop
                                        Write-Log "- Configured interface '$($interface.PortGroupName)' on '$($interface.VMHost)' to MTU $mtu"
                                        break
                                    }
                                    catch {
                                        Write-Log $PSItem.ToString() "Error"
                                        Write-Log "- Re-Configuring interface '$($interface.PortGroupName)' on '$($interface.VMHost)' to MTU $mtu"
                                    }
                                    $retry_times++

                                } while ($retry_times -lt $Maximum)

                                if ($retry_times -eq $Maximum) {
                                    Write-Log "- Failed to configure interface '$($interface.PortGroupName)' on '$($interface.VMHost)' to MTU $MTU"
                                    exit 1
                                }
                            }
                        }
                        else {
                            #$message =  "Host:"+$addVMHost.Name+"->Interface:"+$interface.Name+"->MTU:"+$interface.Mtu+" is same with "+$MTU
                            Write-Log "Host:$($addVMHost.Name)->Interface:$($interface.Name)->MTU:$($interface.Mtu) is same with $($MTU)"  "Warning"
                        }
                    }

                    Write-Log "Enable jumbo frames successfully."

                    if ($skipValid -eq $false) {
                        # enbale hosts' ssh
                        VMware.VimAutomation.Core\Get-Cluster $vxrailCluster | Get-VMHost | foreach-object { set-esxiSSH -ESXi $_ -enable:$true }

                        # MTU Validate
                        $testMTU = $MTU - 28
                        Test-Jumboframe -hosts (Get-VMHost -Name $addHostName) -ip $validIP -mtu $testMTU -vmk $VMK

                        # disable hosts' ssh
                        VMware.VimAutomation.Core\Get-Cluster $vxrailCluster | Get-VMHost  | foreach-Object { set-esxiSSH -ESXi $_ -enable:$false }
                    }

                    Disconnect-VIServer $vcIP -Confirm:$false
                    exit 0
                }
                else {
                    Write-Log "Please make sure the new added host in maintenance mode." "Error"
                    exit 1
                }
            }
            else {
                Write-Log "Cannot find the host in the cluster." "Error"
                exit 1
            }
        }
        catch {
            Write-Log $PSItem.ToString() "Error"
            exit 1
        }
    }
}

Write-Log "`nChecking all exsi hosts' connect state... " "Information"

$allhost_connected = $true

$vmHosts = VMware.VimAutomation.Core\Get-Cluster $vxrailCluster | Get-VMHost

foreach ($vmhost in $vmHosts) {
    $allhost_connected = $allhost_connected -and ($vmhost.ConnectionState -eq "Connected")
    Write-log "'$($vmhost.Name)' is '$($vmhost.ConnectionState)'" "Information"
}

if ($allhost_connected -eq $false) {
    Write-log "Please make sure all exsi hosts are connected." "Error"
    exit 1
}

Write-Log "`nChecking VMKernels MTU..." "Information"

$vmHosts = VMware.VimAutomation.Core\Get-Cluster $vxrailCluster | Get-VMHost

Write-Host $vmHosts

$changeHostMTU = $true

foreach ($vmhost in $vmHosts) {
    $vmkInterfaces = Get-VMHostNetworkAdapter -VMKernel -VirtualSwitch $vDSwitch -VMHost $vmhost
    Write-Host $vmkInterfaces
    foreach ($interface in $vmkInterfaces) {

        if (-not ($interface.Mtu -eq $MTU)) {
            #$message =  "Host:"+$vmhost.Name+"->Interface:"+$interface.Name+"->MTU:"+$interface.Mtu+" is different from "+$MTU
            Write-Log "Host:$($vmhost.Name)->Interface:$($interface.Name)->MTU:$($interface.Mtu) is different from MTU:$($MTU)" "Information"
            $changeHostMTU = $false
        }
        else {
            #$message =  "Host:"+$vmhost.Name+"->Interface:"+$interface.Name+"->MTU:"+$interface.Mtu+" is same with "+$MTU
            Write-Log "Host:$($vmhost.Name)->Interface:$($interface.Name)->MTU:$($interface.Mtu) is same with MTU:$($MTU)" "Information"
        }
    }
}

if ($changeHostMTU -and $changeVDSMTU) {
    Write-Log "`nMTU $MTU is already configued on VDS and VMKernels." "Warning"
    Disconnect-VIServer $vcIP -Confirm:$false
    Exit 0
}

$vmInCluster = VMware.VimAutomation.Core\Get-Cluster $vxrailCluster| Get-VM
if ($vmInCluster.Length -lt 0) {
    Write-Log "No virtual machines found in this cluster." "Warning"
}

# End Setting Check

# ensure no vSAN Component is resyncing
Confirm-NovSanComponent -vxRailCluster $vxrailCluster -Maximum $retryTimes

# backup the vDSWitch configuration
backUp-VDSwitch -vDSwitch $vDSwitch

# poweroff vxrail manager and user vms
$global:poweredoffVM = @()

Write-Log "Poweroff VM in the Cluster." "Information"
Write-Host "If the script is failed in the steps after power off VMS, please power on VMS when the script is executed successfully after retry."

VMware.VimAutomation.Core\Get-Cluster $vxrailCluster| Get-VM |
    Where-Object { ($_.PowerState -eq 'PoweredOn') -and ($_ -notin $systemVM) } |
    foreach-object {
    $global:poweredoffVM += $_
    set-VMPower -vm $_ -power:$false -Maximum $retryTimes
    do {
        #Wait 5 seconds
        Start-Sleep -s 10
        #Check the power status
        $MyVM = Get-VM $_
        Write-Log "`t$_ is being Powered Off Now(Please check VM stats if vm cannot be shutdown for a long time manually.)..." "Warning"
        $status = $MyVM.PowerState
    }until($status -eq "PoweredOff")
}

if ($vDSwitch.Mtu -le $MTU) {
    # set mtu on vds
    set-vDSMTU -vDSwitch $vDSwitch -mtu $MTU -Maximum $retryTimes

    $changed_vDSwitch = Get-VDSwitch -Name $vxVDS
    $mtu_sync = $false

    do {
        if ($changed_vDSwitch.Mtu -eq $MTU) {
            $mtu_sync = $true
        }
        else {
            Write-Log "`tChecking VxRail VDSwitch MTU Syncing..."
        }
    } while ($mtu_sync -eq $false)

    Write-Log "Check all host are connected to VCenter..." "Information"

    do {
        $allhost_connected = $true
        $vmHosts = VMware.VimAutomation.Core\Get-Cluster $vxrailCluster | Get-VMHost

        foreach ($vmhost in $vmHosts) {
            $allhost_connected = $allhost_connected -and ($vmhost.ConnectionState -eq "Connected")
            Write-log "'$($vmhost.Name)' is '$($vmhost.ConnectionState)'" "Information"
        }
        if ($allhost_connected -eq $false) {
            Start-Sleep -s 5
        }
    } while ($allhost_connected -eq $false)

    # set mtu on vmkernel port group
    Set-VMKernelMTU -cluster $vxrailCluster -vswitch $vDSwitch  -mtu $MTU -Maximum $retryTimes -vcNotInCluster $vcNotInCluster -vcip $vcIP
}
else {

    # set mtu on vmkernel port group
    Set-VMKernelMTU -cluster $vxrailCluster -vswitch $vDSwitch  -mtu $MTU -Maximum $retryTimes -vcNotInCluster $vcNotInCluster -vcip $vcIP
    # set mtu on vds
    set-vDSMTU -vDSwitch $vDSwitch -mtu $MTU -Maximum $retryTimes
}

Write-Log "Check all host are connected to VCenter..." "Information"

do {
    $allhost_connected = $true
    $vmHosts = VMware.VimAutomation.Core\Get-Cluster $vxrailCluster | Get-VMHost

    foreach ($vmhost in $vmHosts) {
        $allhost_connected = $allhost_connected -and ($vmhost.ConnectionState -eq "Connected")
        Write-log "'$($vmhost.Name)' is '$($vmhost.ConnectionState)'" "Information"
    }
    if ($allhost_connected -eq $false) {
        Start-Sleep -s 5
    }
} while ($allhost_connected -eq $false)

# poweron the vms(the ones be shut down before)

Write-Log "Poweron VM in the Cluster." "Information"

#check vm's host

VMware.VimAutomation.Core\Get-Cluster $vxrailCluster| Get-VM |
    Where-Object { ($_.PowerState -eq 'PoweredOff') -and ($_ -in $global:poweredoffVM) } |
    foreach-object {
    set-VMPower -vm $_ -power:$true -Maximum $retryTimes
    do {
        #Wait 10 seconds
        Start-Sleep -s 10
        #Check the power status
        $MyVM = Get-VM $_
        Write-Log "`t$_ is being Powered On Now..." "Information"
        $status = $MyVM.PowerState
    }until($status -eq "PoweredOn")
}


if ($skipValid -eq $false) {
    # enbale hosts' ssh
    VMware.VimAutomation.Core\Get-Cluster $vxrailCluster | Get-VMHost | foreach-object { set-esxiSSH -ESXi $_ -enable:$true }

    # MTU Validate
    $testMTU = $MTU - 28
    Test-Jumboframe -hosts (VMware.VimAutomation.Core\Get-Cluster $vxrailCluster | Get-VMHost) -ip $validIP -mtu $testMTU -vmk $VMK

    # disable hosts' ssh
    VMware.VimAutomation.Core\Get-Cluster $vxrailCluster | Get-VMHost  | foreach-Object { set-esxiSSH -ESXi $_ -enable:$false }
}

Write-Host "If the script is failed in the steps after power off VMS, please power on VMS when the script is executed successfully after retry."

Write-Log "`nAfter Jumbo Frames are enabled, additional steps are needed when adding or replacing a node.`n
a. Enable Jumbo MTU on the physical switch port connected to the new node.`n
b. Add or replace the node using standard Dell EMC procedures.`n
c. After successfully addition, Enable Jumbo Frames on a VMKernel network adapter for all vmkernel ports with '-h -addHostName xxxx' " "Warning"

Disconnect-VIServer $vcIP -Confirm:$false
