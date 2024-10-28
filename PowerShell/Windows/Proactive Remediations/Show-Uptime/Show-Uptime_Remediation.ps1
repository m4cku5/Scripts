<#
.SYNOPSIS
    Displays Toast Notification to user if device hasn't rebooted in a week.
    
.DESCRIPTION
    This script, which functions as the remediation portion of the Show Uptime proactive remediation 
    for use in Microsoft Intune, displays Toast Notification to user if device hasn't rebooted in a week.

.NOTES
    FileName:       Show-Uptime_Remediation.ps1
    Created:        10/28/2024
    Updated:        10/28/2024
    Author:         Michael J. Mattingly
    
    Version History:

    1.0.1 - Release

#>

begin {

    $logPath = "C:\PS\Logs\Show-Uptime_Remediation.log"
    Start-Transcript -Path $logPath

    $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $isSystem = $currentIdentity.IsSystem
    
    if ($isSystem -eq $false) {
        Write-Error 'This script needs to run as SYSTEM.'
        return
    }

}

process {
    
    function Show-Notification {
        [CmdletBinding()]
        param (
            [string]$ToastTitle,
            [string]
            [parameter(ValueFromPipeline)]
            $ToastText
        )

        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
        $Template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)

        $RawXml = [xml] $Template.GetXml()
        ($RawXml.toast.visual.binding.text|Where-Object {$_.id -eq "1"}).AppendChild($RawXml.CreateTextNode($ToastTitle)) > $null
        ($RawXml.toast.visual.binding.text|Where-Object{$_.id -eq "2"}).AppendChild($RawXml.CreateTextNode($ToastText)) > $null

        $SerializedXml = New-Object Windows.Data.Xml.Dom.XmlDocument
        $SerializedXml.LoadXml($RawXml.OuterXml)

        $Toast = [Windows.UI.Notifications.ToastNotification]::new($SerializedXml)
        $Toast.Tag = "PowerShell"
        $Toast.Group = "PowerShell"
        $Toast.ExpirationTime = [DateTimeOffset]::Now.AddMinutes(1)

        $Notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("PowerShell")
        $Notifier.Show($Toast);
    }

    Show-Notification -ToastTitle "Restart" `
                      -ToastText "You haven't restarted this device in the " +
                                 "past 7 days. Please do so ASAP."

}

end { Stop-Transcript }