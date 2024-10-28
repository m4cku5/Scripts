<#
.SYNOPSIS
    Detects whether or not FastBoot is enabled.
    
.DESCRIPTION
    This script, which functions as the detection portion of the Disable 
    FastBoot proactive remediation for use in Microsoft Intune, verifies 
    whether or not FastBoot is enabled, and returns an exit code of 0 if it's 
    disabled, signifying compliance, and 1 if it's not, signifying 
    non-compliance.

.NOTES
    FileName:       Disable-FastBoot_Detection.ps1
    Created:        10/28/2024
    Updated:        10/28/2024
    Author:         Michael J. Mattingly
    
    Version History:

    1.0.1 - Release

#>

begin {

    $logPath = "C:\PS\Logs\Disabe-FastBoot_Detection.log"
    Start-Transcript -Path $logPath

    $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $isSystem = $currentIdentity.IsSystem
    
    if ($isSystem -eq $false) {
        Write-Error 'This script needs to run as SYSTEM.'
        return
    }

}

process {
    function Test-IsCompliant {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory = $false, ValueFromPipeline = $false)]
            [string]$name = "HiberbootEnabled",
            [string]$path = "HKLM:\SYSTEM\CurrentControlSet\Control\" +
                            "Session Manager\Power",
            [int]$valueDesired = 0
        )

        $valueCurrent = (Get-ItemProperty -Path $path -Name $name `
            -ErrorAction Stop | Select-Object -ExpandProperty $name)
        if ($valueCurrent -eq $valueDesired) {
            Write-Host "The system is compliant."
            return 0
        } 
        else {
            Write-Host "The system is not compliant."
            return 1
        }
    }

    $complianceStatus = Test-IsCompliant

    if ($complianceStatus -eq 0) {
        exit 0
    } else {
        exit 1
    }

}

end { Stop-Transcript }