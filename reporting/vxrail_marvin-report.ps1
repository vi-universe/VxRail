<#    
Script Name:		vxrail_marvin-report.ps1
Description:		Intern service script Christian Kremer 
Data:		        09/Feb/2024
Version:		1.0
Author:			Christian Kremer
Email:			christian@kremer.systems    
#> 


$vxrm = read-host "enter vxrail manager ip adress"
$user = read-host "enter administrator account"
$pass = read-host "enter password"

import-module VxRail.API

function marvin-info 
{

 param(
		
		[string]$vxrm,
		[string]$user,
		[string]$pass
    )


  
        Get-SystemInfo -Server $vxrm -Username $user -Password $pass | Select-Object "version","number_of_host","cluster_type","is_external_vc" | FT
        
        Get-Cluster -Server $vxrm -Username $user -Password $pass | Select-Object "Cluster_ID","product_type","health","operational_status" | FT
         
        Get-SystemClusterHosts -Server $vxrm -Username $user -Password $pass | Select-Object "host_name","appliance_id","psnt","serial_number","model","health","missing" | FT
        
        Get-VCenterMode -Server $vxrm -Username $user -Password $pass | FT
                
        Get-SupportContact -Server $vxrm -Username $user -Password $pass | Select-Object "email","company","site_id" | FT


 
}


marvin-info -vxrm $vxrm -user $user -pass $pass


