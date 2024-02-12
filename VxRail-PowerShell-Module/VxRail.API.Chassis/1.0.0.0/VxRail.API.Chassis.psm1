$currentPath = $PSScriptRoot.Substring(0,$PSScriptRoot.LastIndexOf("\"))
$currentVersion = $PSScriptRoot.Substring($PSScriptRoot.LastIndexOf("\") + 1, $PSScriptRoot.Length - ($PSScriptRoot.LastIndexOf("\") + 1))
$commonPath = $currentPath.Substring(0,$currentPath.LastIndexOf("\")) + "\VxRail.API.Common\" + $currentVersion + "\VxRail.API.Common.ps1"

. "$commonPath"


<#
.SYNOPSIS

Get chassis list & every node info for each chassis.

.PARAMETER Name

Specifies the file name.

.NOTES

You can run this cmdlet to get chassis info.

.EXAMPLE

PS> Get-Chassis -Server <VxM IP or FQDN> -Username <username> -Password <password>

Get chassis list & every node info for each chassis.

.EXAMPLE

PS> Get-Chassis -Server <VxM IP or FQDN> -Username <username> -Password <password> -ChassisId <chassisId>

Get specific chassis info.
#>
function Get-Chassis {
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
        # Chassis id
        [String] $ChassisId 
    )

    $uri = "/rest/vxm/v1/chassis"
    try{ 
        if($ChassisId){
            $uri = "/rest/vxm/v1/chassis/$ChassisId"
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
