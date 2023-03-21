<#
.SYNOPSIS
    A PowerShell GUI form that displays a clean looking restart prompt to the end user, providing them with options to schedule a restart. 

.DESCRIPTION
    This script will first check for specific registry keys on the local computer and determine if it is pending a reboot. The computer is pending a reboot if it matches any of the following criteria using
    Atera's own guide https://support.atera.com/hc/en-us/articles/4613758024860-Understand-the-Reboot-Required-Indication: 

    - Component Based Servicing 'Reboot Pending' Reg Key

    - Windows Update AU 'Reboot Required' Reg Key

    - Post Reboot Reporting Reg Key

    - Reboot in Progress Reg Key

    - Current Reboot Attempts Reg Key

    - Services Pending containing any sub keys

    - Packages Pending containing any sub keys

    - PendingFileRenameOperations Value or PendingFileRenameOperations2 Value

    Some checks were left out such as NetLogon as this checks if a restart is required after joining a domain and similarly to other checks such as hostname changes that also require restarts. These are not required 
    to determine if a restart is required after Windows has updated. In addition, the PendingFileRenameOperations can cause false positives, so the pending reboot test uses the -and operator to check if any of the other keys exist too alongside it. 

    If only the PendingFileRenameOperations key exists or no keys exist at all, the script will end and output "Reboot not required. Exiting..." and exit the script and not prompt the user to restart. You can change this behaviour on line 321.

    If a restart is required, the script will display a PowerShell Form in the bottom right of the primary screen giving end users a couple of options. They will be able to restart the computer immediately by pressing the 'Restart Now' button or they can select one of either three different options to postpone the restart using the dropdown - 1 hour, 2 hours, and 3 hours. These options can be changed to your desire on lines 122 and 222.

    To prevent the user from circumnavigating the prompt and cancelling the restart altogether, there are a few measures put in place to stop this. 
    - First, on line 265 this prevents the user from closing the form from the Alt + Tab window as well as from pressing Alt + F4 to quit the form. 
    - Secondly, the form border style is set so the minimise, maximise and exit buttons are removed. 
    - Thirdly, the form is locked on the screen and set to TopMost to ensure the user doesn't disregard the prompt and guarantees a restart is done or scheduled. 
    - Lastly, in addition to the 'shutdown -r' command to restart the machine, a secondary hidden PowerShell console window is spawned to execute the restart at the specified time. This is done to prevent the scheduled restart being cancelled using the 'shutdown -a' command that a standard user can execute via cmd. 

    Once a restart has been scheduled or executed, the form and script exits appropriately to ensure the reports you see in Atera show accurate results along with confirmation of the choice the user selected.

.NOTES
    This script is intended to be used with an RMM or script deployment tool, and is ideal for running on a schedule after a patch window. 

    WARNING! The script may need to be run as Current User and NOT with System privileges. Also ensure the script run time is set to at least 30 minutes and not before as the script has a hidden countdown (default 1800 seconds)
    to ensure the form closes with a successful exit code if no input is given by the user. 
#>



