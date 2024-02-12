$currentPath = $PSScriptRoot.Substring(0,$PSScriptRoot.LastIndexOf("\"))
$currentVersion = $PSScriptRoot.Substring($PSScriptRoot.LastIndexOf("\") + 1, $PSScriptRoot.Length - ($PSScriptRoot.LastIndexOf("\") + 1))
$commonPath = $currentPath.Substring(0,$currentPath.LastIndexOf("\")) + "\VxRail.API.Common\" + $currentVersion + "\VxRail.API.Common.ps1"

. "$commonPath"


<#
.SYNOPSIS

Get cluster info and appliance basic info list.

.NOTES

You can run this cmdlet to get cluster info and appliance basic info list.

.EXAMPLE

PS>Get-Cluster -Server <VxM IP or FQDN> -Username <username> -Password <password>

Get cluster info and appliance basic info list.

#>
function Get-Cluster {
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
        [switch] $Format
    )

    $uri = "/rest/vxm/v1/cluster"
    try{ 
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
.Synopsis
Shuts down a cluster or performs a shutdown dry run.

.Parameter Server
VxM IP or FQDN.

.Parameter Username
Valid vCenter username which has either Administrator or HCIA role.

.Parameter Password
Use corresponding password for username.

.Parameter Format
Print JSON style format.

.Parameter Dryrun
Perform a dry run to check whether it's safe to shutdown.

.Notes
You can run this cmdlet to shuts down a cluster or performs a shutdown dry run.

.Example
C:\PS>Start-ClusterShutdown -Server <vxm ip or FQDN> -Username <username> -Password <password>

Shut down a cluster.

.Example
C:\PS>Start-ClusterShutdown -Server <vxm ip or FQDN> -Username <username> -Password <password> -Dryrun

Shut down a cluster with dryrun.
#>
function Start-ClusterShutdown {
    param(
        # VxRail Manager IP address or FQDN
        [Parameter(Mandatory = $true)]
        [String] $Server,
        
        # User name in vCenter
        [Parameter(Mandatory = $true)]
        [String] $Username,
        
        # password for the vCenter
        [Parameter(Mandatory = $true)]
        [String] $Password,
        
        # Formatting the output
        [Parameter(Mandatory = $false)]
        [Switch] $Format,

        # Performs VxRail Cluster Shutdown dry run
        # Default is false. 
        [Parameter(Mandatory = $false)]
        [Switch] $Dryrun
    )

    $uri = "/rest/vxm/v1/cluster/shutdown"

    # Body content to post and update
    $body = @{
        "dryrun" = if($Dryrun){"true"} else{"false"}
    } | ConvertTo-Json

    try{ 
        $ret = doPost -Server $Server -Api $uri -Username $Username -Password $Password -Body $body
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
Removes a host from cluster.

.Parameter Server
VxM IP or FQDN.

.Parameter Username
Valid vCenter username which has either Administrator or HCIA role.

.Parameter Password
Use corresponding password for username.

.Parameter Format
Print JSON style format.

.Parameter VcAdminUserUsername
Username of the vCenter Admin user account

.Parameter VcAdminUserPassword
Password of the vCenter Admin user account

.Parameter VcsaRootUserUsername
Username of the VCSA Root user.

.Parameter VcsaRootUserPassword
Password of the VCSA Root user.

.Parameter SerialNumber
Host serial number.

.Notes
You can run this cmdlet to removes a host from cluster.

.Example
C:\PS>Remove-ClusterHost -Server <vxm ip or FQDN> -Username <username> -Password <password> -vcAdminUserUsername <vc admin user username> -VcAdminUserPassword <vc admin user password> -VcsaRootUserUsername <vcsa root user username> -VcsaRootUserPassword <vcsa root user password> -SerialNumber <serial number>

Remove a host from cluster.
#>
function Remove-ClusterHost {  
    param(
        # VxRail Manager IP address or FQDN
        [Parameter(Mandatory = $true)]
        [String] $Server,
        
        # User name in vCenter
        [Parameter(Mandatory = $true)]
        [String] $Username,
        
        # password for the vCenter
        [Parameter(Mandatory = $true)]
        [String] $Password,
        
        # Formatting the output
        [Parameter(Mandatory = $false)]
        [Switch] $Format,
     
        # Username of vcAdminUser
        [Parameter(Mandatory = $true)]
        [String] $VcAdminUserUsername,

        # Password of vcAdminUser
        [Parameter(Mandatory = $true)]
        [String] $VcAdminUserPassword,

        # Username of vcsaRootUser
        [Parameter(Mandatory = $true)]
        [String] $VcsaRootUserUsername,
        
        # Password of vcsaRootUser
        [Parameter(Mandatory = $true)]
        [String] $VcsaRootUserPassword,

        #serial number
        [Parameter(Mandatory = $true)]
        [String] $SerialNumber   
    )

    $uri = "/rest/vxm/v1/cluster/remove-host"
    
    # Body content to post
    $body = @{
        "serial_number" = $SerialNumber
        "vc_admin_user" = @{
            "username" = $VcAdminUserUsername
            "password" = $VcAdminUserPassword
        } 
        "vcsa_root_user" = @{
            "username" = $VcsaRootUserUsername
            "password" = $VcsaRootUserPassword
        }
    } | ConvertTo-Json

    try{ 
        $ret = doPost -Server $Server -Api $uri -Username $Username -Password $Password -Body $body
        if($Format) {
            $ret = $ret | ConvertTo-Json
        }
        return $ret
    } catch {
        write-host $_
    }
}
