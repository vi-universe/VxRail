$currentPath = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf("\"))
$currentVersion = $PSScriptRoot.Substring($PSScriptRoot.LastIndexOf("\") + 1, $PSScriptRoot.Length - ($PSScriptRoot.LastIndexOf("\") + 1))
$commonPath = $currentPath.Substring(0, $currentPath.LastIndexOf("\")) + "\VxRail.API.Common\" + $currentVersion + "\VxRail.API.Common.ps1"

. "$commonPath"
#. ".\VxRail.API.System.format.ps1xml"


<#
.Synopsis
Retrieves information about the callhome servers.

.Parameter Server
VxM IP or FQDN.

.Parameter Username
Valid vCenter username which has either Administrator or HCIA role.

.Parameter Password
Use corresponding password for username.

.Parameter Format
Print JSON style format.

.Parameter Version
Optional. API version. Only input v1 or v2. Default value is v1.

.NOTES
You can run this cmdlet to retrieve information about the callhome servers.

.Example
C:\PS>Get-CallHomeInfo -Server <vxm ip or FQDN> -Username <username> -Password <password>

Retrieves information about the callhome servers.
#>
function Get-CallHomeInfo {
    param(
        # VxM IP or FQDN
        [Parameter(Mandatory = $true)]
        [string] $Server,

        # Valid vCenter username which has either Administrator or HCIA role
        [Parameter(Mandatory = $true)]
        [String] $Username,

        # Use corresponding password for username
        [Parameter(Mandatory = $true)]
        [String] $Password,

        # Print JSON style format
        [Parameter(Mandatory = $false)]
        [Switch] $Format,

        # The API version, default is v1
        [Parameter(Mandatory = $false)]
        [String] $Version = "v1"
    )

    # version check
    if (($Version -ne "v1") -and ($Version -ne "v2")) {
        write-host "The inputted Version $Version is invalid." -ForegroundColor Red
        return
    }

    $uri = "/rest/vxm/" + $Version.ToLower() + "/callhome/info"

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
Deploys an internal callhome server.

.Parameter Server
VxM IP or FQDN.

.Parameter Username
Valid vCenter username which has either Administrator or HCIA role.

.Parameter Password
Use corresponding password for username.

.Parameter IP
Callhome IP. Support in v1.

.Parameter Address
Callhome Address. Support in v2.

.Parameter SiteID
Callhome site ID.

.Parameter FirstName
Callhome first name.

.Parameter LastName
Callhome last name.

.Parameter Email
Callhome email.

.Parameter Phone
Callhome phone.

.Parameter Company
Callhome company.

.Parameter RootPassword
Use corresponding password for root user.

.Parameter AdminPassword
Use corresponding password for admin user.

.Parameter Format
Print JSON style format.

.Parameter Version
Optional. API version. Only input v1 or v2. Default value is v1.

.NOTES
You can run this cmdlet to deploy an internal callhome server.

.Example
C:\PS>Publish-CallHomeServer -Server <vxm ip or FQDN> -Username <username> -Password <password> -IP <callhome ip> -SiteID <callhome site ID> -FirstName <callhome first name> -LastName <callhome last name> -Email <callhome email> -Phone <callhome phone> -Company <callhome company> -RootPassword <root user password> -AdminPassword <admin user password>

Deploys an internal callhome server.
#>
function Publish-CallHomeServer {
    param(
        # VxM IP or FQDN
        [Parameter(Mandatory = $true)]
        [string] $Server,

        # Valid vCenter username which has either Administrator or HCIA role
        [Parameter(Mandatory = $true)]
        [String] $Username,

        # Use corresponding password for username
        [Parameter(Mandatory = $true)]
        [String] $Password,

        # Callhome IP
        [Parameter(Mandatory = $false)]
        [String] $IP,

        # Callhome Address
        [Parameter(Mandatory = $false)]
        [String] $Address,

        # Callhome site ID
        [Parameter(Mandatory = $true)]
        [String] $SiteID,

        # Callhome first name
        [Parameter(Mandatory = $true)]
        [String] $FirstName,

        # Callhome last name
        [Parameter(Mandatory = $true)]
        [String] $LastName,

        # Callhome email
        [Parameter(Mandatory = $true)]
        [String] $Email,

        # Callhome phone
        [Parameter(Mandatory = $true)]
        [String] $Phone,

        # Callhome company
        [Parameter(Mandatory = $true)]
        [String] $Company,

        # Use corresponding password for root user
        [Parameter(Mandatory = $true)]
        [String] $RootPassword,

        # Use corresponding password for admin user
        [Parameter(Mandatory = $true)]
        [String] $AdminPassword,

        # Print JSON style format
        [Parameter(Mandatory = $false)]
        [Switch] $Format,

        # The API version, default is v1
        [Parameter(Mandatory = $false)]
        [String] $Version = "v1"
    )

    # version check
    if (($Version -ne "v1") -and ($Version -ne "v2")) {
        write-host "The inputted Version $Version is invalid." -ForegroundColor Red
        return
    }

    # argurment check
    if ($Version.ToLower() -eq "v1") {
        if ([string]::IsNullOrWhiteSpace($IP)) {
            write-host "The inputted IP is empty." -ForegroundColor Red
            return
        }
    } elseif ($Version.ToLower() -eq "v2") {
        if ([string]::IsNullOrWhiteSpace($Address)) {
            write-host "The inputted Address is empty." -ForegroundColor Red
            return
        }
    }

    $uri = "/rest/vxm/" + $Version.ToLower() + "/callhome/deployment"

    $Body = ""
    if ($Version -eq "v1") {
        $Body = @{
            "ip"         = $IP
            "site_id"    = $SiteID
            "first_name" = $FirstName
            "last_name"  = $LastName
            "email"      = $Email
            "phone"      = $Phone
            "company"    = $Company
            "root_pwd"   = $RootPassword
            "admin_pwd"  = $AdminPassword
        } | ConvertTo-Json
    } elseif ($Version -eq "v2") {
        $Body = @{
            "address"    = $Address
            "site_id"    = $SiteID
            "first_name" = $FirstName
            "last_name"  = $LastName
            "email"      = $Email
            "phone"      = $Phone
            "company"    = $Company
            "root_pwd"   = $RootPassword
            "admin_pwd"  = $AdminPassword
        } | ConvertTo-Json
    }

    try {
        $ret = doPost -Server $Server -Api $uri -Username $Username -Password $Password -Body $Body
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
Activates and registers an internal callhome server.

.Parameter Server
VxM IP or FQDN.

.Parameter Username
Valid vCenter username which has either Administrator or HCIA role.

.Parameter Password
Use corresponding password for username.

.Parameter AccessCode
Access code for activating an internal callhome server.

.Parameter Format
Print JSON style format.

.NOTES
You can run this cmdlet to activate and register an internal callhome server.

.Example
C:\PS>Register-InternalCallHomeServer -Server <vxm ip or FQDN> -Username <username> -Password <password> -AccessCode <access code>

Activates and registers an internal callhome server.
#>
function Register-InternalCallHomeServer {
    param(
        # VxM IP or FQDN
        [Parameter(Mandatory = $true)]
        [string] $Server,

        # Valid vCenter username which has either Administrator or HCIA role
        [Parameter(Mandatory = $true)]
        [String] $Username,

        # Use corresponding password for username
        [Parameter(Mandatory = $true)]
        [String] $Password,

        # Access code for activating an internal callhome server
        [Parameter(Mandatory = $true)]
        [String] $AccessCode,

        # Print JSON style format
        [Parameter(Mandatory = $false)]
        [Switch] $Format
    )

    $uri = "/rest/vxm/v1/callhome/internal/register"

    $Body = @{
        "access_code" = $AccessCode
    } | ConvertTo-Json

    try {
        $ret = doPost -Server $Server -Api $uri -Username $Username -Password $Password -Body $Body
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
Registers the external callhome server(s).

.Parameter Server
VxM IP or FQDN.

.Parameter Username
Valid vCenter username which has either Administrator or HCIA role.

.Parameter Password
Use corresponding password for username.

.Parameter SiteID
Callhome site ID.

.Parameter IPList
Callhome IP list. Support in v1

.Parameter AddressList
Callhome Address list. Support in v2

.Parameter SupportUsername
Callhome support username.

.Parameter SupportPassword
Callhome support password.

.Parameter Format
Print JSON style format.

.Parameter Version
Optional. API version. Only input v1 or v2. Default value is v1.

.NOTES
You can run this cmdlet to register the external callhome server(s).

.Example
C:\PS>Register-ExternalCallHomeServer -Server <vxm ip or FQDN> -Username <username> -Password <password> -SiteID <callhome site ID> -IPList <callhome IP list>

Registers the external callhome server(s) when support account log in.

.Example
C:\PS>Register-ExternalCallHomeServer -Server <vxm ip or FQDN> -Username <username> -Password <password> -SiteID <callhome site ID> -IPList <callhome IP list> -SupportUsername <support username> -SupportPassword <support password>

Registers the external callhome server(s) when support account not log in.
#>
function Register-ExternalCallHomeServer {
    param(
        # VxM IP or FQDN
        [Parameter(Mandatory = $true)]
        [string] $Server,

        # Valid vCenter username which has either Administrator or HCIA role
        [Parameter(Mandatory = $true)]
        [String] $Username,

        # Use corresponding password for username
        [Parameter(Mandatory = $true)]
        [String] $Password,

        # Callhome site ID
        [Parameter(Mandatory = $true)]
        [String] $SiteID,

        # Callhome IP list
        [Parameter(Mandatory = $false)]
        [String[]] $IPList,

        # Callhome Address list
        [Parameter(Mandatory = $false)]
        [String[]] $AddressList,

        # Callhome support username
        [Parameter(Mandatory = $false)]
        [String] $SupportUsername,

        # Callhome support password
        [Parameter(Mandatory = $false)]
        [String] $SupportPassword,

        # Print JSON style format
        [Parameter(Mandatory = $false)]
        [Switch] $Format,

        # The API version, default is v1
        [Parameter(Mandatory = $false)]
        [String] $Version = "v1"
    )

    # version check
    if (($Version -ne "v1") -and ($Version -ne "v2")) {
        write-host "The inputted Version $Version is invalid." -ForegroundColor Red
        return
    }

    # argurment check
    if ($Version.ToLower() -eq "v1") {
        if ([string]::IsNullOrWhiteSpace($IPList)) {
            write-host "The inputted IP List is empty." -ForegroundColor Red
            return
        }
    } elseif ($Version.ToLower() -eq "v2") {
        if ([string]::IsNullOrWhiteSpace($AddressList)) {
            write-host "The inputted Address List is empty." -ForegroundColor Red
            return
        }
    }

    $uri = "/rest/vxm/" + $Version.ToLower() + "/callhome/external/register"

    $Body = ""
    
    if ($Version.ToLower() -eq "v1") {
        $Body = @{
        "site_id"          = $SiteID 
        "ip_list"          = $IPList
        "support_username" = $SupportUsername
        "support_pwd"      = $SupportPassword
        } | ConvertTo-Json
    } elseif ($Version.ToLower() -eq "v2") {
        $Body = @{
        "site_id"          = $SiteID 
        "address_list"     = $AddressList
        "support_username" = $SupportUsername
        "support_pwd"      = $SupportPassword
        } | ConvertTo-Json
    }
    
    Write-Host $Body
    
    try {
        $ret = doPost -Server $Server -Api $uri -Username $Username -Password $Password -Body $Body
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
Generates an access code to activate the internal callhome server.

.Parameter Server
VxM IP or FQDN.

.Parameter Username
Valid vCenter username which has either Administrator or HCIA role.

.Parameter Password
Use corresponding password for username.

.Parameter Format
Print JSON style format.

.NOTES
You can run this cmdlet to generate an access code to activate the internal callhome server.

.Example
C:\PS>New-CallhomeAccessCode -Server <vxm ip or FQDN> -Username <username> -Password <password>

Generates an access code to activate the internal callhome server.
#>
function New-CallhomeAccessCode {
    param(
        # VxM IP or FQDN
        [Parameter(Mandatory = $true)]
        [string] $Server,

        # Valid vCenter username which has either Administrator or HCIA role
        [Parameter(Mandatory = $true)]
        [String] $Username,

        # Use corresponding password for username
        [Parameter(Mandatory = $true)]
        [String] $Password,

        # Print JSON style format
        [Parameter(Mandatory = $false)]
        [Switch] $Format
    )

    $uri = "/rest/vxm/v1/callhome/access-code"

    try {
        $ret = doPost -Server $Server -Api $uri -Username $Username -Password $Password
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
Unregisters the callhome server(s), and deletes the SRS VE virtual machine if it exists.

.Parameter Server
VxM IP or FQDN.

.Parameter Username
Valid vCenter username which has either Administrator or HCIA role.

.Parameter Password
Use corresponding password for username.

.Parameter Format
Print JSON style format.

.NOTES
You can run this cmdlet to unregister the callhome server(s), and delete the SRS VE virtual machine if it exists.

.Example
C:\PS>Unregister-CallhomeServer -Server <vxm ip or FQDN> -Username <username> -Password <password>

Unregisters the callhome server(s), and deletes the SRS VE virtual machine if it exists.
#>
function Unregister-CallhomeServer {
    param(
        # VxM IP or FQDN
        [Parameter(Mandatory = $true)]
        [string] $Server,

        # Valid vCenter username which has either Administrator or HCIA role
        [Parameter(Mandatory = $true)]
        [String] $Username,

        # Use corresponding password for username
        [Parameter(Mandatory = $true)]
        [String] $Password,

        # Print JSON style format
        [Parameter(Mandatory = $false)]
        [Switch] $Format
    )

    $uri = "/rest/vxm/v1/callhome/disable"

    try {
        $ret = doDelete -Server $Server -Api $uri -Username $Username -Password $Password
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
Upgrades the internal SRS instance.

.Parameter Server
VxM IP or FQDN.

.Parameter Username
Valid vCenter username which has either Administrator or HCIA role.

.Parameter Password
Use corresponding password for username.

.Parameter SrsRootPwd
Use corresponding password for SRS root username.

.Parameter SrsAdminPwd
Use corresponding password for SRS admin username.

.Parameter Format
Print JSON style format.

.NOTES
You can run this cmdlet to upgrade the internal SRS instance.

.Example
C:\PS>Start-InternalSRSUpgrade -Server <VxM> -Username <account> -Password <password> -SrsRootPwd <srsRootPwd> -SrsAdminPwd <srsAdminPwd>

Upgrades the internal SRS instance.
#>
function Start-InternalSRSUpgrade {
    param(
        # VxM IP or FQDN
        [Parameter(Mandatory = $true)]
        [string] $Server,

        # Valid vCenter username which has either Administrator or HCIA role
        [Parameter(Mandatory = $true)]
        [String] $Username,

        # Use corresponding password for username
        [Parameter(Mandatory = $true)]
        [String] $Password,

        # password for SRS root username
        [Parameter(Mandatory = $true)]
        [String] $SrsRootPwd,

        # password for SRS admin username
        [Parameter(Mandatory = $true)]
        [String] $SrsAdminPwd,

        # Print JSON style format
        [Parameter(Mandatory = $false)]
        [Switch] $Format
    )

    $uri = "/rest/vxm/v1/callhome/internal/upgrade"

    # Body content: ESRS root and admin password
    $Body = @{
        "root_pwd"  = $SrsRootPwd
        "admin_pwd" = $SrsAdminPwd
    } | ConvertTo-Json

    try {
        $ret = doPost -Server $Server -Api $uri -Username $Username -Password $Password -Body $Body
        if ($Format) {
            $ret = $ret | ConvertTo-Json
        }
        return $ret
    }
    catch {
        write-host $_
    }
}