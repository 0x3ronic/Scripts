<#
.SYNOPSIS
    A PowerShell GUI to manage your local services. Essentially Task Manager with the services control in one place. 

.NOTES
    Admin privileges will be required to manage certain services. 
#>

# Importing the Windows Forms DLL to be able to create the Form
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$FormObj1 = [System.Windows.Forms.Form]
$LabelObj1 = [System.Windows.Forms.Label]
$ButtonObj1 = [System.Windows.Forms.Button]
$ComboboxObj1 = [System.Windows.Forms.ComboBox]

#Fonts
$fontDefault = 'Arial, 11pt'
$fontTitle1 = 'Arial, 15pt, style=bold'

#Form Icon PNG in Base64
$icon1 = 'iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAFBmlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4KPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNS41LjAiPgogPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIgogICAgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIgogICAgeG1sbnM6cGhvdG9zaG9wPSJodHRwOi8vbnMuYWRvYmUuY29tL3Bob3Rvc2hvcC8xLjAvIgogICAgeG1sbnM6ZXhpZj0iaHR0cDovL25zLmFkb2JlLmNvbS9leGlmLzEuMC8iCiAgICB4bWxuczp0aWZmPSJodHRwOi8vbnMuYWRvYmUuY29tL3RpZmYvMS4wLyIKICAgIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIgogICAgeG1sbnM6c3RFdnQ9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZUV2ZW50IyIKICAgeG1wOkNyZWF0ZURhdGU9IjIwMjMtMDItMDlUMjE6NDg6NDYrMDAwMCIKICAgeG1wOk1vZGlmeURhdGU9IjIwMjMtMDItMDlUMjE6NTM6MTVaIgogICB4bXA6TWV0YWRhdGFEYXRlPSIyMDIzLTAyLTA5VDIxOjUzOjE1WiIKICAgcGhvdG9zaG9wOkRhdGVDcmVhdGVkPSIyMDIzLTAyLTA5VDIxOjQ4OjQ2KzAwMDAiCiAgIHBob3Rvc2hvcDpDb2xvck1vZGU9IjMiCiAgIHBob3Rvc2hvcDpJQ0NQcm9maWxlPSJzUkdCIElFQzYxOTY2LTIuMSIKICAgZXhpZjpQaXhlbFhEaW1lbnNpb249IjIwIgogICBleGlmOlBpeGVsWURpbWVuc2lvbj0iMjAiCiAgIGV4aWY6Q29sb3JTcGFjZT0iMSIKICAgdGlmZjpJbWFnZVdpZHRoPSIyMCIKICAgdGlmZjpJbWFnZUxlbmd0aD0iMjAiCiAgIHRpZmY6UmVzb2x1dGlvblVuaXQ9IjIiCiAgIHRpZmY6WFJlc29sdXRpb249IjE0NC8xIgogICB0aWZmOllSZXNvbHV0aW9uPSIxNDQvMSI+CiAgIDx4bXBNTTpIaXN0b3J5PgogICAgPHJkZjpTZXE+CiAgICAgPHJkZjpsaQogICAgICBzdEV2dDphY3Rpb249InByb2R1Y2VkIgogICAgICBzdEV2dDpzb2Z0d2FyZUFnZW50PSJBZmZpbml0eSBEZXNpZ25lciAyLjAuMCIKICAgICAgc3RFdnQ6d2hlbj0iMjAyMy0wMi0wOVQyMTo1MzoxNVoiLz4KICAgIDwvcmRmOlNlcT4KICAgPC94bXBNTTpIaXN0b3J5PgogIDwvcmRmOkRlc2NyaXB0aW9uPgogPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KPD94cGFja2V0IGVuZD0iciI/PkUTiIYAAAGBaUNDUHNSR0IgSUVDNjE5NjYtMi4xAAAokXWRu0sDQRCHvySKr4iCChYWh0QrIzFC0MYiQaOgFkkEX01y5iHkcdxFRGwF24CCaOOr0L9AW8FaEBRFEFutFW00nHNGSBAzy+x8+9udYXcW7JG0mjFqPJDJ5vVQ0K/Mzs0rdc/YaaADD0pUNbSp8FiEqvZxh82KN26rVvVz/1rTUtxQwVYvPKJqel54XHhyNa9ZvC3crqaiS8Knwn26XFD41tJjJX6xOFniL4v1SCgA9lZhJVnBsQpWU3pGWF6OK5NeUX/vY73EGc/OhCV2i3dhECKIH4UJRgngY4BhmX248dIvK6rke37yp8lJriqzxho6yyRJkadP1BWpHpeYED0uI82a1f+/fTUSg95Sdacfap9M860H6ragWDDNz0PTLB6B4xEusuX83AEMvYteKGuufWjZgLPLshbbgfNN6HzQonr0R3KI2xMJeD2B5jlou4bGhVLPfvc5vofIunzVFezuQa+cb1n8BoyAZ/c9aWijAAAACXBIWXMAABYlAAAWJQFJUiTwAAABwUlEQVQ4jaXUz4uNURgH8M99k4ZsFCZ6bfzaYJaT8vPNgpISkq0yFBt2KDshK3+AspqVjTQ75aihGE3MmihOZHZ+NGManbG499a9r/MO8l2d8z3f5/uc5/SchwYUZbW2KKttGb4qympNU1wrE7AOlzCCeVzEFxTYiGuYw13cTDF86I1fkklyBec76wHcyWiW4Rxe43bfhTLiH03lNBj3oa/koqyGMY6lf2k4hz0phonfDIuyWo1JrM8ELtST9+Aj9uFNimGhVZTVAF5gA5bXxBEX8FD7efbjVkdbx3esahVltRNPMoJpbE8xTPeSRVmtxUsMZmJ2FdjRUMr1uhmkGD7hRkPM7gLv8S1zOJHhushV9BbjRYrhHg5lBCsWMVyZ4U6kGJ52+/AZZmqCo4sYHqvtZzFFp7FTDPMd016cLcrqeN2pw43U6MkUw0/6+/Ax9mZucx+PtP/1ARzJaN5ha4phttUxG8bzjPBfcDjFMNYteQKj/2E2mmIYo3/anMYW7QeewcE/mDzQbv5NONMl68OhlWJY6KyHcBkna0ZjuJpieJXL0vThe5NMYaiz/YrBFEPjiMsN2DpOYTMSPi9mBr8AK7iAzceNxSUAAAAASUVORK5CYII='
$iconBytes1 = [Convert]::FromBase64String($icon1)
# Initialise a Memory stream holding the bytes
$stream1 = [System.IO.MemoryStream]::new($iconBytes1, 0, $iconBytes1.Length)

