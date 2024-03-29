﻿#
# Module manifest for module 'VxRail.API.System'
#
# Generated by: qic2
#
# Generated on: 2019/2/28
#

@{

# Script module or binary module file associated with this manifest.
#RootModule = ''

# Version number of this module.
ModuleVersion = '1.0.0.0'

# ID used to uniquely identify this module
GUID = 'be6a78ea-28ec-4821-8168-907fc6cb839b'

# Author of this module
Author = 'qic2'

# Company or vendor of this module
CompanyName = 'Dell EMC'

# Copyright statement for this module
Copyright = '(c) 2019 Dell EMC. All rights reserved.'

# Description of the functionality provided by this module
# Description = ''

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @(
    'VxRail.API.System.VM.psm1',
    'VxRail.API.System.psm1',
    'VxRail.API.System.Health.psm1',
    'VxRail.API.System.Host.psm1',
    'VxRail.API.System.InternetMode.psm1',
    'VxRail.API.System.Proxy.psm1',
    'VxRail.API.CallHomeMode.psm1',
    'VxRail.API.CallHomeESRS.psm1',
    'VxRail.API.Requests.psm1'
)

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @(
@{"ModuleName"="VxRail.API.Common";"ModuleVersion"="1.0.0.0"}
)

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.0'

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = "*-*"

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = "*"

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()
}