# Restart Notification Form GUI
function RestartNotification_Form 
{ 
    # Importing the required assemblies for .NET forms. 
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    Add-Type -AssemblyName System.Data
    [System.Windows.Forms.Application]::EnableVisualStyles() 

    $formObj = [System.Windows.Forms.Form]
    $labelObj = [System.Windows.Forms.Label]
    $buttonObj = [System.Windows.Forms.Button]
    $comboboxObj = [System.Windows.Forms.ComboBox]
    $timerObj = [System.Windows.Forms.Timer]
    $formwindowsObj = [System.Windows.Forms.FormWindowState]

    $MainForm = New-Object $formObj
    $lblTitle = New-Object $labelObj
    $lblMessage = New-Object $labelObj
    $ddlDelay = New-Object $comboboxObj
    $btnPostpone = New-Object $buttonObj
    $btnRestartNow = New-Object $buttonObj
    $timerUpdate = New-Object $timerObj
    $InitialFormWindowState = New-Object $formwindowsObj

    #Fonts
    $fontDefault = 'Arial Regular, 12pt'
    $fontBtn = 'Arial Regular, 12pt'
    $fontTitle = 'Arial Regular, 18pt, style=bold'

    # Form Timer
    $TotalTime = 1800 # Set the timer here in seconds that determines how long the form is displayed to the end user before stopping and executing a force scheduled restart.
    $MainForm_Load={ 
        $script:StartTime = (Get-Date).AddSeconds($TotalTime)  
        $timerUpdate.Start() 
    } 
     
    # Countdown Timer Start and End event
    $timerUpdate_Tick={  
        [TimeSpan]$span = $script:StartTime - (Get-Date)
        $timerUpdate.Start()
        if ($span.TotalSeconds -le 0) 
            { 
                # When the countdown timer ends, the timer stops and a restart is forcefully scheduled. Set this to what you want. 
                $timerUpdate.Stop() 
                Write-Host "Timer ended and restart was forced to scheduled in 3 hours"
                shutdown -r -t 10800 -c " "
                # Create a new hidden powershell window to execute the Start-Sleep restart which prevents users from aborting scheduled restart (shutdown -a). 
                Start-Process powershell.exe -WindowStyle Hidden -ArgumentList '-command Start-Sleep -Seconds 10800; Restart-Computer -Force; Exit 0'
                $MainForm.Close()
                $MainForm.Dispose()
                [environment]::exit(0)
            } 
         
    } 
     
    $btnRestartNow_Click = { 
        Write-Host "Selected to restart now"
        shutdown -r -t 3 -c " " 
        $MainForm.Close()
        $MainForm.Dispose()
        [environment]::exit(0)
    } 
     
    $btnPostpone_Click = {
        $postponeSelection = $ddlDelay.SelectedItem.ToString()

        switch ($postponeSelection) {
            "1 Hour" {  
                Write-Host "Selected to postpone for 1 hour"
                shutdown -r -t 3600 -c " "
                # Create a new hidden powershell window to execute the Start-Sleep restart which prevents users from aborting scheduled restart (shutdown -a) using other method. 
                Start-Process powershell.exe -WindowStyle Hidden -ArgumentList '-command Start-Sleep -Seconds 3600; Restart-Computer -Force; Exit 0'
                $MainForm.Close() 
                $MainForm.Dispose()
                [environment]::exit(0)
            }
            "2 Hours" {
                Write-Host "Selected to postpone for 2 hours"
                shutdown -r -t 7200 -c " "
                # Create a new hidden powershell window to execute the Start-Sleep restart which prevents users from aborting scheduled restart (shutdown -a) using other method. 
                Start-Process powershell.exe -WindowStyle Hidden -ArgumentList '-command Start-Sleep -Seconds 7200; Restart-Computer -Force; Exit 0'
                $MainForm.Close() 
                $MainForm.Dispose()
                [environment]::exit(0)
            }
            "3 Hours" {
                Write-Host "Selected to postpone for 3 hours"
                shutdown -r -t 10800 -c " "
                # Create a new hidden powershell window to execute the Start-Sleep restart which prevents users from aborting scheduled restart (shutdown -a) using other method. 
                Start-Process powershell.exe -WindowStyle Hidden -ArgumentList '-command Start-Sleep -Seconds 10800; Restart-Computer -Force; Exit 0'
                $MainForm.Close() 
                $MainForm.Dispose()
                [environment]::exit(0)
            }
        }
    }
     
    $Form_StateCorrection_Load= 
    { 
        $MainForm.WindowState = $InitialFormWindowState 
    } 
     
    $Form_StoreValues_Closing= 
    { 
    } 
 
    $Form_Cleanup_FormClosed= 
    { 
        try 
        { 
            $btnPostpone.remove_Click($btnPostpone_Click) 
            $btnRestartNow.remove_Click($btnRestartNow_Click) 
            $labelTime.remove_Click($labelTime_Click) 
            $MainForm.remove_Load($MainForm_Load) 
            $timerUpdate.remove_Tick($timerUpdate_Tick) 
            $MainForm.remove_Load($Form_StateCorrection_Load) 
            $MainForm.remove_Closing($Form_StoreValues_Closing) 
            $MainForm.remove_FormClosed($Form_Cleanup_FormClosed) 
        } 
        catch [Exception] 
        { } 
    } 

    $MainForm.SuspendLayout() 
    $lblTitle.SuspendLayout()
    $lblMessage.SuspendLayout()
    $btnRestartNow.SuspendLayout()
    $btnPostpone.SuspendLayout()
    $ddlDelay.SuspendLayout()
 
    $MainForm.Controls.AddRange(@($lblTitle,$lblMessage,$ddlDelay,$btnRestartNow,$btnPostpone))

    # Form styling

    $monitor = [System.Windows.Forms.Screen]::PrimaryScreen 
    [void]::$monitor.WorkingArea.Width
    $MainForm.ClientSize = '600, 300' 
    $MainForm.Location = New-Object System.Drawing.Point(0,0)
    $MainForm.StartPosition = "manual"
    $MainForm.Left = $monitor.WorkingArea.Width - $MainForm.Width # Setting the form to open in the bottom right of the primary screen
    $MainForm.Top = $monitor.WorkingArea.Height - $MainForm.Height
    $MainForm.Name = 'MainForm' 
    $MainForm.MaximizeBox = $False 
    $MainForm.MinimizeBox = $False 
    $MainForm.ShowIcon = $False 
    $MainForm.ShowInTaskbar = $False  
    $MainForm.TopMost = $True 
    $MainForm.FormBorderStyle = 'None'
    $MainForm.Font =  $fontDefault
    $MainForm.add_Load($MainForm_Load) 

    $lblTitle.ClientSize = '600,70'
    $lblTitle.Text = "Updates Require Restart"
    $lblTitle.Font =  $fontTitle
    $lblTitle.BackColor = '#021C41'
    $lblTitle.TextAlign = 'MiddleCenter'
    $lblTitle.ForeColor = 'White'

    $lblMessage.ClientSize = '520,40'
    $lblMessage.Location = New-Object System.Drawing.Point(40,90)
    $lblMessage.Text = "Important updates require a computer restart. Please save your work now and restart, or select a time below to postpone the restart."
    $lblMessage.Font = $fontDefault
    $lblMessage.ForeColor = '#021C41'

    $ddlDelay.ClientSize = '515,40'
    $ddlDelay.DropDownStyle = 'DropDownList'
    $ddlDelay.Location = New-Object System.Drawing.Point(40,165)
    $ddlDelayOptions = '1 Hour','2 Hours','3 Hours'
    $ddlDelay.Items.AddRange($ddlDelayOptions)
    $ddlDelay.SelectedIndex = 0

    $btnPostpone.Location = New-Object System.Drawing.Point(40,240)
    $btnPostpone.Text = 'Postpone'
    $btnPostpone.Font = $fontBtn
    $btnPostpone.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btnPostpone.ClientSize = '240,40'
    $btnPostpone.BackColor = '#021C41'
    $btnPostpone.ForeColor = 'White'
    $btnPostpone.FlatAppearance.BorderSize = 0
    $btnPostpone.Add_MouseEnter({
        $btnPostpone.backcolor = [System.Drawing.ColorTranslator]::FromHtml("White")
        $btnPostpone.forecolor = [System.Drawing.ColorTranslator]::FromHtml("#021C41")
        $btnPostpone.Cursor = 'Hand'
        $btnPostpone.FlatAppearance.BorderSize = 1
        $btnPostpone.FlatAppearance.BorderColor = [System.Drawing.ColorTranslator]::FromHtml('#021C41')
    })
    $btnPostpone.Add_MouseLeave({
        $btnPostpone.backcolor = [System.Drawing.ColorTranslator]::FromHtml("#021C41")
        $btnPostpone.forecolor = [System.Drawing.ColorTranslator]::FromHtml("White")
    })
    $btnPostpone.add_Click($btnPostpone_Click) 

    $btnRestartNow.Text = 'Restart Now'
    $btnRestartNow.Font = $fontBtn
    $btnRestartNow.Location = New-Object System.Drawing.Point(320,240)
    $btnRestartNow.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btnRestartNow.ClientSize = '240,40'
    $btnRestartNow.BackColor = '#021C41'
    $btnRestartNow.ForeColor = 'White'
    $btnRestartNow.FlatAppearance.BorderSize = 0
    $btnRestartNow.Add_MouseEnter({
        $btnRestartNow.backcolor = [System.Drawing.ColorTranslator]::FromHtml("White")
        $btnRestartNow.forecolor = [System.Drawing.ColorTranslator]::FromHtml("#021C41")
        $btnRestartNow.Cursor = 'Hand'
        $btnRestartNow.FlatAppearance.BorderSize = 1
        $btnRestartNow.FlatAppearance.BorderColor = [System.Drawing.ColorTranslator]::FromHtml('#021C41')
    })
    $btnRestartNow.Add_MouseLeave({
        $btnRestartNow.backcolor = [System.Drawing.ColorTranslator]::FromHtml("#021C41")
        $btnRestartNow.forecolor = [System.Drawing.ColorTranslator]::FromHtml("White")
    })
    $btnRestartNow.add_Click($btnRestartNow_Click) 

    $timerUpdate.add_Tick($timerUpdate_Tick) 
    $MainForm.ResumeLayout() 
    $lblTitle.ResumeLayout()
    $lblMessage.ResumeLayout()
    $btnRestartNow.ResumeLayout()
    $btnPostpone.ResumeLayout()
    $ddlDelay.ResumeLayout()
    $InitialFormWindowState = $MainForm.WindowState 
    $MainForm.add_Load($Form_StateCorrection_Load) 
    $MainForm.add_FormClosed($Form_Cleanup_FormClosed) 
    $MainForm.add_Closing($Form_StoreValues_Closing) 

    # Prevent the user from closing form manually.
    $MainForm.add_FormClosing({$_.Cancel=$true})  

    return $MainForm.ShowDialog() 
}

