$currentPath = $PSScriptRoot.Substring(0,$PSScriptRoot.LastIndexOf("\"))
$currentVersion = $PSScriptRoot.Substring($PSScriptRoot.LastIndexOf("\") + 1, $PSScriptRoot.Length - ($PSScriptRoot.LastIndexOf("\") + 1))
$commonPath = $currentPath.Substring(0,$currentPath.LastIndexOf("\")) + "\VxRail.API.Common\" + $currentVersion + "\VxRail.API.Common.ps1"

. "$commonPath"


<#
.SYNOPSIS

Get a list of host & each subcomponent info.

.PARAMETER Name

Specifies the file name.

.NOTES

You can run this cmdlet to get host info.

.EXAMPLE

PS> Get-Hosts -Server <VxM IP or FQDN> -Username <username> -Password <password>

Get a list of host & each subcomponent info.

.EXAMPLE

PS> Get-Hosts -Server <VxM IP or FQDN> -Username <username> -Password <password> -Sn <sn>

Get a specific host & each subcomponent info.

#>
function Get-Hosts {
    param(
        [Parameter(Mandatory = $true)]
        # VxM IP or FQDN
        [String] $Server,

        [Parameter(Mandatory = $true)]
        # Valid vCenter username which has either Administrator or HCIA role
        [String] $Username,

        [Parameter(Mandatory = $true)]
        # Use corresponding password for username
        [String] $Password,

        [Parameter(Mandatory = $false)]
        # Print JSON style format
        [switch] $Format,

        [Parameter(Mandatory = $false)]
        # The sn of node
        [String] $Sn
    )

    $uri = "/rest/vxm/v1/hosts"
    try{ 
        if($Sn) {
            $uri = "/rest/vxm/v1/hosts/$Sn"
        }
        $ret = doGet -Server $server -Api $uri -Username $username -Password $password
        if($Format) {
            $ret = $ret | ConvertTo-Json -Depth 4
        }
        return $ret
    } catch {
        write-host $_
    }

}
 

<#
.SYNOPSIS

Host shutdown with dryrun.

.PARAMETER Name

Specifies the file name.

.NOTES

You can run this cmdlet to shutdown host or dryrun.

.EXAMPLE

PS> Start-HostsShutDown -Server <VxM IP or FQDN> -Username <username> -Password <password> -Sn <sn> -Dryrun -EvacuatePoweredOffVms

Shutdown host with dryrun.
#>
function Start-HostsShutDown {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        # VxM IP or FQDN
        [String] $Server,

        [Parameter(Mandatory = $true)]
        # Valid vCenter username which has either Administrator or HCIA role
        [String] $Username,

        [Parameter(Mandatory = $true)]
        # Use corresponding password for username
        [String] $Password,

        [Parameter(Mandatory = $false)]
        # Print JSON style format
        [switch] $Format,

        [Parameter(Mandatory = $true)]
        # The sn of node
        [String] $Sn,

        [Parameter(Mandatory = $false)]
        # To run disk addition validation only
        [switch] $Dryrun,

        [Parameter(Mandatory = $false)]
        # Evacuate powered off vms for this node
        [switch] $EvacuatePoweredOffVms
    )

    $uri = -join ("/rest/vxm/v1/hosts/",$sn,"/shutdown")
	# write-host "This is URL $uri"

    $body = @{
        "dryrun" = if ($Dryrun) {"true"} else {"false"}
	    "evacuatePoweredOffVms" = if ($EvacuatePoweredOffVms) {"true"} else {"false"}
    } 
        
    $body = $body | ConvertTo-Json
	# write-host "This is the body $body"
    try{
        $ret = doPost -Server $server -Api $uri -Username $username -Password $password -Body $body
        if($Format) {
            $ret = $ret | ConvertTo-Json 
        }
        return $ret
    } catch {
        write-host $_
    }
}