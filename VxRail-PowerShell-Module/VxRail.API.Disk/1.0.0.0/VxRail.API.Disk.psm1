$currentPath = $PSScriptRoot.Substring(0,$PSScriptRoot.LastIndexOf("\"))
$currentVersion = $PSScriptRoot.Substring($PSScriptRoot.LastIndexOf("\") + 1, $PSScriptRoot.Length - ($PSScriptRoot.LastIndexOf("\") + 1))
$commonPath = $currentPath.Substring(0,$currentPath.LastIndexOf("\")) + "\VxRail.API.Common\" + $currentVersion + "\VxRail.API.Common.ps1"

. "$commonPath"


<#
.SYNOPSIS

Get disk info list.

.NOTES

You can run this cmdlet to get disk info list.

.EXAMPLE

PS> Get-Disks -Server <VxM IP or FQDN> -Username <username> -Password <password>

Get disk info list.

.EXAMPLE

PS> Get-Disks -Server <VxM IP or FQDN> -Username <username> -Password <password> -DiskSn <disk serial number>

Get specific disk info.
#>
function Get-Disks {
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
        # The sn of disk
        [String] $DiskSn
    )

    $uri = "/rest/vxm/v1/disks"
    try{ 
        if($DiskSn){
            $uri = "/rest/vxm/v1/disks/$DiskSn"
        }
        $ret = doGet -Server $server -Api $uri -Username $username -Password $password
        if($Format) {
            $ret = $ret | ConvertTo-Json
        }
        return $ret
    } catch {
        write-host $_
    }
    
}