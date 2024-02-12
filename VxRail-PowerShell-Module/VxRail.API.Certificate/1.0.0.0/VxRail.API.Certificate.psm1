$currentPath = $PSScriptRoot.Substring(0,$PSScriptRoot.LastIndexOf("\"))
$currentVersion = $PSScriptRoot.Substring($PSScriptRoot.LastIndexOf("\") + 1, $PSScriptRoot.Length - ($PSScriptRoot.LastIndexOf("\") + 1))
$commonPath = $currentPath.Substring(0,$currentPath.LastIndexOf("\")) + "\VxRail.API.Common\" + $currentVersion + "\VxRail.API.Common.ps1"

. "$commonPath"


<#
.SYNOPSIS

Update VXM certificate

.NOTES

You can run this cmdlet to update VxM certificate.

.EXAMPLE

PS> Update-Certificate -Server <VxM IP or FQDN> -Username <username> -Password <password> -CertContent <cert content> -PrimaryKey <primary key> -RootCertChain <root cert content> -PfxPassword <.pfx password>

Update VxM certificate
#>
function Update-Certificate {
    param(
        [Parameter(Mandatory = $true)]
        # VxM IP or FQDN
        [string] $Server,

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
        # .crt file content
        [String] $CertContent,

        [Parameter(Mandatory = $true)]
        # .key file content
        [String] $PrimaryKey,

        [Parameter(Mandatory = $true)]
        # Root certificate content
        [String] $RootCertChain,

        [Parameter(Mandatory = $true)]
        # The password for new .pfx file
        [String] $PfxPassword 
    )

    $Body = @{
        "cert" = $CertContent
        "primary_key" = $PrimaryKey
        "root_cert_chain" = $RootCertChain
        "password" = $PfxPassword
    } | ConvertTo-Json

    $uri = "/rest/vxm/v1/certificates/import-vxm"
    try{
        $ret = doPost -Server $server -Api $uri -Username $username -Password $password -Body $Body
        if($Format) {
            $ret = $ret | ConvertTo-Json -Depth
        }
        return $ret
    } catch {
        write-host $_
    }

}