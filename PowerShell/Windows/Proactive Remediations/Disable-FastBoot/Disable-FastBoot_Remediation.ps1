<#
.SYNOPSIS
    Disables FastBoot.
    
.DESCRIPTION
    This script, which functions as the remediation portion of the Disable FastBoot proactive remediation 
    for use in Microsoft Intune, disables FastBoot via the registry.

.NOTES
    FileName:       Disable-FastBoot_Remediation.ps1
    Created:        10/28/2024
    Updated:        10/28/2024
    Author:         Michael J. Mattingly
    
    Version History:

    1.0.1 - Release

#>

begin {

    $logPath = "C:\PS\Logs\Disabe-FastBoot_Remediation.log"
    Start-Transcript -Path $logPath

    $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $isSystem = $currentIdentity.IsSystem
    
    if ($isSystem -eq $false) {
        Write-Error 'This script needs to run as SYSTEM.'
        return
    }

}

process {
    
    function Disable-FastBoot {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory = $false, ValueFromPipeline = $false)]
            [string]$name = "HiberbootEnabled",
            [string]$path = "HKLM:\SYSTEM\CurrentControlSet\Control\" + 
                            "Session Manager\Power",
            [string]$propertyType = "DWord",
            [int]$valueDesired = 0
        )

        New-ItemProperty -LiteralPath $path -Name $name -Value $valueDesired `
            -PropertyType $propertyType -Force -ea SilentlyContinue;

    }

    Disable-FastBoot

}

end { Stop-Transcript }