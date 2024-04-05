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
	# vxrail manager ip
	Server = 'xxx.xxx.xxx.xxx'
	# administrator@vsphere.local
	Username = '@vsphere.local'
	# administrator@vsphere.local password
	Password = 'PASSWORD'

}

Function Get-Marvin {

	param (
		[CmdletBinding(SupportsShouldProcess = $False)]
		[parameter(Mandatory = $true, HelpMessage = 'marvinparameters')]
		[ValidateNotNullorEmpty()]
		[hashtable] $marvinparameters
		
	)
	if ('' -eq "$($marvinparameters.Server)" -or '' -eq "$($marvinparameters.Username)" -or '' -eq "$($marvinparameters.Password)") {
		Write-Host "Please check your parameters:"
		$marvinparameters
		return
	}

     Get-SystemInfo @marvinparameters | Select-Object 'version', 'number_of_host', 'cluster_type', 'is_external_vc' | Format-Table
	 Get-Cluster @marvinparameters | Select-Object 'Cluster_ID', 'product_type', 'health', 'operational_status' | Format-Table
	 Get-SystemClusterHosts @marvinparameters | Select-Object 'host_name', 'appliance_id', 'psnt', 'serial_number', 'model', 'health', 'missing' | Format-Table
	 Get-VCenterMode @marvinparameters | Format-Table
	 Get-SupportContact @marvinparameters | Select-Object 'email', 'company', 'site_id' | Format-Table
}

Get-Marvin -marvinparameters $marvinparams


