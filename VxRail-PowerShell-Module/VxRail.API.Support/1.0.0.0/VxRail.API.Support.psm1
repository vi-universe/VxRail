$currentPath = $PSScriptRoot.Substring(0,$PSScriptRoot.LastIndexOf("\"))
$currentVersion = $PSScriptRoot.Substring($PSScriptRoot.LastIndexOf("\") + 1, $PSScriptRoot.Length - ($PSScriptRoot.LastIndexOf("\") + 1))
$commonPath = $currentPath.Substring(0,$currentPath.LastIndexOf("\")) + "\VxRail.API.Common\" + $currentVersion + "\VxRail.API.Common.ps1"

. "$commonPath"
#. ".\VxRail.API.System.format.ps1xml"


<#
.Synopsis
Query a list of URI to create service request.

.Parameter Server
VxM IP or FQDN.

.Parameter Username
Valid vCenter username which has either Administrator or HCIA role. 

.Parameter Password
Use corresponding password for username. 

.Parameter Format
Print JSON style format.

.Notes
You can run this cmdlet to query a list of URI to create service request.

.Example
C:\PS>Get-SupportServiceRequests -Server <vxm ip or FQDN> -Username <username> -Password <password>

Retrieves links for opening Service Requests (SRs). One link per node.
#>
function Get-SupportServiceRequests {
    param (
        # VxRail Manager IP address or FQDN
        [Parameter(Mandatory = $true)]
        [string] $Server,
        
        # User name from vCenter Server
        [Parameter(Mandatory = $true)]
        [String] $Username,
        
        # password for the vCenter
        [Parameter(Mandatory = $true)]
        [String] $Password,

        # Formatting the output
        [Parameter(Mandatory = $false)]
        [Switch] $Format
    )

    $uri = "/rest/vxm/v1/support/service-requests"
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
Get a link for online chat with Support.

.Parameter Server
VxM IP or FQDN.

.Parameter Username
Valid vCenter username which has either Administrator or HCIA role. 

.Parameter Password
Use corresponding password for username. 

.Parameter Format
Print JSON style format.

.Notes
You can run this cmdlet to get a link for online chat with Support.

.Example
C:\PS>Get-SupportChatURL -Server <vxm ip or FQDN> -Username <username> -Password <password>

Get support chat url.
#>
function Get-SupportChatURL {
    param (
        # VxRail Manager IP address or FQDN
        [Parameter(Mandatory = $true)]
        [string] $Server,
        
        # User name from vCenter Server
        [Parameter(Mandatory = $true)]
        [String] $Username,
        
        # password for the vCenter
        [Parameter(Mandatory = $true)]
        [String] $Password,

        # Formatting the output
        [Parameter(Mandatory = $false)]
        [Switch] $Format
    )

    $uri = "/rest/vxm/v1/support/chat-url"
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