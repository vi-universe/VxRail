$currentPath = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf("\"))
$currentVersion = $PSScriptRoot.Substring($PSScriptRoot.LastIndexOf("\") + 1, $PSScriptRoot.Length - ($PSScriptRoot.LastIndexOf("\") + 1))
$commonPath = $currentPath.Substring(0, $currentPath.LastIndexOf("\")) + "\VxRail.API.Common\" + $currentVersion + "\VxRail.API.Common.ps1"

. "$commonPath"

<#
.Synopsis
Get the vxm system info.

.Parameter Server
VxM IP or FQDN.

.Parameter Username
Valid vCenter username which has either Administrator or HCIA role. 

.Parameter Password
Use corresponding password for username. 

.Parameter Format
Print JSON style format.

.Notes
You can run this cmdlet to get the vxm system info.

.Example
C:\PS>Get-SystemInfo -Server <vxm ip or FQDN> -Username <username> -Password <password>

Get the vxm system info.
#>
function Get-SystemInfo {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Server,

        [Parameter(Mandatory = $true)]
        [String] $Username,
        
        [Parameter(Mandatory = $true)]
        [String] $Password,
        
        [Parameter(Mandatory = $false)]
        [Switch] $Format
    )

    $uri = "/rest/vxm/v1/system"
    try { 
        $ret = doGet -Server $Server -Api $uri -Username $Username -Password $Password
        if ($Format) {
            $ret = $ret | ConvertTo-Json
        }
        return $ret
    }
    catch {
        write-host $_
    }
}



<#
.Synopsis
Validates the supplied user credentials.

.Parameter Server
VxM IP or FQDN.

.Parameter Username
Valid vCenter username which has either Administrator or HCIA role. 

.Parameter Password
Use corresponding password for username.

.Parameter VxmRootUsername
VxRail Manager root user name.

.Parameter VxmRootPassword
VxRail Manager root user password.

.Parameter VcAdminUsername
vCenter admin user name.

.Parameter VcAdminPassword
vCenter admin user password.

.Parameter VcsaRootUsername
VCSA root user name. Required if the upgrade bundle contains vcenter component

.Parameter VcsaRootPassword
VCSA root user password.

.Parameter PscRootUsername
PSC root user name.

.Parameter PscRootPassword
PSC root user password.

.Parameter HostsSn
The serial number of the host to be validate.

.Parameter HostsUsername
Host user name.

.Parameter HostsPassword
Host user password.

.Parameter WitnessUsername
Witness user name.

.Parameter WitnessPassword
Witness user password.

.Parameter Format
Print JSON style format.

.Notes
You can run this cmdlet to validate the supplied user credentials.

.Example
C:\PS>Confirm-SystemCredential -Server <vxm ip or FQDN> -Username <username> -Password <password> -VxmRootUsername <vxm root user> -VxmRootPassword <vxm root password>

Validates the one supplied user credential.

.Example
C:\PS>Confirm-SystemCredential -Server <vxm ip or FQDN> -Username <username> -Password <password> -Format <Format> -VxmRootUsername <vxm root user> -VxmRootPassword <vxm root password> -VcAdminUsername <vc admin user> -VcAdminPassword <vc admin password> -VcsaRootUsername <vcsa root username> -VcsaRootPassword <vcsa root password> -PscRootUsername <psc root user> -PscRootPassword <psc root password> -HostsSn <HostsSn> -HostsUsername <HostsUsername> -HostsPassword <HostsPassword> -WitnessUsername <witness username>  -WitnessPassword <witness password> 

Validates the multiple supplied user credentials.
#>

function Confirm-SystemCredential {
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

        # VxRail Manager root user name
        [Parameter(Mandatory = $false)]
        [String] $VxmRootUsername,

        # VxRail Manager root user password
        [Parameter(Mandatory = $false)]
        [String] $VxmRootPassword,

        # vCenter admin user name
        [Parameter(Mandatory = $false)]
        [String] $VcAdminUsername,

        # vCenter admin user password
        [Parameter(Mandatory = $false)]
        [String] $VcAdminPassword,

        # VCSA root user name
        [Parameter(Mandatory = $false)]
        [String] $VcsaRootUsername,

        # VCSA root user password
        [Parameter(Mandatory = $false)]
        [String] $VcsaRootPassword,
        
        # PSC root user name
        [Parameter(Mandatory = $false)]
        [String] $PscRootUsername,

        # PSC root user password
        [Parameter(Mandatory = $false)]
        [String] $PscRootPassword,

        # The serial number of the host to be validate
        [Parameter(Mandatory = $false)]
        [String] $HostsSn, 

        # Host user name
        [Parameter(Mandatory = $false)]
        [String] $HostsUsername, 
           
        # Host user password
        [Parameter(Mandatory = $false)]
        [String] $HostsPassword,

        # Witness user name
        [Parameter(Mandatory = $false)]
        [String] $WitnessUsername,

        # Witness user nam password
        [Parameter(Mandatory = $false)]
        [String] $WitnessPassword,

        # Print JSON style format
        [Parameter(Mandatory = $false)]
        [switch] $Format
    )

    $uri = "/rest/vxm/v1/system/validate-credential"
    
    # Add non-mandatory information to body, $Body.count must get 1
    $Body = @{ }

    # if user entered vxm root user account, add it to body
    if ($VxmRootUsername -and $VxmRootPassword) {
        $VxmRootObj = @{
            "vxm_root_user" = @{
                "username" = $VxmRootUsername
                "password" = $VxmRootPassword
            }
        }
        $Body.add("vxrail", $VxmRootObj)
    }

    # if user entered vcenter admin user account, add it to body
    if ($VcAdminUsername -and $VcAdminPassword) {
        $VcAdminObj = @{
            "vc_admin_user" = @{
                "username" = $VcAdminUsername
                "password" = $VcAdminPassword
            }
        }
        $Body.add("vcenter", $VcAdminObj)
    }

    # if user entered vcsa root user account, add it to body
    if ($VcsaRootUsername -and $VcsaRootPassword) {
        $VcsaRootObj = @{
            "vcsa_root_user" = @{
                "username" = $VcsaRootUsername
                "password" = $VcsaRootPassword
            }
        }
        $Body.add("vcenter", $VcsaRootObj)
    }

    # if user entered psc root user account, add it to body
    if ($PscRootUsername -and $PscRootPassword) {
        $PscRootObj = @{
            "psc_root_user" = @{
                "username" = $PscRootUsername
                "password" = $PscRootPassword
            }
        }
        $Body.add("vcenter", $PscRootObj)
    }

    # if user entered ESXi host info, add it to body
    if ($HostsSn -and $HostsUsername -and $HostsPassword) {
        $HostsObj = @{
            "sn" = $HostsSn
            "root_user" = @{
                "username" = $HostsUsername
                "password" = $HostsPassword
            }
        }
        $Body.add("hosts", @($HostsObj))
    }

    # if user entered witness info, add it to body
    if ($WitnessUsername -and $WitnessPassword) {
        $WitnessObj = @{
            "witness_user" = @{
                "usernmae" = $WitnessUsername
                "password" = $WitnessPassword
            }
        }
        $Body.add("witness-user", $WitnessObj)
    }

    if ($Body.Count -lt 1) {
        Write-Host "Credentials input for validation is required."
        Break
    }

    # Convert Body to JSON format
    $Body = $Body | ConvertTo-Json -Depth 3

    # Write-Host $Body

    try {
        $ret = doPost -Server $server -Api $uri -Username $username -Password $password -Body $body
        if ($Format) {
            $ret = $ret | ConvertTo-Json
        }
        return $ret
    }
    catch {
        write-host $_
    }
}


<#
.Synopsis
Updates the vCenter and ESXi hosts management user passwords stored in VxRail Manager.

.Parameter Server
VxM IP or FQDN.

.Parameter Username
Valid vCenter username which has either Administrator or HCIA role. 

.Parameter Password
Use corresponding password for username. 

.Parameter ComponentName
Component Name.

.Parameter ComponentHostName
Host Name for Component.

.Parameter ComponentUsername
Component user name.

.Parameter ComponentPassword
Use corresponding password for component user.

.Parameter Format
Print JSON style format.

.Notes
You can run this cmdlet to update the vCenter and ESXi hosts management user passwords stored in VxRail Manager.

.Example
C:\PS>Update-SystemCredential -Server <vxm ip or FQDN> -Username <username> -Password <password> -ComponentName <component name> -ComponentHostName <component host name> -ComponentUsername <component user name> -ComponentPassword <component user password>

Updates the vCenter and ESXi hosts management user passwords stored in VxRail Manager. 

.Example
C:\PS>Update-SystemCredential -Server <vxm ip or FQDN> -Username <username> -Password <password> -ComponentName c1,c2 -ComponentHostName h1,h2 -ComponentUsername u1,u2 -ComponentPassword p1,p2

Updates the vCenter and ESXi hosts management user passwords stored in VxRail Manager. 
#>
function Update-SystemCredential {
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
 
        # Component Name
        [Parameter(Mandatory = $false)]
        [String[]] $ComponentName = "",

        # Host Name for Component
        [Parameter(Mandatory = $false)]
        [String[]] $ComponentHostName = "",

        # Component user name
        [Parameter(Mandatory = $false)]
        [String[]] $ComponentUsername = "",

        # Use corresponding password for component user
        [Parameter(Mandatory = $false)]
        [String[]] $ComponentPassword = "",

        # Print JSON style format
        [Parameter(Mandatory = $false)]
        [switch] $Format
    )

    $uri = "/rest/vxm/v1/system/update-credential"
    
    # Add mandatory information to body
    $Body = @()

    $n = ($ComponentName.Count, $ComponentHostName.Count,$ComponentUsername.Count,$ComponentPassword.Count) | Measure-Object -Minimum -Maximum

    for ($i = 0; $i -lt $n.Maximum; $i++) {
            $ComponentObj = @{
                "component" = $ComponentName[$i]
                "hostname"  = $ComponentHostName[$i]
                "username"  = $ComponentUsername[$i]
                "password"  = $ComponentPassword[$i]
            } 
            $Body += $ComponentObj
        }
   
    $Body = ConvertTo-Json @($Body)

    try {
        # $ret = Invoke-RestMethod -Method 'POST' -Uri $url -Headers $headers -Body $Body -ContentType "application/json" -TimeoutSec 300
        $ret = doPost -Server $server -Api $uri -Username $username -Password $password -Body $body
        if ($Format) {
            $ret = $ret | ConvertTo-Json
        }
        return $ret
    }
    catch {
        $response = $_.Exception.Response
        $status = $response.StatusCode.value__
        if($status -eq 500) {
            $body = $response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($body)
            $reader.BaseStream.Position = 0
            $reader.DiscardBufferedData()
            $ret = $reader.ReadToEnd() | ConvertFrom-Json
            if ($Format) {
                if($ret.Length -le 1) {
                    $ret = "[{0}]" -f ($ret | ConvertTo-Json)
                } else {
                    $ret = $ret | ConvertTo-Json
                }
            }
            return $ret
        } else {
            write-host $_
        }
    }
}