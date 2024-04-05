<#    
Script Name:		vxrail_marvin-report.ps1
Description:		Intern service script Christian Kremer 
Data:		        09/Feb/2024
Version:		    1.0
Author:			    Christian Kremer
Email:			    christian@kremer.systems    
#>     



import-module VxRail.API
$marvinparams = @{
	#vxrail manager ip address
	Server = 'xxx.xxx.xxx.xxx'
	Username = '@vsphere.local'
	Password = 'PASSWORD'
}

$teamsparams = @{
	#Teams weebhook uri
	URI         = 'URI'
	Method      = 'POST'
	ContentType = 'application/json'
}


Function Get-Marvin {

	param (
		[CmdletBinding(SupportsShouldProcess = $False)]
		[parameter(Mandatory = $true, HelpMessage = 'marvinparameters')]
		[ValidateNotNullorEmpty()]
		[hashtable] $marvinparameters,
		[parameter(Mandatory = $true, HelpMessage = 'Teamsparameters')]
		[ValidateNotNullorEmpty()]
		[hashtable] $Teamsparameters
	)
	if ('' -eq "$($marvinparameters.Server)" -or '' -eq "$($marvinparameters.Username)" -or '' -eq "$($marvinparameters.Password)") {
		Write-Host "Please check your parameters:"
		$marvinparameters
		return
	}

	if ('' -eq "$($Teamsparameters.Uri)" -or '' -eq "$($Teamsparameters.Method)" -or '' -eq "$($Teamsparameters.ContentType)") {
		Write-Host "Please check your parameters:"
		$Teamsparameters
		return
	}
	 $vxrsysinfo = Get-SystemInfo @marvinparameters | Select-Object 'version', 'number_of_host', 'cluster_type', 'is_external_vc'
	 $vxrcluster = Get-Cluster @marvinparameters | Select-Object 'Cluster_ID', 'product_type', 'health', 'operational_status' 
	 $vxrsysclusterhosts = Get-SystemClusterHosts @marvinparameters | Select-Object 'host_name', 'appliance_id', 'psnt', 'serial_number', 'model', 'health', 'missing' 
	 $vxrvcsamode = Get-VCenterMode @marvinparameters 
	 $vxrsupport = Get-SupportContact @marvinparameters | Select-Object 'email', 'company', @{n="site_id";e={($_.site_id[0] -split ",")[0]}} 
	
	
	$Teamsbody = [PSCustomObject][Ordered]@{
		"@type"      = "MessageCard"
		"@context"   = "<http://schema.org/extensions>"
		"summary"    = "VxRail Report v-1"
		"themeColor" = '0078D7'
		"title"      = "marvin-report"
		"text"       =  @(
			"<br/><b>SystemInfo</b>"
			$($vxrsysinfo | ConvertTo-HTML -Fragment) -join ""
			"<br/><b>Cluster</b>"
			$($vxrcluster  | ConvertTo-HTML -Fragment) -join ""
			"<br/><b>SystemClusterHosts</b>"
			$($vxrsysclusterhosts | ConvertTo-HTML -Fragment) -join ""
			"<br/><b>vCenter Mode</b>"
			$($vxrvcsamode | ConvertTo-HTML -Fragment) -join ""
			"<br/><b>SupportContact</b>"
			$($vxrsupport | ConvertTo-HTML -Fragment) -join ""
			) -join ""
		
	}
	
	$Teamsparameters += @{"Body"=$Teamsbody | ConvertTo-Json}

	Invoke-RestMethod @Teamsparameters

}

Get-Marvin -marvinparameters $marvinparams -Teamsparameters $teamsparams


