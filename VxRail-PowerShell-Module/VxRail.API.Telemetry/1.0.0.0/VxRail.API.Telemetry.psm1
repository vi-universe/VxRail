$currentPath = $PSScriptRoot.Substring(0,$PSScriptRoot.LastIndexOf("\"))
$currentVersion = $PSScriptRoot.Substring($PSScriptRoot.LastIndexOf("\") + 1, $PSScriptRoot.Length - ($PSScriptRoot.LastIndexOf("\") + 1))
$commonPath = $currentPath.Substring(0,$currentPath.LastIndexOf("\")) + "\VxRail.API.Common\" + $currentVersion + "\VxRail.API.Common.ps1"

. "$commonPath"


<#
.SYNOPSIS
Retrieves the currently set telemetry tier.

.Parameter Server
VxM IP or FQDN.

.Parameter Username
Valid vCenter username which has either Administrator or HCIA role. 

.Parameter Password
Use corresponding password for username.

.NOTES
You can run this cmdlet to retrieve the currently set telemetry tier.

.EXAMPLE
C:\PS>Get-TelemetryTier -Server <VxM IP or FQDN> -Username <username> -Password <password>

Retrieves the currently set telemetry tier.
#>
function Get-TelemetryTier {
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

        # Print JSON style format
        [Parameter(Mandatory = $false)]
        [switch] $Format

    )

    $uri = "/rest/vxm/v1/telemetry/tier"
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
.SYNOPSIS
Sets the telemetry tier.

.Parameter Server
VxM IP or FQDN.

.Parameter Username
Valid vCenter username which has either Administrator or HCIA role. 

.Parameter Password
Use corresponding password for username.

.Parameter TelemetryLevel
telemetry level to be set.

.NOTES
You can run this cmdlet to set the telemetry tier.

.EXAMPLE
PS> Set-TelemetryTier -Server <VxM IP or FQDN> -Username <username> -Password <password> -TelemetryLevel <telemetrytier level>

Sets the telemetry tier.
#>
function Set-TelemetryTier {
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

        # Telemetry level to be set
        [Parameter(Mandatory = $true,HelpMessage="Supported telemetry: 'LIGHT','BASIC','ADVANCED','NONE'.")]
        [ValidateSet('LIGHT','BASIC','ADVANCED','NONE')]
        [string] $TelemetryLevel,

        # Print JSON style format
        [Parameter(Mandatory = $false)]
        [switch] $Format
    )

    $uri = "/rest/vxm/v1/telemetry/tier"

    $body = @{
        "level" = $TelemetryLevel
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
