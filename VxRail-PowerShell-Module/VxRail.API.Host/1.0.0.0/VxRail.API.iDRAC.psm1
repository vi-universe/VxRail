$currentPath = $PSScriptRoot.Substring(0,$PSScriptRoot.LastIndexOf("\"))
$currentVersion = $PSScriptRoot.Substring($PSScriptRoot.LastIndexOf("\") + 1, $PSScriptRoot.Length - ($PSScriptRoot.LastIndexOf("\") + 1))
$commonPath = $currentPath.Substring(0,$currentPath.LastIndexOf("\")) + "\VxRail.API.Common\" + $currentVersion + "\VxRail.API.Common.ps1"

. "$commonPath"


<#
.SYNOPSIS
Retrieves a list of the available iDRAC user slot IDs.

.Parameter Server
VxM IP or FQDN.

.Parameter Username
Valid vCenter username which has either Administrator or HCIA role.

.Parameter Password
Use corresponding password for username.

.Parameter Format
Print JSON style format.

.Parameter Sn
The serial number of the host to be queried.

.NOTES
You can run this cmdlet to retrieve a list of the available iDRAC user slot IDs.

.EXAMPLE
PS> Get-iDRACUserIds -Server <VxM IP or FQDN> -Username <username> -Password <password> -Sn <sn>

Retrieves a list of the available iDRAC user slot IDs.
#>
function Get-iDRACUserIds {
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
        # The serial number of the host to be queried
        [String] $Sn
    )

    $uri = -join ("/rest/vxm/v1/hosts/",$sn,"/idrac/available-user-ids")

    try{ 
        $ret = doGet -Server $Server -Api $uri -Username $Username -Password $Password
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
Retrieves a list of created iDRAC user accounts on the specified host.

.Parameter Server
VxM IP or FQDN.

.Parameter Username
Valid vCenter username which has either Administrator or HCIA role.

.Parameter Password
Use corresponding password for username.

.Parameter Format
Print JSON style format.

.Parameter Sn
The serial number of the host to be queried.

.NOTES
You can run this cmdlet to retrieve a list of created iDRAC user accounts on the specified host.

.EXAMPLE
PS> Get-iDRACUsers -Server <VxM IP or FQDN> -Username <username> -Password <password> -Sn <sn>

Retrieves a list of created iDRAC user accounts on the specified host.
#>
function Get-iDRACUsers {
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
        # The serial number of the host to be queried
        [String] $Sn
    )

    $uri = -join ("/rest/vxm/v1/hosts/",$sn,"/idrac/users")

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
Create an iDRAC user account.

.Parameter Server
VxM IP or FQDN.

.Parameter Username
Valid vCenter username which has either Administrator or HCIA role.

.Parameter Password
Use corresponding password for username.

.Parameter Sn
The serial number of the host to be queried.

.Parameter UserId
The iDRAC user slot ID.

.Parameter iDRACUserName
The iDRAC user name.

.Parameter iDRACPassword
The iDRAC user password.

.Parameter iDRACPrivilege
The permissions (privilege) of the iDRAC user. Can be set to ADMIN, OPER, or READONLY.

.Parameter Format
Print JSON style format.

.Notes
You can run this cmdlet to create an iDRAC user account.

.EXAMPLE
PS> New-iDRACUser -Server <VxM IP or FQDN> -Username <username> -Password <password> -Sn <sn> -UserId <iDRAC user slot id> -iDRACUsername <iDRAC user name> -iDRACPasword <iDRAC user password> -iDRACPrivilege <iDRAC user privilege>

Create an iDRAC user account
#>
function New-iDRACUser {  
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

        # The serial number of the host to be queried
        [Parameter(Mandatory = $true)]
        [String] $Sn,

        # The iDRAC user slot ID
        [Parameter(Mandatory = $false)]
        [String] $UserId,

        # The iDRAC user name
        [Parameter(Mandatory = $true)]
        [String] $iDRACUsername,

        # The iDRAC user password
        [Parameter(Mandatory = $true)]
        [String] $iDRACPassword,

        # The permissions (privilege) of the iDRAC user. Can be set to ADMIN, OPER, or READONLY.
        [Parameter(Mandatory = $true,HelpMessage="Supported privilege: 'ADMIN','OPER','READONLY'")]
        [ValidateSet('ADMIN','OPER','READONLY')]
        [String] $iDRACPrivilege,
        
        # Print JSON style format
        [Parameter(Mandatory = $false)]
        [Switch] $Format
    )

    $uri = -join ("/rest/vxm/v1/hosts/",$sn,"/idrac/users")
    
    # Body content to post
    $body = @{
        "id" = $UserId
        "name" = $iDRACUsername
        "password" = $iDRACPassword
        "privilege" = $iDRACPrivilege
    } | ConvertTo-Json

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


<#
.Synopsis
Updates an iDRAC user account.

.Parameter Server
VxM IP or FQDN.

.Parameter Username
Valid vCenter username which has either Administrator or HCIA role.

.Parameter Password
Use corresponding password for username.

.Parameter Sn
The serial number of the host to be queried.

.Parameter UserId
The unique identifier of the iDRAC user.
The user ID range is 3 through 16.

.Parameter iDRACUserName
The iDRAC user name.

.Parameter iDRACPassword
The iDRAC user password.

.Parameter iDRACPrivilege
The permissions (privilege) of the iDRAC user. Can be set to ADMIN, OPER, or READONLY.

.Parameter Format
Print JSON style format.

.Notes
You can run this cmdlet to update an iDRAC user account.

.EXAMPLE
PS> Update-iDRACUser -Server <VxM IP or FQDN> -Username <username> -Password <password> -Sn <sn> -UserId <iDRAC user Id> -iDRACUsername <iDRAC user name> -iDRACPasword <iDRAC user password> -iDRACPrivilege <iDRAC user privilege>

Updates an iDRAC user account.
#>
function Update-iDRACUser {
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

        # The serial number of the host to be queried
        [Parameter(Mandatory = $true)]
        [String] $Sn,

        # The unique identifier of the iDRAC user. The user ID range is 3 through 16.
        [Parameter(Mandatory = $true)]
        [String] $UserId,

        # The iDRAC user name
        [Parameter(Mandatory = $true)]
        [String] $iDRACUsername,

        # The iDRAC user password
        [Parameter(Mandatory = $true)]
        [String] $iDRACPassword,

        # User account privilege of the iDRAC
        [Parameter(Mandatory = $true,HelpMessage="Supported privilege: 'ADMIN','OPER','READONLY'")]
        [ValidateSet('ADMIN','OPER','READONLY')]
        [String] $iDRACPrivilege,
        
        # Print JSON style format
        [Parameter(Mandatory = $false)]
        [Switch] $Format
    )

    $uri = -join ("/rest/vxm/v1/hosts/",$sn,"/idrac/users/",$UserId)
    
    # Body content to put
    $body = @{
        "name" = $iDRACUsername
        "password" = $iDRACPassword
        "privilege" = $iDRACPrivilege
    } | ConvertTo-Json

    try{
        $ret = doPut -Server $server -Api $uri -Username $username -Password $password -Body $body
        if($Format) {
            $ret = $ret | ConvertTo-Json 
        }
        return $ret
    } catch {
        write-host $_
    }
}


<#
.SYNOPSIS
Retrieves the iDRAC network settings on the specified host.

.Parameter Server
VxM IP or FQDN.

.Parameter Username
Valid vCenter username which has either Administrator or HCIA role.

.Parameter Password
Use corresponding password for username.

.Parameter Sn
The serial number of the host to be queried.

.Parameter Format
Print JSON style format.

.NOTES
You can run this cmdlet to retrieve the iDRAC network settings on the specified host.

.EXAMPLE
PS> Get-iDRACNetwork -Server <VxM IP or FQDN> -Username <username> -Password <password> -Sn <sn>

Retrieves the iDRAC network settings on the specified host.
#>
function Get-iDRACNetwork {
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

        [Parameter(Mandatory = $true)]
        # The serial number of the host to be queried
        [String] $Sn,

        [Parameter(Mandatory = $false)]
        # Print JSON style format
        [switch] $Format
    )

    $uri = -join ("/rest/vxm/v1/hosts/",$sn,"/idrac/network")

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
Updates the iDRAC network settings on the specified host.

.Parameter Server
VxM IP or FQDN.

.Parameter Username
Valid vCenter username which has either Administrator or HCIA role.

.Parameter Password
Use corresponding password for username.

.Parameter Sn
The serial number of the host to be queried.

.Parameter IpType
The VLAN id setting for the iDRAC network. Only IPv4 is supported in the current version.

.Parameter IpAddress
The MAC address of the iDRAC.

.Parameter Netmask
The netmask for the iDRAC.

.Parameter Gateway
The gateway for the iDRAC network.

.Parameter DhcpEnabled
Sets if DHCP service is enabled or not.

.Parameter VlanId
The VLAN ID setting of the iDRAC. 0 means disabled.

.Parameter VlanPriority
The VLAN priority of the iDRAC.

.Parameter Format
Print JSON style format.

.Notes
You can run this cmdlet to update the iDRAC network settings on the specified host.

.Example
PS> Update-iDRACNetwork -Server <VxM IP or FQDN> -Username <username> -Password <password> -Sn <sn> -DhcpEnabled <dhcp enable> -VlanId <vlan id> -VlanPriority <vlan priority>

Updates the iDRAC network settings on the specified host with DHCP enabled.

.Example
PS> Update-iDRACNetwork -Server <VxM IP or FQDN> -Username <username> -Password <password> -Sn <sn> -IpType <ip type> -IpAddress <ip address> -Netmask <ip netmask> -Gateway <ip gateway> -VlanId <vlan id> -VlanPriority <vlan priority>

Updates the iDRAC network settings on the specified host with DHCP disabled.
#>
function Update-iDRACNetwork {  
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

        # The serial number of the host to be queried
        [Parameter(Mandatory = $true)]
        [String] $Sn,

        # The VLAN id setting for the iDRAC network. Only IPv4 is supported in the current version
        [Parameter(Mandatory = $false,HelpMessage="Only IPv4 is supported in the current version")]
        [String] $IpType,

        # The MAC address of the iDRAC
        [Parameter(Mandatory = $false)]
        [String] $IpAddress,

        # The netmask for the iDRAC
        [Parameter(Mandatory = $false)]
        [String] $Netmask,

        # The gateway for the iDRAC network
        [Parameter(Mandatory = $false)]
        [String] $Gateway,

        # Sets if DHCP service is enabled or not
        [Parameter(Mandatory = $false,HelpMessage="Supported parameter: 'TRUE','FALSE'")]
        [ValidateSet('TRUE','FALSE')]
        [string] $DhcpEnabled,

        # The VLAN ID setting of the iDRAC. 0 means disabled
        [Parameter(Mandatory = $false)]
        [String] $VlanId,

        # The VLAN priority of the iDRAC
        [Parameter(Mandatory = $false)]
        [String] $VlanPriority,
        
        # Formatting the output
        [Parameter(Mandatory = $false)]
        [Switch] $Format
    )

    $uri = -join ("/rest/vxm/v1/hosts/",$sn,"/idrac/network")

    # Body content to patch
    $body = @{
    }

    if($VlanId -or $VlanPriority){
        $VlanObj = @{
        }
        $body.add("vlan",$VlanObj)
    }
    if($VlanId){
        $body.vlan.add("vlan_id",$VlanId)
    }
    if($VlanPriority){
        $body.vlan.add("vlan_priority",$VlanPriority)
    }

    if($IpType -or $IpAddress -or $Netmask -or $Gateway){
        $IpObj = @{
        }
        $body.add("ip",$IpObj)
    }
    if($IpType){
        $body.ip.add("type",$IpType)
    }
    if($IpAddress){
        $body.ip.add("ip_address",$IpAddress)
    }
    if($Netmask){
        $body.ip.add("netmask",$Netmask)
    }
    if($Gateway){
        $body.ip.add("gateway",$Gateway)
    }

    # if DhcpEnabled is exist, add it to body
    if($DhcpEnabled){
        if($DhcpEnabled -match "true"){
            $body.add("dhcp_enabled","true")
        }
        if($DhcpEnabled -match "false"){
            $body.add("dhcp_enabled","false")
        }
    }

    $body = $body | ConvertTo-Json 

    try{
        $ret = doPatch -Server $server -Api $uri -Username $username -Password $password -Body $body
        if($Format) {
            $ret = $ret | ConvertTo-Json 
        }
        return $ret
    } catch {
        write-host $_
    }
}