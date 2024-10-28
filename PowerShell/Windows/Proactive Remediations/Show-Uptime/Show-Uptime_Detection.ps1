<#
.SYNOPSIS
    Detects whether or not the device has rebooted in the past week.
    
.DESCRIPTION
    This script, which functions as the detecttion portion of the Show Uptime proactive remediation 
    for use in Microsoft Intune, detects whether or not the device has rebooted in the past week.

.NOTES
    FileName:       Show-Uptime_Detection.ps1
    Created:        10/28/2024
    Updated:        10/28/2024
    Author:         Michael J. Mattingly
    
    Version History:

    1.0.1 - Release

#>

begin {

    $logPath = "C:\PS\Logs\Show-Uptime_Detection.log"
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
            [int]$maxDays = 7
        )

        $os = (Get-CimInstance -ClassName "Win32_OperatingSystem")
        $uptime = (Get-Date) - ($os.LastBootUpTime)
        $uptimeInDays = ($uptime).Days

        if ($uptimeInDays -ge $maxDays) {
            Write-Host "This devices hasn't rebooted in the past $maxDays days."
            Write-Host "The user will be notified."
            Write-Host "The remediation script will run."
            return 1
        } else {
            Write-Host "This device has rebooted in the past $maxDays day(s)."
            Write-Host "The user won't be notified."
            Write-Host "The remediation script will not run."
            return 0
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