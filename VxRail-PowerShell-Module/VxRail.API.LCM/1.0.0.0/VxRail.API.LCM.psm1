$currentPath = $PSScriptRoot.Substring(0,$PSScriptRoot.LastIndexOf("\"))
$currentVersion = $PSScriptRoot.Substring($PSScriptRoot.LastIndexOf("\") + 1, $PSScriptRoot.Length - ($PSScriptRoot.LastIndexOf("\") + 1))
$commonPath = $currentPath.Substring(0,$currentPath.LastIndexOf("\")) + "\VxRail.API.Common\" + $currentVersion + "\VxRail.API.Common.ps1"

. "$commonPath"

<#
.Synopsis
Upgrades all VxRail software and hardware.

.Parameter Version
Optional. API version. Only input v1 or v2. Default value is v1.

.Parameter Server
Required. VxM IP or FQDN.

.Parameter Username
Required. Valid vCenter username which has either Administrator or HCIA role. 

.Parameter Password
Required. Use corresponding password for username. 

.Parameter BundleFilePath
Required. Full path of the upgrade bundle

.Parameter VxmRootUsername
Optional. Username of VxRail Manager root user. Default is root.

.Parameter VxmRootPassword
Required. Password of VxRail Manager root user

.Parameter VcAdminUsername
Required. Username for vCenter Admin user

.Parameter VcAdminPassword
Required. Password for vCenter Admin user

.Parameter VcsaRootUsername
Username for VCSA Root user. Required if the upgrade bundle contains vcenter component

.Parameter VcsaRootPassword
Password for VCSA Root user. Required if the upgrade bundle contains vcenter component

.Parameter PscRootUsername
Username for PSC Root user. Required if the upgrade bundle contains vcenter component

.Parameter PscRootPassword
Password for PSC Root user. Required if the upgrade bundle contains vcenter component

.Parameter SourceVcsaHostname
Optional. Hostname of the VxRail host on which VCSA VM is currently on

.Parameter SourceVcsaHostUsername
Optional. Username of the VxRail host on which VCSA VM is currently on

.Parameter SourceVcsaHostPassword
Optional. Password of the VxRail host on which VCSA VM is currently on

.Parameter SourcePscHostname
Optional. Hostname of the VxRail host on which PSC VM is currently on

.Parameter SourcePscHostUsername
Optional. Username of the VxRail host on which PSC VM is currently on

.Parameter SourcePscHostPassword
Optional. Password of the VxRail host on which PSC VM is currently on

.Parameter TargetVcsaHostname
Optional. Hostname of the VxRail host on which VCSA/PSC VM is to be deployed on

.Parameter TargetVcsaHostUsername
Optional. Username of the VxRail host on which VCSA/PSC VM is to be deployed on

.Parameter TargetVcsaHostPassword
Optional. Password of the VxRail host on which VCSA/PSC VM is to be deployed on

.Parameter TemporaryIP
Optional. Temporary IP address for the upgrade

.Parameter TemporaryGateway
Optional. Temporary gateway for the upgrade

.Parameter TemporaryNetmask
Optional. Temporary netmask for the upgrade

.Parameter AutoWitnessUpgrade
Support since Version v2. Used for Stretched Cluster or vSAN 2-Node Cluster. Whether VxRail will automatically upgrade the witness node

.Parameter WitnessUsername
Support since Version v2. Used for Stretched Cluster or vSAN 2-Node Cluster. Username for witness node user. Required if witness node is upgraded.

.Parameter WitnessUserPassword
Support since Version v2. Used for Stretched Cluster or vSAN 2-Node Cluster. Password for witness node user. Required if witness node is upgraded.

.Parameter PreferredFaultDomainFirst
Support since Version v2. Stretched cluster upgrade sequence selection. For standard cluster and vSAN 2-Node cluster, this option should not be specified. For stretched cluster, this option is optional. 

.Parameter Format
Print JSON style format.


.Notes
You can run this cmdlet to start LCM.

.Example
For standard cluster,
C:\PS>Start-LcmUpgrade -Version <v1 or v2> -Server <vxm ip or FQDN> -Username <username> -Password <password> -BundleFilePath <bundle file path> -VxmRootUsername <vxm root user> -VxmRootPassword <vxm root password> -VcAdminUsername <vc admin user> -VcAdminPassword <vc admin password> -VcsaRootUsername <vcsa root username> -VcsaRootPassword <vcsa root password> -PscRootUsername <psc root user> -PscRootPassword <psc root password> -SourceVcsaHostname <source vcsa hostname> -SourceVcsaHostUsername <source vcsa host username> -SourceVcsaHostPassword <source vcsa host password> -SourcePscHostname <source psc hostname> -SourcePscHostUsername <source psc host username> -SourcePscHostPassword <source psc host password> -TargetVcsaHostname <target vcsa  hostname> -TargetVcsaHostUsername <target vcsa host username> -TargetVcsaHostPassword <target vcsa host password> -TemporaryIP <temporary ip> -TemporaryGateway <temporary gateway> -TemporaryNetMask <temporary netmask>

.Example
For stretched cluster and vSAN 2-Node cluster,
C:\PS>Start-LcmUpgrade -Version <v1 or v2> -Server <vxm ip or FQDN> -Username <username> -Password <password> -BundleFilePath <bundle file path> -VxmRootUsername <vxm root user> -VxmRootPassword <vxm root password> -VcAdminUsername <vc admin user> -VcAdminPassword <vc admin password> -VcsaRootUsername <vcsa root username> -VcsaRootPassword <vcsa root password> -PscRootUsername <psc root user> -PscRootPassword <psc root password> -SourceVcsaHostname <source vcsa hostname> -SourceVcsaHostUsername <source vcsa host username> -SourceVcsaHostPassword <source vcsa host password> -SourcePscHostname <source psc hostname> -SourcePscHostUsername <source psc host username> -SourcePscHostPassword <source psc host password> -TargetVcsaHostname <target vcsa  hostname> -TargetVcsaHostUsername <target vcsa host username> -TargetVcsaHostPassword <target vcsa host password> -TemporaryIP <temporary ip> -TemporaryGateway <temporary gateway> -TemporaryNetMask <temporary netmask> -AutoWitnessUpgrade <$true or $false> -WitnessUsername <witness node username> -WitnessUserPassword <witness node user password> -PreferredFaultDomainFirst <$true or $false>

Start LCM upgrade. Need to provide all the necessary information. 
#>
function Start-LcmUpgrade  {
    param(
        [Parameter(Mandatory = $false)]
        [String] $Version = "v1",

        # VxRail Manager IP address or FQDN
        [Parameter(Mandatory = $true)]
        [string] $Server,
        
        # User name in vCenter
        [Parameter(Mandatory = $true)]
        [String] $Username,
        
        # password for the vCenter
        [Parameter(Mandatory = $true)]
        [String] $Password,       

        # The absolute path of bundle file
        [Parameter(Mandatory = $true)]
        [String] $BundleFilePath, 

        # The Vxm_Root account settings, default username is root
        [Parameter(Mandatory = $false)]
        [String] $VxmRootUsername = "root",

        [Parameter(Mandatory = $true)]
        [String] $VxmRootPassword,

        # The Vc_Admin account settings
        [Parameter(Mandatory = $true)]
        [String] $VcAdminUsername,

        [Parameter(Mandatory = $true)]
        [String] $VcAdminPassword,

        # The Vcsa_Root account settings, Only required if the upgrade bundle contains vcenter component
        [Parameter(Mandatory = $false)]
        [String] $VcsaRootUsername,

        [Parameter(Mandatory = $false)]
        [String] $VcsaRootPassword,
        
         # The Psc_Root account settings, Only required if the upgrade bundle contains vcenter component
        [Parameter(Mandatory = $false)]
        [String] $PscRootUsername,

        [Parameter(Mandatory = $false)]
        [String] $PscRootPassword,

        # The Source Vcsa ESXi host settings, Only required for migration based vcenter upgrade
        [Parameter(Mandatory = $false)]
        [String] $SourceVcsaHostname,  
         
        [Parameter(Mandatory = $false)]
        [String] $SourceVcsaHostUsername, 
           
        [Parameter(Mandatory = $false)]
        [String] $SourceVcsaHostPassword,  

        # The Source Psc ESXi host settings, Only required for migration based vcenter upgrade
        [Parameter(Mandatory = $false)]
        [String] $SourcePscHostname,  

        [Parameter(Mandatory = $false)]
        [String] $SourcePscHostUsername,  

        [Parameter(Mandatory = $false)]
        [String] $SourcePscHostPassword, 

        # The Target vcsa ESXi host settings, Only required for migration based vcenter upgrade
        [Parameter(Mandatory = $false)]
        [String] $TargetVcsaHostname,   

        [Parameter(Mandatory = $false)]
        [String] $TargetVcsaHostUsername,    
 
        [Parameter(Mandatory = $false)]
        [String] $TargetVcsaHostPassword,  

        # Temporary IP settings, Only required for migration based vcenter upgrade
        [Parameter(Mandatory = $false)]
        [String] $TemporaryIP,  

        [Parameter(Mandatory = $false)]
        [String] $TemporaryGateway,  

        [Parameter(Mandatory = $false)]
        [String] $TemporaryNetmask,

        [Parameter(Mandatory = $false)]
        [bool] $AutoWitnessUpgrade,

        [Parameter(Mandatory = $false)]
        [String] $WitnessUsername,

        [Parameter(Mandatory = $false)]
        [String] $WitnessUserPassword,

        [Parameter(Mandatory = $false)]
        [bool] $PreferredFaultDomainFirst,

        # need good format
        [Parameter(Mandatory = $false)]
        [Switch] $Format
    )

    $uri = "/rest/vxm/" + $Version.ToLower() + "/lcm/upgrade"

    # check Version
    # $pattern = "^v{1}[1|2]{1}$"
    if(($Version -ne "v1") -and ($Version -ne "v2")) {
        write-host "The inputted Version $Version is invalid." -ForegroundColor Red
        return
    }
        
    # check parameters support since version v2 api
    $message = ""
    if(!$Version -or ($Version.ToLower() -eq "v1")) {
        if($PSBoundParameters.ContainsKey("AutoWitnessUpgrade")) {
            $message = $message + "The parameter 'AutoWitnessUpgrade' is supported since Version v2.`n"
        }
        if($PSBoundParameters.ContainsKey("WitnessUsername")) {
            $message = $message + "The parameter 'WitnessUsername' is supported since Version v2.`n"
        }
        if($PSBoundParameters.ContainsKey("WitnessUserPassword")) {
            $message = $message + "The parameter 'WitnessUserPassword' is supported since Version v2.`n"
        }
        if($PSBoundParameters.ContainsKey("PreferredFaultDomainFirst")) {
            $message = $message + "The parameter 'PreferredFaultDomainFirst' is supported since Version v2."
        }
    }

    if($message.Length -gt 0) {
        write-host $message -ForegroundColor Red
        return
    }
    
    # Add mandatory information to body
    $Body = @{
    	"bundle_file_locator" = $BundleFilePath 
    	"vxrail" = @{
    		"vxm_root_user" = @{
    			"username" = $VxmRootUsername
    			"password" = $VxmRootPassword
    		}	
    	}
    	"vcenter" = @{
    		"vc_admin_user" = @{
    			"username" = $VcAdminUsername
    			"password" = $VcAdminPassword
    		}
        }
    }

    # if user entered vcsa root user account, add it to body
    if($VcsaRootUsername -and $VcsaRootPassword){
            $VcsaRootObj = @{
                "username" = $VcsaRootUsername
                "password" = $VcsaRootPassword
            }
            $Body.vcenter.add("vcsa_root_user",$VcsaRootObj)
    }

    # if user entered psc root user account, add it to body
    if($PscRootUsername -and $PscRootPassword){
            $PscRootObj = @{
                "username" = $PscRootUsername
                "password" = $PscRootPassword
            }
            $Body.vcenter.add("psc_root_user",$PscRootObj)
    }

    # if user entered  Source Vcsa ESXi host info, add it to body
    if($SourceVcsaHostname -and $SourceVcsaHostUsername -and $SourceVcsaHostPassword){
        # if Body object don't have 'migration_spec' object yet, add below info
        $toBeAdd_to_vcenter = @{
            "source_vcsa_host" = @{
                "name"= $SourceVcsaHostname    
			    "user"= @{
                    "username" = $SourceVcsaHostUsername
			    	"password" = $SourceVcsaHostPassword
			    }
		    }
        }
        # if Body object already have 'migration_spec', add below info
        $toBeAdd_to_vcenter_upgrade_spec = @{
            "name"= $SourceVcsaHostname    
			"user"= @{
                "username" = $SourceVcsaHostUsername
                "password" = $SourceVcsaHostPassword
            }
		}
        if($Body.vcenter.vcenter_major_version_upgrade_spec){
             $Body.vcenter.migration_spec.add("source_vcsa_host",$toBeAdd_to_vcenter_upgrade_spec)
        }
        else {
             $Body.vcenter.add("migration_spec",$toBeAdd_to_vcenter)
        }
    }

    # if user entered Source psc ESXi host info, add it to body
    if($SourcePscHostname -and $SourcePscHostUsername -and $SourcePscHostPassword){
        # if Body object don't have 'migration_spec' object yet, add below info
        $toBeAdd_to_vcenter = @{
            "source_psc_host" = @{
                "name"= $SourcePscHostname    
			    "user"= @{
                    "username" = $SourcePscHostUsername
			    	"password" = $SourcePscHostPassword
			    }
		    }
        }
        # if Body object already have 'migration_spec', add below info
        $toBeAdd_to_vcenter_upgrade_spec = @{
            "name"= $SourcePscHostname    
			"user"= @{
                "username" = $SourcePscHostUsername
                "password" = $SourcePscHostPassword
            }
		}
        if($Body.vcenter.migration_spec){
             $Body.vcenter.migration_spec.add("source_psc_host",$toBeAdd_to_vcenter_upgrade_spec)
        }
        else {
             $Body.vcenter.add("migration_spec",$toBeAdd_to_vcenter)
        }
    }

    # if user entered target Vcsa Esxi host info, add it to body
    if($TargetVcsaHostname -and $TargetVcsaHostUsername -and $TargetVcsaHostPassword){
        # if Body object don't have 'migration_spec' object yet, add below info
        $toBeAdd_to_vcenter = @{
            "target_vcsa_host" = @{
                "name"= $TargetVcsaHostname    
			    "user"= @{
                    "username" = $TargetVcsaHostUsername
			    	"password" = $TargetVcsaHostPassword
			    }
		    }
        }
        # if Body object already have 'migration_spec', add below info
        $toBeAdd_to_vcenter_upgrade_spec = @{
            "name"= $TargetVcsaHostname    
		    "user"= @{
                "username" = $TargetVcsaHostUsername
			    "password" = $TargetVcsaHostPassword
            }
		}
        if($Body.vcenter.migration_spec){
             $Body.vcenter.migration_spec.add("target_vcsa_host",$toBeAdd_to_vcenter_upgrade_spec)
        }
        else {
             $Body.vcenter.add("migration_spec",$toBeAdd_to_vcenter)
        }
    }

    # if user entered Temporary IP info, add it to body
    if($TemporaryIP -and $TemporaryGateway -and $TemporaryNetmask){
        # if Body object don't have 'migration_spec' object yet, add below info
        $toBeAdd_to_vcenter = @{
            "temporary_ip_setting" = @{
		    	"temporary_ip" = $TemporaryIP
		    	"gateway" = $TemporaryGateway
		    	"netmask" = $TemporaryNetmask
		    }
        }
        # if Body object already have 'migration_spec', add below info
        $toBeAdd_to_vcenter_upgrade_spec = @{
            "temporary_ip" = $TemporaryIP
		    "gateway" = $TemporaryGateway
		  	"netmask" = $TemporaryNetmask
		}
        if($Body.vcenter.migration_spec){
             $Body.vcenter.migration_spec.add("temporary_ip_setting",$toBeAdd_to_vcenter_upgrade_spec)
        }
        else {
             $Body.vcenter.add("migration_spec",$toBeAdd_to_vcenter)
        }
    }

    # Add parameters for v2 API
    if($Version.ToLower() -eq "v2") {
        # witness node upgrade spec
        if($AutoWitnessUpgrade) {
            if(! $WitnessUsername -or ! $WitnessUserPassword) {
                write-host "Please input WitnessUsername and WitnessUserPassword if AutoWitnessUpgrade is true." -ForegroundColor Red
                return
            }
        }
        $WitnessObj = @{
            "auto_witness_upgrade" = $AutoWitnessUpgrade
        }
        $Body.add("witness",$WitnessObj)
        if($WitnessUserPassword -or $WitnessUserPassword) {
            $WitnessUserObj = @{
                "username" = $WitnessUsername
                "password" = $WitnessUserPassword
            }
            $Body.witness.add("witness_user",$WitnessUserObj)
        }
        
        # upgrade_sequence
        if($PSBoundParameters.ContainsKey("PreferredFaultDomainFirst")) {
            $UpgradeSeqObj = @{
                "preferred_fault_domain_first" = $PreferredFaultDomainFirst
            }
            $Body.add("upgrade_sequence",$UpgradeSeqObj)
        }
    }
    
    # Convert Body to Json format
    $Body = $Body | ConvertTo-Json -Depth 10
          
    # Make "username:password" string
    $UserNameColonPassword = "{0}:{1}" -f $Username, $Password
    # Could also be accomplished like:
    # $UserNameColonPassword = "$($Username):$($Password)"

    # Ensure it's ASCII-encoded
    $InAscii = [Text.Encoding]::ASCII.GetBytes($UserNameColonPassword)

    # Now Base64-encode:
    $InBase64 = [Convert]::ToBase64String($InAscii)

    # The value of the Authorization header is "Basic " and then the Base64-encoded username:password
    $Authorization = "Basic {0}" -f $InBase64
    # Could also be done as:
    # $Authorization = "Basic $InBase64"

    #This hash will be returned as the value of the function and is the Powershell version of the basic auth header
    $headers = @{ Authorization = $Authorization }

    $url = "https://" + $Server + $uri

    try{
        $ret = Invoke-RestMethod -Method 'POST' -Uri $url -Headers $headers -Body $Body -ContentType "application/json" -TimeoutSec 300
        if($Format) {
            $ret = $ret | ConvertTo-Json
        }
        return $ret
    } catch {
        write-host $_
    }
}