# Main App Form
$AppForm = New-Object $FormObj1
$AppForm.Icon = [System.Drawing.Icon]::FromHandle(([System.Drawing.Bitmap]::new($stream1).GetHIcon()))
$AppForm.ClientSize = '700,400'
$AppForm.Text = 'Service Status Tool'
$AppForm.TopMost = $true
$AppForm.Font = $fontDefault
$AppForm.StartPosition = 'CenterScreen'

$lblTitle = New-Object $LabelObj1
$lblTitle.ClientSize = '700,50'
$lblTitle.Text = "Service Status"
$lblTitle.Font = $fontTitle1
$lblTitle.BackColor = '#021C41'
$lblTitle.TextAlign = 'MiddleCenter'
$lblTitle.ForeColor = 'White'

# Services
$lblService = New-Object $LabelObj1
$lblService.Text = 'Services:'
$lblService.AutoSize = $true
$lblService.Location = New-Object System.Drawing.Point(40,80)

# Dropdown Menu
$ddlService = New-Object $ComboboxObj1
$ddlService.Width = '400'
$ddlService.Location = New-Object System.Drawing.Point(125,75)
$ddlService.Text = 'Pick a service...'

# Load the dropdown menu with only the name of the service
Get-Service | ForEach-Object {$ddlService.Items.Add($_.Name)}

$lblForName = New-Object $LabelObj1
$lblForName.Text = 'Display Name:'
$lblForName.AutoSize = $true
$lblForName.Location = New-Object System.Drawing.Point(40,150)

$lblName = New-Object $LabelObj1
$lblName.AutoSize = $true
$lblName.Location = New-Object System.Drawing.Point(155,150)

$lblStartup = New-Object $LabelObj1
$lblStartup.Text = 'Start Type:'
$lblStartup.AutoSize = $true
$lblStartup.Location = New-Object System.Drawing.Point(40,190)

$lblType = New-Object $LabelObj1
$lblType.AutoSize = $true
$lblType.Location = New-Object System.Drawing.Point(155,190)

$lblForStatus = New-Object $LabelObj1
$lblForStatus.Text = 'Status:'
$lblForStatus.AutoSize = $true
$lblForStatus.Location = New-Object System.Drawing.Point(40,230)

$lblStatus = New-Object $LabelObj1
$lblStatus.AutoSize = $true
$lblStatus.Location = New-Object System.Drawing.Point(155,230)

# Buttons
$btnStart = New-Object $ButtonObj1
$btnStart.Location = New-Object System.Drawing.Point(40,280)
$btnStart.Text = 'Start'
$btnStart.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnStart.ClientSize = '100,40'
$btnStart.BackColor = '#12BF00'
$btnStart.ForeColor = 'White'
$btnStart.FlatAppearance.BorderSize = 0
$btnStart.Add_MouseEnter({
    $btnStart.backcolor = [System.Drawing.ColorTranslator]::FromHtml("#0C8000")
    $btnStart.forecolor = [System.Drawing.ColorTranslator]::FromHtml("White")
    $btnStart.Cursor = 'Hand'
})
$btnStart.Add_MouseLeave({
    $btnStart.backcolor = [System.Drawing.ColorTranslator]::FromHtml("#12BF00")
    $btnStart.forecolor = [System.Drawing.ColorTranslator]::FromHtml("White")
})