#  Confirms if a restart is required by checking the following registry keys. To avoid false positives the $RebootRequired variable only confirms a reboot is required if the pending filerename operations returns true along with any of the other keys
function CheckRestartRequired {
    try {
        # Check for Component Based Servicing 'Reboot Pending' Reg Key
        $regcheckRebootPending = Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -EA Ignore

        # Check for Windows Update AU 'Reboot Required' Reg Key
        $regcheckRebootRequired = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -EA Ignore

        # Check for Post Reboot Reporting Reg Key
        $regcheckPostRebootReporting = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\PostRebootReporting" -EA Ignore

        # Check for Reboot in Progress Reg Key
        $regcheckRebootInProgress = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootInProgress" -EA Ignore

        # Check for Current Reboot Attempts Reg Key
        $regcheckCurrentRebootAttempts = Test-Path "HKLM:\SOFTWARE\Microsoft\ServerManager\CurrentRebootAttempts" -EA Ignore

        # Check for Services\Pending containing any sub keys
        $regcheckServicesPending = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Services\Pending\*" -EA Ignore

        # Check for Packages Pending containing any sub keys
        $regcheckPackagesPending = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\PackagesPending" -EA Ignore

        # Check for PendingFileRenameOperations Value
        $regcheckFileRenameOp1 = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager").PSObject.Properties.Name 
        $regcheckFileRenameOp1_Results = if ($regcheckFileRenameOp1 -contains "PendingFileRenameOperations") {$true} else { $false}

        # Check for PendingFileRenameOperations2 Value
        $regcheckFileRenameOp2 = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager").PSObject.Properties.Name 
        $regcheckFileRenameOp2_Results = if ($regcheckFileRenameOp2 -contains "PendingFileRenameOperations2") {$true} else { $false}

        # Reboot Required if any of the registry keys/values return $true
        $RebootRequired = $regcheckFileRenameOp1_Results -or $regcheckFileRenameOp2_Results -and $regcheckRebootPending -or $regcheckRebootRequired -or $regcheckServicesPending -or $regcheckPostRebootReporting -or $regcheckCurrentRebootAttempts -or $regcheckPackagesPending -or $regcheckRebootInProgress

        if ($RebootRequired -eq $true) {
            [PSCustomObject]@{
                RebootRequired = 'Yes'
                ComponentBasedServicing = $regcheckRebootPending
                WindowsUpdateAU = $regcheckRebootRequired
                PendingFileRenameOperations = $regcheckFileRenameOp1_Results
                PendingFileRenameOperations2 = $regcheckFileRenameOp2_Results
                ServicesPending = $regcheckServicesPending
                PackagesPending = $regcheckPackagesPending
                PostRebootReporting = $regcheckPostRebootReporting
                CurrentRebootAttempts = $regcheckCurrentRebootAttempts
                RebootInProgress = $regcheckRebootInProgress

            }
        }
            else {
                [PSCustomObject]@{
                    RebootRequired = 'No'
                }
            }  

    }
    catch {
        $hostpc = hostname
        Write-Warning "$hostpc`: $_"
    }
} 

# First function to determine if a restart is required, if not it exits. If it does, the form is executed. 
function Check {
    if ((CheckRestartRequired).RebootRequired -eq 'Yes') {
        RestartNotification_Form # Executes the form that displays the prompt to the user
    }
        else {
            Write-Host "Reboot not required. Exiting..."
            Exit 0 # If a restart is not required, it exits successfully for better reporting. 
        }

}
Check
