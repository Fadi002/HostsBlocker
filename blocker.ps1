Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
if (!((New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([System.Security.Principal.WindowsBuiltinRole]::Administrator))) {
    [System.Windows.Forms.MessageBox]::Show("This script requires administrative privileges. Please run as Administrator.", "Permission Required", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    exit
}

$hostsPath = "$env:windir\System32\drivers\etc\hosts"

function confirmation {
    Write-Host "Waiting for user confirmation..."
    $result = [System.Windows.Forms.MessageBox]::Show(
        "Blocking these hosts can be dangerous. Are you sure you want to proceed?",
        "Confirmation",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )
    Write-Host "User confirmation result: $result"
    return $result -eq [System.Windows.Forms.DialogResult]::Yes
}



$form = New-Object System.Windows.Forms.Form
$form.Text = "Hosts Blocker"
$form.Size = New-Object System.Drawing.Size(360, 300)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$header = New-Object System.Windows.Forms.Label
$header.Text = "Select categories to block:"
$header.ForeColor = [System.Drawing.Color]::White
$header.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$header.AutoSize = $true
$header.Location = New-Object System.Drawing.Point(17, 17)
$credits = New-Object System.Windows.Forms.Label
$credits.Text = "Made by Fadi002"
$credits.ForeColor = [System.Drawing.Color]::White
$credits.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$credits.AutoSize = $true
$credits.Location = New-Object System.Drawing.Point(17, 216)
$lastupdate = New-Object System.Windows.Forms.Label
$lastupdate.Text = "Last update on:"
$lastupdate.ForeColor = [System.Drawing.Color]::White
$lastupdate.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$lastupdate.AutoSize = $true
$lastupdate.Location = New-Object System.Drawing.Point(192, 197)
$lastupdatedate = New-Object System.Windows.Forms.Label
$lastupdatedate.Text = try { (Invoke-RestMethod -Uri "https://raw.githubusercontent.com/Fadi002/HostsBlocker/main/date" -UseBasicParsing).Trim() } catch { "00/00/0000" }
$lastupdatedate.ForeColor = [System.Drawing.Color]::Green
$lastupdatedate.Font = New-Object System.Drawing.Font("Segoe UI", 9.75, [System.Drawing.FontStyle]::Regular)
$lastupdatedate.AutoSize = $true
$lastupdatedate.Location = New-Object System.Drawing.Point(221, 220)
$pornbox = New-Object System.Windows.Forms.CheckBox
$pornbox.Text = "Block Porn"
$pornbox.ForeColor = [System.Drawing.Color]::White
$pornbox.BackColor = $form.BackColor
$pornbox.Location = New-Object System.Drawing.Point(17, 52)
$adwarebox = New-Object System.Windows.Forms.CheckBox
$adwarebox.Text = "Block Adware"
$adwarebox.ForeColor = [System.Drawing.Color]::White
$adwarebox.BackColor = $form.BackColor
$adwarebox.Location = New-Object System.Drawing.Point(17, 78)
$malwarebox = New-Object System.Windows.Forms.CheckBox
$malwarebox.Text = "Block Malware"
$malwarebox.ForeColor = [System.Drawing.Color]::White
$malwarebox.BackColor = $form.BackColor
$malwarebox.Location = New-Object System.Drawing.Point(17, 104)
$wspywarebox = New-Object System.Windows.Forms.CheckBox
$wspywarebox.Text = "Block Windows spyware"
$wspywarebox.ForeColor = [System.Drawing.Color]::White
$wspywarebox.BackColor = $form.BackColor
$wspywarebox.Location = New-Object System.Drawing.Point(17, 130)
$wspywarebox.Size = New-Object System.Drawing.Size(150, 20)
$wupdatesbox = New-Object System.Windows.Forms.CheckBox
$wupdatesbox.Text = "Block Windows Updates (unsafe)"
$wupdatesbox.ForeColor = [System.Drawing.Color]::White
$wupdatesbox.BackColor = $form.BackColor
$wupdatesbox.Location = New-Object System.Drawing.Point(17, 153)
$wupdatesbox.Size = New-Object System.Drawing.Size(300, 20)
$wextrabox = New-Object System.Windows.Forms.CheckBox
$wextrabox.Text = "Block Windows Extra hosts (unsafe)"
$wextrabox.ForeColor = [System.Drawing.Color]::White
$wextrabox.BackColor = $form.BackColor
$wextrabox.Location = New-Object System.Drawing.Point(17, 176)
$wextrabox.Size = New-Object System.Drawing.Size(300, 20)
$applybtn = New-Object System.Windows.Forms.Button
$applybtn.Text = "Apply Changes"
$applybtn.Size = New-Object System.Drawing.Size(124, 35)
$applybtn.Location = New-Object System.Drawing.Point(207, 52)
$applybtn.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
$applybtn.FlatStyle = 'Flat'
$applybtn.ForeColor = [System.Drawing.Color]::White
$applybtn.FlatAppearance.BorderSize = 0
$applybtn.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$restorebtn = New-Object System.Windows.Forms.Button
$restorebtn.Text = "Restore original hosts"
$restorebtn.Size = New-Object System.Drawing.Size(124, 35)
$restorebtn.Location = New-Object System.Drawing.Point(207, 104)
$restorebtn.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
$restorebtn.FlatStyle = 'Flat'
$restorebtn.ForeColor = [System.Drawing.Color]::White
$restorebtn.FlatAppearance.BorderSize = 0
$restorebtn.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$applybtn.Add_Click({
    if ($pornbox.Checked) {
        Write-Host "Blocking Porn hosts..."
        $hostsContent = $hostsContent = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Fadi002/HostsBlocker/main/hosts/porn" -UseBasicParsing).Content
        Add-Content -Path $hostsPath -Value "`n`n# Hosts blocker - porn - (start - $((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')))`n$hostsContent`n# Hosts blocker - porn - end"
        Write-Host "Successfully blocked Porn hosts."
    }
    if ($adwarebox.Checked) {
        Write-Host "Blocking Adware hosts..."
        $hostsContent = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Fadi002/HostsBlocker/main/hosts/adware" -UseBasicParsing).Content
        Add-Content -Path $hostsPath -Value "`n`n# Hosts blocker - adware - (start - $((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')))`n$hostsContent`n# Hosts blocker - adware - end"
        Write-Host "Successfully blocked Adware hosts."
    }
    if ($malwarebox.Checked) {
        Write-Host "Blocking Malware hosts..."
        $hostsContent = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Fadi002/HostsBlocker/main/hosts/malware" -UseBasicParsing).Content
        Add-Content -Path $hostsPath -Value "`n`n# Hosts blocker - malware - (start - $((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')))`n$hostsContent`n# Hosts blocker - malware - end"
        Write-Host "Successfully blocked Malware hosts."
    }
    if ($wspywarebox.Checked) {
        Write-Host "Blocking Windows spy hosts..."
        $hostsContent = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Fadi002/HostsBlocker/main/hosts/windows_spy" -UseBasicParsing).Content
        Add-Content -Path $hostsPath -Value "`n`n# Hosts blocker - windows spy - (start - $((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')))`n$hostsContent`n# Hosts blocker - windows spy - end"
        Write-Host "Successfully blocked Windows spy hosts."
    }
    if ($wextrabox.Checked) {
        Write-Host "Blocking Windows extra hosts..."
        if (!(confirmation)) {
            [System.Windows.Forms.MessageBox]::Show(
            "Aborted blocking Windows extra hosts.",
            "Aborted",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information)
        } else {
            $hostsContent = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Fadi002/HostsBlocker/main/hosts/windows_extra" -UseBasicParsing).Content
            Add-Content -Path $hostsPath -Value "`n`n# Hosts blocker - windows extra - (start - $((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')))`n$hostsContent`n# Hosts blocker - windows extra - end"
            Write-Host "Successfully blocked Windows extra hosts."}
        }
    if ($wupdatesbox.Checked) {
        if (!(confirmation)) {
            [System.Windows.Forms.MessageBox]::Show(
            "Aborted blocking Windows update hosts.",
            "Aborted",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information)
        } else {
            Write-Host "Blocking Windows update hosts..."
            $hostsContent = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Fadi002/HostsBlocker/main/hosts/windows_update" -UseBasicParsing).Content
            Add-Content -Path $hostsPath -Value "`n`n# Hosts blocker - windows update - (start - $((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')))`n$hostsContent`n# Hosts blocker - windows update - end"
            Write-Host "Successfully blocked Windows update hosts."
        }
    }
})

$Restorebtn.Add_Click({
    $backupname = "hosts-hostsblocker-$(Get-Random -Minimum 1000 -Maximum 9999).bak"
    Rename-Item -Path $hostsPath -NewName $backupname -Force
    $defcontent = @"
# Copyright (c) 1993-2009 Microsoft Corp.
#
# This is a sample HOSTS file used by Microsoft TCP/IP for Windows.
#
# This file contains the mappings of IP addresses to host names. Each
# entry should be kept on an individual line. The IP address should
# be placed in the first column followed by the corresponding host name.
# The IP address and the host name should be separated by at least one
# space.
#
# Additionally, comments (such as these) may be inserted on individual
# lines or following the machine name denoted by a '#' symbol.
#
# For example:
#
#      102.54.94.97     rhino.acme.com          # source server
#       38.25.63.10     x.acme.com              # x client host

# localhost name resolution is handled within DNS itself.
#	127.0.0.1       localhost
#	::1             localhost
"@
    $defcontent | Out-File -FilePath $hostsPath -Encoding UTF8
    [System.Windows.Forms.MessageBox]::Show("Hosts file has been restored to its default state. Backup created at: $backupname", "Restore Successful", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
})

$applybtn.Add_MouseEnter({
    $applybtn.BackColor = [System.Drawing.Color]::FromArgb(80, 80, 80)
})
$applybtn.Add_MouseLeave({
    $applybtn.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
})

$restorebtn.Add_MouseEnter({
    $restorebtn.BackColor = [System.Drawing.Color]::FromArgb(80, 80, 80)
})
$restorebtn.Add_MouseLeave({
    $restorebtn.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
})

$form.Controls.Add($header)
$form.Controls.Add($pornbox)
$form.Controls.Add($adwarebox)
$form.Controls.Add($malwarebox)
$form.Controls.Add($wspywarebox)
$form.Controls.Add($wupdatesbox)
$form.Controls.Add($wextrabox)
$form.Controls.Add($applybtn)
$form.Controls.Add($restorebtn)
$form.Controls.Add($credits)
$form.Controls.Add($lastupdate)
$form.Controls.Add($lastupdatedate)
$form.ShowDialog()