$currentPath = $PSScriptRoot.Substring(0,$PSScriptRoot.LastIndexOf("\"))
$currentVersion = $PSScriptRoot.Substring($PSScriptRoot.LastIndexOf("\") + 1, $PSScriptRoot.Length - ($PSScriptRoot.LastIndexOf("\") + 1))
$commonPath = $currentPath.Substring(0,$currentPath.LastIndexOf("\")) + "\VxRail.API.Common\" + $currentVersion + "\VxRail.API.Common.ps1"

. "$commonPath"
#. ".\VxRail.API.System.format.ps1xml"


<#
.Synopsis
Retrieves information on available hosts in the VxRail cluster.

.Parameter Server
VxM IP or FQDN.

.Parameter Username
Valid vCenter username which has either Administrator or HCIA role.

.Parameter Password
Use corresponding password for username.

.Parameter Filter
Query conditions for searching for the host.
The following operators are supported: equal (eq), not equal (ne) on the following fields: 
id, appliance_id, slot, model, is_primary_node, bios_uuid, cluster_affinity.
For example: "id eq VXRAILVIP470F2-01-01 and slot ne 2".

.Parameter Format
Print JSON style format.

.Notes
You can run this cmdlet to retrieves information on available hosts in the VxRail cluster.

.Example
C:\PS>Get-SystemAvailableHosts -Server <vxm ip or FQDN> -Username <username> -Password <password>

Retrieves information on available hosts in the VxRail cluster without filter.

.Example
C:\PS>Get-SystemAvailableHosts -Server <vxm ip or FQDN> -Username <username> -Password <password> -Filter <filter>

Retrieves information on available hosts in the VxRail cluster with filter, example: -Filter "id eq VXRAILVIP470F2-01-01 and slot ne 2"
#>
function Get-SystemAvailableHosts {
    param(
		# VxM IP or FQDN
        [Parameter(Mandatory = $true)]
        [String] $Server,
																	
        # Valid vCenter username which has either Administrator or HCIA role
        [Parameter(Mandatory = $true)]
        [String] $Username,
										 
        # Use corresponding password for username
        [Parameter(Mandatory = $true)]
        [String] $Password,

        # Query conditions for searching for the host.
        [Parameter(Mandatory = $false)]
        [String] $Filter,

        # Print JSON style format
        [Parameter(Mandatory = $false)]
        [switch] $Format
    )

    $uri = "/rest/vxm/v1/system/available-hosts"

    #If $Filter is true, get hosts and filter it. Add the filter string to HTTP query string
    if ($Filter) {$uri += '?$filter=' + $Filter}

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
Retrieves information on configured hosts in the VxRail cluster.

.Parameter Server
VxM IP or FQDN.

.Parameter Username
Valid vCenter username which has either Administrator or HCIA role.

.Parameter Password
Use corresponding password for username.

.Parameter Filter
Query conditions for searching for the host.
The following operators are supported: equal (eq), not equal (ne) on the following fields: 
id, appliance_id, slot, model, is_primary_node, bios_uuid, cluster_affinity.
For example: "id eq VXRAILVIP470F2-01-01 and slot ne 2".

.Parameter Format
Print JSON style format.

.Notes
You can run this cmdlet to retrieve information on configured hosts in the VxRail cluster.

.Example
C:\PS>Get-SystemClusterHosts -Server <vxm ip or FQDN> -Username <username> -Password <password>

Retrieves information on configured hosts in the VxRail cluster without filter.

.Example
C:\PS>Get-SystemClusterHosts -Server <vxm ip or FQDN> -Username <username> -Password <password> -Filter <filter>

Retrieves information on configured hosts in the VxRail cluster with filter, example: -Filter "id eq VXRAILVIP470F2-01-01 and slot ne 2"
#>
function Get-SystemClusterHosts {
    param(
        # VxM IP or FQDN
        [Parameter(Mandatory = $true)]
        [String] $Server,

        # Valid vCenter username which has either Administrator or HCIA role
        [Parameter(Mandatory = $true)]
        [String] $Username,

        # Use corresponding password for username
        [Parameter(Mandatory = $true)]
        [String] $Password,

        # Query conditions for hosts.
        [Parameter(Mandatory = $false)]
        [String] $Filter,

        # Print JSON style format
        [Parameter(Mandatory = $false)]
        [switch] $Format
    )

    $uri = "/rest/vxm/v1/system/cluster-hosts"

    #If $Filter is true, get hosts and filter it. Add the filter string to HTTP query string
    if ($Filter) {$uri += '?$filter=' + $Filter}
    
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