$btnStop = New-Object $ButtonObj1
$btnStop.Location = New-Object System.Drawing.Point(180,280)
$btnStop.Text = 'Stop'
$btnStop.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnStop.ClientSize = '100,40'
$btnStop.BackColor = '#D22B2B'
$btnStop.ForeColor = 'White'
$btnStop.FlatAppearance.BorderSize = 0
$btnStop.Add_MouseEnter({
    $btnStop.backcolor = [System.Drawing.ColorTranslator]::FromHtml("#8B0000")
    $btnStop.forecolor = [System.Drawing.ColorTranslator]::FromHtml("White")
    $btnStop.Cursor = 'Hand'
})
$btnStop.Add_MouseLeave({
    $btnStop.backcolor = [System.Drawing.ColorTranslator]::FromHtml("#D22B2B")
    $btnStop.forecolor = [System.Drawing.ColorTranslator]::FromHtml("White")
})

$btnRestart = New-Object $ButtonObj1
$btnRestart.Location = New-Object System.Drawing.Point(320,280)
$btnRestart.Text = 'Restart'
$btnRestart.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnRestart.ClientSize = '100,40'
$btnRestart.BackColor = '#021C41'
$btnRestart.ForeColor = 'White'
$btnRestart.FlatAppearance.BorderSize = 0
$btnRestart.Add_MouseEnter({
    $btnRestart.backcolor = [System.Drawing.ColorTranslator]::FromHtml("White")
    $btnRestart.forecolor = [System.Drawing.ColorTranslator]::FromHtml("#021C41")
    $btnRestart.Cursor = 'Hand'
    $btnRestart.FlatAppearance.BorderSize = 1
    $btnRestart.FlatAppearance.BorderColor = [System.Drawing.ColorTranslator]::FromHtml('#021C41')
})
$btnRestart.Add_MouseLeave({
    $btnRestart.backcolor = [System.Drawing.ColorTranslator]::FromHtml("#021C41")
    $btnRestart.forecolor = [System.Drawing.ColorTranslator]::FromHtml("White")
})

# Start type dropdown
$ddlType = New-Object $ComboboxObj1
$ddlType.Width = '200'
$ddlType.Location = New-Object System.Drawing.Point(450,285)
$ddlType.Text = 'Change Start Type...'

$btnConfirmType = New-Object $ButtonObj1
$btnConfirmType.Text = 'Confirm'
$btnConfirmType.Location = New-Object System.Drawing.Point(500,330)
$btnConfirmType.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnConfirmType.ClientSize = '100,40'
$btnConfirmType.BackColor = '#021C41'
$btnConfirmType.ForeColor = 'White'
$btnConfirmType.FlatAppearance.BorderSize = 0
$btnConfirmType.Add_MouseEnter({
    $btnConfirmType.backcolor = [System.Drawing.ColorTranslator]::FromHtml("White")
    $btnConfirmType.forecolor = [System.Drawing.ColorTranslator]::FromHtml("#021C41")
    $btnConfirmType.Cursor = 'Hand'
    $btnConfirmType.FlatAppearance.BorderSize = 1
    $btnConfirmType.FlatAppearance.BorderColor = [System.Drawing.ColorTranslator]::FromHtml('#021C41')
})
$btnConfirmType.Add_MouseLeave({
    $btnConfirmType.backcolor = [System.Drawing.ColorTranslator]::FromHtml("#021C41")
    $btnConfirmType.forecolor = [System.Drawing.ColorTranslator]::FromHtml("White")
})

# Drop down startup items
$ddlStartupTypes = @("Automatic","Manual","Disabled")

foreach($StartupType in $ddlStartupTypes){
    $ddlType.Items.Add($StartupType)
}

$btnRefresh = New-Object $ButtonObj1
$btnRefresh.Text = 'Refresh'
$btnRefresh.Location = New-Object System.Drawing.Point(550,68)
$btnRefresh.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnRefresh.ClientSize = '100,40'
$btnRefresh.BackColor = '#021C41'
$btnRefresh.ForeColor = 'White'
$btnRefresh.FlatAppearance.BorderSize = 0
$btnRefresh.Add_MouseEnter({
    $btnRefresh.backcolor = [System.Drawing.ColorTranslator]::FromHtml("White")
    $btnRefresh.forecolor = [System.Drawing.ColorTranslator]::FromHtml("#021C41")
    $btnRefresh.Cursor = 'Hand'
    $btnRefresh.FlatAppearance.BorderSize = 1
    $btnRefresh.FlatAppearance.BorderColor = [System.Drawing.ColorTranslator]::FromHtml('#021C41')
})
$btnRefresh.Add_MouseLeave({
    $btnRefresh.backcolor = [System.Drawing.ColorTranslator]::FromHtml("#021C41")
    $btnRefresh.forecolor = [System.Drawing.ColorTranslator]::FromHtml("White")
})

