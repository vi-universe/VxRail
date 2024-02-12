$currentPath = $PSScriptRoot.Substring(0,$PSScriptRoot.LastIndexOf("\"))
$currentVersion = $PSScriptRoot.Substring($PSScriptRoot.LastIndexOf("\") + 1, $PSScriptRoot.Length - ($PSScriptRoot.LastIndexOf("\") + 1))
$commonPath = $currentPath.Substring(0,$currentPath.LastIndexOf("\")) + "\VxRail.API.Common\" + $currentVersion + "\VxRail.API.Common.ps1"

. "$commonPath"


<#
.Synopsis
Query support account.

.Parameter Server
VxM IP or FQDN.

.Parameter Username
Valid vCenter username which has either Administrator or HCIA role. 

.Parameter Password
Use corresponding password for username. 

.Parameter Format
Print JSON style format.

.Notes
You can run this cmdlet to query support account.

.Example
C:\PS>Get-SupportAccount -Server <vxm ip or FQDN> -Username <username> -Password <password>

Get support account information.
#>
function Get-SupportAccount {
    param(
        # VxRail Manager IP address or FQDN
        [Parameter(Mandatory = $true)]
        [string] $Server,
        
        # User name in vCenter
        [Parameter(Mandatory = $true)]
        [String] $Username,
        
        # password for the vCenter
        [Parameter(Mandatory = $true)]
        [String] $Password,

        # Formatting the output
        [Parameter(Mandatory = $false)]
        [Switch] $Format
    )

    $uri = "/rest/vxm/v1/support/account"
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
Setup support account.

.Parameter Server
VxM IP or FQDN.

.Parameter Username
Valid vCenter username which has either Administrator or HCIA role. 

.Parameter Password
Use corresponding password for username. 

.Parameter Format
Print JSON style format.

.Parameter SupportAccountName
The username of the support account.

.Parameter SupportAccountPassword
The password of the support account.

.Notes
You can run this cmdlet to setup support account.

.Example
C:\PS>Add-SupportAccount -Server <vxm ip or FQDN> -Username <username> -Password <password> -SupportAccountName <support account name> -SupportAccountPassword <support account password>

Add support account settings.
#>
function Add-SupportAccount {
    param (
        # VxRail Manager IP address or FQDN
        [Parameter(Mandatory = $true)]
        [string] $Server,
        
        # User name in vCenter
        [Parameter(Mandatory = $true)]
        [String] $Username,
        
        # password for the vCenter
        [Parameter(Mandatory = $true)]
        [String] $Password,

        # Formatting the output
        [Parameter(Mandatory = $false)]
        [Switch] $Format,

        # a new support account User Name
        [Parameter(Mandatory = $true)]
        [string] $SupportAccountName,

        # Password for the new support account
        [Parameter(Mandatory = $true)]
        [String] $SupportAccountPassword
    )
    
    $uri = "/rest/vxm/v1/support/account"
    
    # Body content: Support Account user name and password to post
    $Body = @{
        "username" = $SupportAccountName
        "password" = $SupportAccountPassword
    } | ConvertTo-Json

    try{ 
        $ret = doPost -Server $Server -Api $uri -Username $Username -Password $Password -Body $Body
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
Update support account.

.Parameter Server
VxM IP or FQDN.

.Parameter Username
Valid vCenter username which has either Administrator or HCIA role. 

.Parameter Password
Use corresponding password for username. 

.Parameter Format
Print JSON style format.

.Parameter SupportAccountName
The username of the support account.

.Parameter SupportAccountPassword
The password of the support account.

.Notes
You can run this cmdlet to update support account.

.Example
C:\PS>Update-SupportAccount -Server <vxm ip or FQDN> -Username <username> -Password <password> -SupportAccountName <support account name> -SupportAccountPassword <support account password>

Update support account settings.
#>
function Update-SupportAccount {
    param (
        # VxRail Manager IP address or FQDN
        [Parameter(Mandatory = $true)]
        [string] $Server,
        
        # User name in vCenter
        [Parameter(Mandatory = $true)]
        [String] $Username,
        
        # password for the vCenter
        [Parameter(Mandatory = $true)]
        [String] $Password,

        # Formatting the output
        [Parameter(Mandatory = $false)]
        [Switch] $Format,

        # a new support account User Name
        [Parameter(Mandatory = $true)]
        [string]
        $SupportAccountName,

        # a new support account Password
        [Parameter(Mandatory = $true)]
        [String]
        $SupportAccountPassword
    )
    
    $uri = "/rest/vxm/v1/support/account"
    
    # Body content: Support Account user name and password to put
    $Body = @{
        "username" = $SupportAccountName
        "password" = $SupportAccountPassword
    } | ConvertTo-Json

    try{ 
        $ret = doPut -Server $Server -Api $uri -Username $Username -Password $Password -Body $Body
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
Forget support account.

.Parameter Server
VxM IP or FQDN.

.Parameter Username
Valid vCenter username which has either Administrator or HCIA role. 

.Parameter Password
Use corresponding password for username. 

.Parameter Format
Print JSON style format.

.Notes
You can run this cmdlet to forget support account.

.Example
C:\PS>Remove-SupportAccount -Server <vxm ip or FQDN> -Username <username> -Password <password>

Remove support account settings.
#>
function Remove-SupportAccount {
    param (
        # VxRail Manager IP address or FQDN
        [Parameter(Mandatory = $true)]
        [string] $Server,
        
        # User name in vCenter
        [Parameter(Mandatory = $true)]
        [String] $Username,
        
        # password for the vCenter
        [Parameter(Mandatory = $true)]
        [String] $Password,

        # Formatting the output
        [Parameter(Mandatory = $false)]
        [Switch] $Format
    )
    
    $uri = "/rest/vxm/v1/support/account"

    try{ 
        $ret = doDelete -Server $Server -Api $uri -Username $Username -Password $Password 
        if($Format) {
            $ret = $ret | ConvertTo-Json
        }
        return $ret
    } catch {
        write-host $_
    }
}