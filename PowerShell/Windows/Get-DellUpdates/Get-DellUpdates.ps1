<#
.SYNOPSIS
    This script installs Dell updates via the DC|U application.

.DESCRIPTION
    This script uses the Dell Command | Update (DC|U) application to perform 
    the following tasks.

    - Checks to see if DC|U app is installed.
    - Scans for Dell updates with DC|U app.
    - Temporarily suspends BitLocker if updates are found.
    - Downloads and installs Dell updates.

.PARAMETERS

.EXAMPLE
    PS> .\Get-DellUpdates.ps1

.NOTES
    Author:             Michael J. Mattingly
    Created:            10/31/2024
    Version:            1.0.0
    Version History:

    1.0.0 - Release

#>

begin {

    # Define the log path.
    $logPath = "C:\Logs\PowerShell\Get-DellUpdates.log"

    # Start logging the session.
    Start-Transcript -Path $logPath

    # Get the current Windows identity.
    $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $isSystem = $currentIdentity.IsSystem
    
    # Check if the script is running as SYSTEM.
    if (-not $isSystem) {
        Write-Error 'This script needs to run as SYSTEM.'
        return
    }

}

process {

    # Install available Dell updates.
    function Install-Updates {  

        [CmdletBinding()]
        Param(
            [Parameter(Mandatory = $false, ValueFromPipeline = $false)]
            [string]$functionName = $($MyInvocation.MyCommand).Name
        )

        try {
            # Define error messages.
            $errorMessages = @{
                1000 = (
                    "An error occurred when retrieving the result of the " +
                    "applyupdates operation. [1000]"
                )
                1001 = (
                    "The cancellation was initiated, Hence, the apply " +
                    "updates operation is canceled. [1001]"
                )
                1002 = (
                    "An error occurred while downloading a file during the " +
                    "apply updates operation. [1002]"
                )
            }

            # Define log file path.
            $logPath = "C:\Logs\PowerShell\Get-DellUpdates_Install-Updates.log"
            
            Write-Host "`nRunning $functionName function."

            $applyUpdateArgs = "/applyUpdates -reboot=`"disable`" -silent " +
                "-outputLog=`"$logPath`""

            $applyUpdateProcess = Start-Process -FilePath "$dcuPath" `
                -ArgumentList "$applyUpdateArgs" -Wait -NoNewWindow -PassThru

            if ($errorMessages.ContainsKey($applyUpdateProcess.ExitCode)) {
                Write-Error $errorMessages[$applyUpdateProcess.ExitCode]
            }
        
        } catch {

            $errorMessage = (
                "\nAn error occurred while running the `"$functionName`"" +
                "function. [1]"
            )

            Write-Error $errorMessage
            exit 1
        }
    }

    # Enable temporary suspension of BitLocker.
    function Set-AutoSuspendBitLocker {

        [CmdletBinding()]
        Param(
            [Parameter(Mandatory = $false, ValueFromPipeline = $false)]
            [string]$functionName = $($MyInvocation.MyCommand).Name
        )
        
        try {
            # Define error messages.
            $errorMessages = @{
                1 = "`nUnable to enable -autoSuspendBitLocker. [1]"
            }

            Write-Host "`nRunning $functionName function."
            $suspendBitLockerArgs = "/configure " +
                "-autoSuspendBitLocker=`"enable`""

            $suspendBitLockerProcess = Start-Process -FilePath "$dcuPath" `
                -ArgumentList "$suspendBitLockerArgs" -Wait -NoNewWindow `
                -PassThru

            if ($errorMessages.ContainsKey($suspendBitLockerProcess.ExitCode)) {
                Write-Error $errorMessages[$suspendBitLockerProcess.ExitCode]
            }

        } catch {

            $error_catch = (
                "\nAn error occurred while running the `"$functionName`"" +
                "function. [1]"
            )

            Write-Error $error_catch
            exit 1
        }
    }
    # Check if BitLocker is enabled.
    function Test-BitLockerIsEnabled {

        [CmdletBinding()]
        Param(
            [Parameter(Mandatory = $false, ValueFromPipeline = $false)]
            [string]$functionName = $($MyInvocation.MyCommand).Name
        )

        try {

            $bitLockerProtectionStatus = (Get-BitLockerVolume).ProtectionStatus

            if ($bitLockerProtectionStatus -eq "On") {
                return $true
            } else {
                return $false
            }

        } catch {

            $errorMessage = (
                "\nAn error occurred while running the `"$functionName`"" +
                "function. [1]"
            )

            Write-Error $errorMessage
            return $false
        }
    }

    # Check if DC|U is installed.
    function Test-DcuPath {

        [CmdletBinding()]
        Param(
            [Parameter(Mandatory = $false, ValueFromPipeline = $false)]
            [string]$functionName = $($MyInvocation.MyCommand).Name
        )

        try {

            $dcuPathX86 = "C:\Program Files (x86)\Dell\CommandUpdate\" +
                "dcu-clu.exe"
            $dcuPathX64 = "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe"

            Write-Host "`nRunning $functionName function."
            Write-Host "Searching for the DC|U path..."

            if (Test-Path -Path $dcuPathX86 -PathType leaf) {
                $script:dcuPath = $dcuPathX86
                Write-Host "The path for DC|U is $dcuPath."
                return $true
            } elseif (Test-Path -Path $dcuPathX64 -PathType leaf) {
                $script:dcuPath = $dcuPathX64
                Write-Host "The path for DC|U is $dcuPath."
                return $true
            } else {
                Write-Host "DC|U isn't installed on the device. [1]"
                return $false
            }
        } catch {

            $errorMessage = (
                "\nAn error occurred while running the `"$functionName`"" +
                "function. [1]"
            )

            Write-Error $errorMessage
            return $false
        }
    }

    # Check if updates are available.
    function Test-ForUpdates {

        [CmdletBinding()]
        Param(
            [Parameter(Mandatory = $false, ValueFromPipeline = $false)]
            [string]$functionName = $($MyInvocation.MyCommand).Name
        )

        try {
            # Define error messages.
            $errorMessages = @{
                5 = "`nA reboot was pending from a previous operation. [5]"
                500 = (
                    "`nNo updates were found for the system when a scan " +
                    "operation was performed. [500]"
                )
                501 = (
                    "`nAn error occurred while determining the available " +
                    "updates for the system, when a scan operation was " +
                    "performed. [501]"
                )
                502 = (
                    "`nThe cancellation was initiated, Hence, the scan " +
                    "operation is canceled. [502]"
                )
                503 = (
                    "`nAn error occurred while downloading a file during the " +
                    "scan operation. [503]"
                )
            }

            $logPath = "C:\PS\Logs\Import-DcuSettings_Test-ForUpdates.log"

            Write-Host "`nRunning $functionName function."

            $scanArgs = "/scan -silent -outputLog=`"$logPath`""

            $scanProcess = Start-Process -FilePath "$dcuPath" -ArgumentList `
                "$scanArgs" -Wait -NoNewWindow -PassThru

            if ($scanProcess.ExitCode -eq 500) {
                Write-Host $errorMessages[500]
                return $false
            } elseif ($errorMessages.ContainsKey($scanProcess.ExitCode)) {
                Write-Error $errorMessages[$scanProcess.ExitCode]
                return $false
            } else {
                return $true
            }    

        } catch {

            $errorMessage = (
                "\nAn error occurred while running the `"$functionName`"" +
                "function. [1]"
            )

            Write-Error $errorMessage
            return $false
        }
    }

    $dcuIsInstalled = Test-DcuPath

    if ($dcuIsInstalled) {

        $updatesWereFound = Test-ForUpdates

        if ($updatesWereFound) {

            $bitLockerIsEnabled = Test-BitLockerIsEnabled

            if ($bitLockerIsEnabled) {
                Set-AutoSuspendBitLocker
            }

            Install-Updates

        } else {
            Write-Host "Exiting."
            exit 1
        }

    } else {
        Write-Host "Exiting."
        exit 1
    }

}

end { Stop-Transcript }