# Log Text Box
$output = New-Object System.Windows.Forms.RichTextBox
$output.Location = New-Object System.Drawing.Point(40,360)
$output.ClientSize = '380,50'
$output.Multiline = $true
$output.ScrollBars = 'Vertical'
$output.ReadOnly = $true
$output.BorderStyle = 0
$output.BackColor = '#F0F0F0'

$AppForm.Controls.AddRange(@($lblService,$ddlService,$lblForName,$lblName,$lblForStatus,$lblStartup,$lblType,$lblStatus,$lblTitle,$btnStart,$btnStop,$btnRestart,$ddlType,$btnConfirmType,$btnRefresh,$output))

# Form Functions
function GetServiceDetails {
    $ServiceName = $ddlService.SelectedItem
    $details = Get-Service -Name $ServiceName | Select-Object *
    $lblName.Text = $details.DisplayName
    $lblType.Text = $details.StartType
    $lblStatus.Text = $details.Status
    $output.Text = ''

    if ($lblStatus.Text -eq 'Running') {
        $lblStatus.ForeColor = 'Green'
    }
        else {
            $lblStatus.ForeColor = 'Red'
        }
}

# Control Functions
$ddlService.Add_SelectedIndexChanged({GetServiceDetails})

# Button Functions
function StartService {
    $ServiceName = $ddlService.SelectedItem
    $svcStart = Start-Service -Name $ServiceName 

    if ($lblStatus.Text -eq 'Running') {
        $output.Text = " > This service is already running."
        $output.ForeColor = 'Red'
    }
        else {
            $svcStart
            $output.Text = " > The service has been started..."
            $output.ForeColor = 'Green'
        }
}

$btnStart.Add_Click({
    if (!$ddlService.SelectedItem){
    }
        else {
            StartService
        }
})

function StopService {
    $ServiceName = $ddlService.SelectedItem
    $svcStop = Stop-Service -Name $ServiceName 

    if ($lblStatus.Text -eq 'Stopped') {
        $output.Text = " > This service is already stopped."
        $output.ForeColor = 'Red'
    }
        else {
            $svcStop
            $output.Text = " > The service has been stopped..."
            $output.ForeColor = 'Green'
        }
}

$btnStop.Add_Click({
    if (!$ddlService.SelectedItem){
    }
        else {
            StopService
        }
})

function RestartService {
    $ServiceName = $ddlService.SelectedItem
    $svcRestart = Restart-Service -Name $ServiceName 
    $svcRestart
    $output.Text = " > The service is restarting..."
    $output.ForeColor = 'Green'
}

$btnRestart.Add_Click({
    if (!$ddlService.SelectedItem){
    }
        else {
            RestartService
        }
})

# Refresh Button Function
function refresh {
    $ServiceName = $ddlService.SelectedItem
    $details = Get-Service -Name $ServiceName | Select-Object *
    $lblName.Text = $details.DisplayName
    $lblType.Text = $details.StartType
    $lblStatus.Text = $details.Status
    $output.Text = ''

    if ($lblStatus.Text -eq 'Running') {
            $lblStatus.ForeColor = 'Green'
        }
            else {
                $lblStatus.ForeColor = 'Red'
            }
}

$btnRefresh.Add_Click({
    if (!$ddlService.SelectedItem){
    }
        else {
            refresh
        }
})

function confirmType {
    $ServiceName = $ddlService.SelectedItem
    $typeSelection = $ddlType.SelectedItem.ToString()

    switch ($typeSelection) {
        "Automatic" 
        {Set-Service -Name $ServiceName -StartupType Automatic
        $output.Text = " > Start up type set to Automatic"
        $output.ForeColor = 'Green'}
        "Manual" 
        {Set-Service -Name $ServiceName -StartupType Manual
        $output.Text = " > Start up type set to Manual"
        $output.ForeColor = 'Green'}
        "Disabled" {Set-Service -Name $ServiceName -StartupType Disabled
        $output.Text = " > Start up type set to Disabled"
        $output.ForeColor = 'Green'}}
    } 

$btnConfirmType.Add_Click({
    if (!$ddlService.SelectedItem){
    }
        else {
            confirmType
        }
})


[void] $AppForm.ShowDialog()
# Trash bin
$stream1.Dispose()
$AppForm.Dispose()
