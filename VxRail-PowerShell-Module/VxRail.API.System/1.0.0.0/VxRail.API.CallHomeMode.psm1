$currentPath = $PSScriptRoot.Substring(0,$PSScriptRoot.LastIndexOf("\"))
$currentVersion = $PSScriptRoot.Substring($PSScriptRoot.LastIndexOf("\") + 1, $PSScriptRoot.Length - ($PSScriptRoot.LastIndexOf("\") + 1))
$commonPath = $currentPath.Substring(0,$currentPath.LastIndexOf("\")) + "\VxRail.API.Common\" + $currentVersion + "\VxRail.API.Common.ps1"

. "$commonPath"
#. ".\VxRail.API.System.format.ps1xml"


<#
.Synopsis
Get the callhome mode status.

.Parameter Server
VxM IP or FQDN.

.Parameter Username
Valid vCenter username which has either Administrator or HCIA role.

.Parameter Password
Use corresponding password for username.

.Parameter Format
Print JSON style format.

.NOTES
You can run this cmdlet to get the callhome mode status.

.Example
C:\PS>Get-CallHomeMode -Server <vxm ip or FQDN> -Username <username> -Password <password>

Retrieves the call home mode status.
#>
function Get-CallHomeMode {
    param(
        # VxManager ip address or FQDN
        [Parameter(Mandatory = $true)]
        [string] $Server,
        
        # User name in vCenter
        [Parameter(Mandatory = $true)]
        [String] $Username,
        
        # password for the vCenter
        [Parameter(Mandatory = $true)]
        [String] $Password,
        
        # need good format
        [Parameter(Mandatory = $false)]
        [Switch] $Format
    )

    $uri = "/rest/vxm/v1/callhome/mode"
    try{ 
        $ret = doGet -Server $Server -Api $uri -Username $Username -Password $Password
        if($Format) {
            $ret = $ret | ConvertTo-Json
        }
        return $ret
    } catch {
        write-host $_
    }
}


<#
.Synopsis
Update the callhome mode status.

.Parameter Server
VxRail Manager IP address or FQDN.

.Parameter Username
Valid vCenter username which has either Administrator or HCIA role.

.Parameter Password
Use corresponding password for username.

.Parameter IsMuted
Specify the "is_muted" property for callhome Mode.

.NOTES
You can run this cmdlet to update the callhome mode status.

.Example
C:\PS>Update-CallHomeMode -Server <vxm ip or FQDN> -Username <username> -Password <password> -IsMuted 

Update "is_muted" property of callhome mode to "true".

.Example
C:\PS>Update-CallHomeMode -Server <vxm ip or FQDN> -Username <username> -Password <password>

Update "is_muted" property of callhome mode to "false"
#>
function Update-CallHomeMode {
    param(
        # VxManager ip address or FQDN
        [Parameter(Mandatory = $true)]
        [string] $Server,
        
        # User name in vCenter
        [Parameter(Mandatory = $true)]
        [String] $Username,
        
        # password for the vCenter
        [Parameter(Mandatory = $true)]
        [String] $Password,

        # specify the "is_muted" property for callhome Mode
        [Parameter(Mandatory = $false)]
        [Switch] $IsMuted
    )

    $uri = "/rest/vxm/v1/callhome/mode"

    # Body content: Support PUT "is_muted" property 
    $Body = @{
        "is_muted" = if($IsMuted) {"true"} else{"false"}
    } | ConvertTo-Json

    try{  
        $ret = doPut -Server $Server -Api $uri -Username $Username -Password $Password -Body $Body
        return $ret
    } catch {
        write-host $_
    }
}