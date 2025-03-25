<#
.SYNOPSIS
    Sets the device serial number in Active Directory (AD).
    
.DESCRIPTION
    This script, which can be used as a scheduled task, gets the serial number 
    from the BIOS for each Windows device in a particular organizational unit 
    (OU) and uses it to set the serialNumber attribute in Active Directory (AD) 
    for each device.

.NOTES
    FileName:       Set-SerialNumberInAd.ps1
    Created:        03/25/2025
    Updated:        03/25/2025
    Author:         Michael J. Mattingly
    
    Version History:

    1.0.1 - Release

#>

Try {
    # Import the Active Directory module
    Import-Module ActiveDirectory
} Catch {
    Write-Error "Failed to import Active Directory module: $_"
}

# Specify the OU from which to retrieve computer objects
$ou = "OU=Workstations,DC=<domain>,DC=com"

# Get all computer objects in the specified OU
$computers = Get-ADComputer -Filter * -SearchBase $ou

foreach ($computer in $computers) {
    Try {
        # Get the serial number from the BIOS.
        $biosSerialNumber = (Get-CimInstance -ClassName Win32_BIOS -ComputerName $computer.Name).SerialNumber

        if ($biosSerialNumber) {
            # Update the serialNumber attribute in AD
            Set-ADComputer -Identity $computer -Replace @{serialNumber = $biosSerialNumber}
            Write-Host "Successfully updated the serialNumber for $($computer.Name) to $biosSerialNumber."
        } else {
            Write-Host "Could not retrieve serial number for $($computer.Name)."
        }
    } Catch {
        Write-Host "Failed to retrieve serial number for $($computer.Name): $_"
    }
}