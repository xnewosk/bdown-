if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Run as admin" -ForegroundColor Red
    return
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$Categories = @("winget")

$AppList = @(
    @{ Name = "Brave";              Id = "Brave.Brave" }
    @{ Name = "Firefox";            Id = "Mozilla.Firefox" }
    @{ Name = "LibreWolf";          Id = "LibreWolf.LibreWolf" }
    @{ Name = "Tor Browser";        Id = "TorProject.TorBrowser" }
    @{ Name = "Gpg4win";            Id = "GnuPG.Gpg4win" }
    @{ Name = "Malwarebytes";       Id = "Malwarebytes.Malwarebytes" }
    @{ Name = "O&O ShutUp10++";     Id = "OO-Software.ShutUp10" }
    @{ Name = "Proton VPN";         Id = "Proton.ProtonVPN" }
    @{ Name = "Tailscale";          Id = "Tailscale.Tailscale" }
    @{ Name = "Wireshark";          Id = "WiresharkFoundation.Wireshark" }
    @{ Name = "Autoruns";           Id = "Microsoft.Sysinternals.Autoruns" }
    @{ Name = "Detect It Easy";     Id = "horsicq.DIE-engine" }
    @{ Name = "Docker Desktop";    Id = "Docker.DockerDesktop" }
    @{ Name = "System Informer";   Id = "WinsiderSS.SystemInformer" }
    @{ Name = "VMware Workstation"; Id = "VMware.WorkstationPro" }
    @{ Name = "x64dbg";            Id = "x64dbg.x64dbg" }
    @{ Name = "Git";               Id = "Git.Git" }
    @{ Name = "Node.js LTS";       Id = "OpenJS.NodeJS.LTS" }
    @{ Name = "PowerShell 7";      Id = "Microsoft.PowerShell" }
    @{ Name = "VS Code";           Id = "Microsoft.VisualStudioCode" }
    @{ Name = "Windows Terminal";  Id = "Microsoft.WindowsTerminal" }
    @{ Name = "7-Zip";             Id = "7zip.7zip" }
    @{ Name = "BCUninstaller";     Id = "Klocman.BulkCrapUninstaller" }
    @{ Name = "Everything";        Id = "voidtools.Everything" }
    @{ Name = "LocalSend";         Id = "LocalSend.LocalSend" }
    @{ Name = "PowerToys";         Id = "Microsoft.PowerToys" }
    @{ Name = "Rufus";             Id = "Rufus.Rufus" }
    @{ Name = "WinToys";           Id = "Wintoys.Wintoys" }
    @{ Name = "WizTree";           Id = "AntibodySoftware.WizTree" }
    @{ Name = "Bambu Studio";      Id = "Bambulab.Bambustudio" }
    @{ Name = "ChatGPT";           Id = "OpenAI.ChatGPT" }
    @{ Name = "Discord";           Id = "Discord.Discord" }
    @{ Name = "Modrinth App";      Id = "Modrinth.ModrinthApp" }
    @{ Name = "Steam";             Id = "Valve.Steam" }
)

$ManualNote = "Manual ahh Binary Ninja, Bitdefender, Autodesk Fusion, Python, .NET SDK, Java JDK.`r`n:) annas-archive.cc, getintopc.com, fmhy.net, massgrave.dev`r`nfirefox is better than brave btw chromium skin"

$form = New-Object System.Windows.Forms.Form
$form.Text = "someone should stop shoving copilot into everything"
$form.Size = New-Object System.Drawing.Size(480, 700)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

$tree = New-Object System.Windows.Forms.TreeView
$tree.Location = New-Object System.Drawing.Point(10, 10)
$tree.Size = New-Object System.Drawing.Size(445, 440)
$tree.CheckBoxes = $true
$tree.ShowLines = $false
$tree.ShowRootLines = $false
$tree.ShowPlusMinus = $true
$tree.ItemHeight = 22
$tree.Indent = 24
$tree.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$headerFont = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)

foreach ($cat in $Categories) {
    $apps = @($AppList | Sort-Object { $_.Name })
    $catNode = New-Object System.Windows.Forms.TreeNode("$($cat.ToUpper())  ($($apps.Count))    ")
    $catNode.NodeFont = $headerFont
    $catNode.ForeColor = [System.Drawing.Color]::FromArgb(0, 90, 170)
    $catNode.BackColor = [System.Drawing.Color]::FromArgb(235, 242, 250)

    foreach ($app in $apps) {
        $node = New-Object System.Windows.Forms.TreeNode($app.Name)
        $node.Tag = $app.Id
        $node.Checked = $true
        [void]$catNode.Nodes.Add($node)
    }

    $catNode.Checked = $true
    [void]$tree.Nodes.Add($catNode)
}

$tree.ExpandAll()

if ($tree.Nodes.Count -gt 0) {
    $tree.Nodes[0].EnsureVisible()
}

$script:busy = $false

$tree.Add_AfterCheck({
    param($sender, $e)

    if ($script:busy) { return }

    $script:busy = $true

    try {
        if ($e.Node.Parent -eq $null) {
            foreach ($c in $e.Node.Nodes) {
                $c.Checked = $e.Node.Checked
            }
        } else {
            $p = $e.Node.Parent
            $p.Checked = (@($p.Nodes | Where-Object { -not $_.Checked }).Count -eq 0)
        }
    } finally {
        $script:busy = $false
    }
})

$form.Controls.Add($tree)

$btnAll = New-Object System.Windows.Forms.Button
$btnAll.Text = "All"
$btnAll.Location = New-Object System.Drawing.Point(10, 460)
$btnAll.Size = New-Object System.Drawing.Size(110, 30)
$btnAll.Add_Click({
    foreach ($n in $tree.Nodes) {
        $n.Checked = $true
    }
})
$form.Controls.Add($btnAll)

$btnNone = New-Object System.Windows.Forms.Button
$btnNone.Text = "None"
$btnNone.Location = New-Object System.Drawing.Point(130, 460)
$btnNone.Size = New-Object System.Drawing.Size(110, 30)
$btnNone.Add_Click({
    foreach ($n in $tree.Nodes) {
        $n.Checked = $false
    }
})
$form.Controls.Add($btnNone)

$btnInstall = New-Object System.Windows.Forms.Button
$btnInstall.Text = "Install"
$btnInstall.Location = New-Object System.Drawing.Point(250, 460)
$btnInstall.Size = New-Object System.Drawing.Size(205, 30)
$form.Controls.Add($btnInstall)

$noteBox = New-Object System.Windows.Forms.TextBox
$noteBox.Text = $ManualNote
$noteBox.Location = New-Object System.Drawing.Point(10, 500)
$noteBox.Size = New-Object System.Drawing.Size(445, 55)
$noteBox.Multiline = $true
$noteBox.ScrollBars = "Vertical"
$noteBox.ReadOnly = $true
$noteBox.ForeColor = [System.Drawing.Color]::DarkRed
$form.Controls.Add($noteBox)

$logBox = New-Object System.Windows.Forms.TextBox
$logBox.Location = New-Object System.Drawing.Point(10, 560)
$logBox.Size = New-Object System.Drawing.Size(445, 95)
$logBox.Multiline = $true
$logBox.ScrollBars = "Vertical"
$logBox.ReadOnly = $true
$logBox.MaxLength = 0
$logBox.Font = New-Object System.Drawing.Font("Consolas", 8)
$form.Controls.Add($logBox)

function Write-Log {
    param([string]$text)

    if ($logBox.IsDisposed) { return }

    $logBox.AppendText("$text`r`n")
    $logBox.SelectionStart = $logBox.Text.Length
    $logBox.ScrollToCaret()
}

$btnInstall.Add_Click({
    $btnInstall.Enabled = $false
    $btnAll.Enabled = $false
    $btnNone.Enabled = $false
    $tree.Enabled = $false

    try {
        try {
            $wingetCommand = Get-Command winget.exe -CommandType Application -ErrorAction Stop
            $wingetPath = $wingetCommand.Source
        } catch {
            Write-Log "WinGet was not found. Install or update App Installer, then reopen PowerShell."
            Write-Log $_.Exception.Message
            return
        }

        $checked = @(foreach ($cn in $tree.Nodes) {
            foreach ($c in $cn.Nodes) {
                if ($c.Checked) { $c }
            }
        })

        if ($checked.Count -eq 0) {
            Write-Log "Nothing selected."
            return
        }

        Write-Log "Starting installation of $($checked.Count) apps."

        foreach ($item in $checked) {
            if ($form.IsDisposed) { break }

            $name = $item.Text
            $id = $item.Tag
            $proc = $null

            Write-Log ""
            Write-Log ">>> $name ($id)"

            try {
                $psi = New-Object System.Diagnostics.ProcessStartInfo
                $psi.FileName = $wingetPath
                $psi.Arguments = "install --id $id --silent --accept-package-agreements --accept-source-agreements --disable-interactivity -e"
                $psi.UseShellExecute = $false
                $psi.CreateNoWindow = $true
                $psi.RedirectStandardOutput = $true
                $psi.RedirectStandardError = $true
                $psi.StandardOutputEncoding = [System.Text.Encoding]::UTF8
                $psi.StandardErrorEncoding = [System.Text.Encoding]::UTF8

                $proc = New-Object System.Diagnostics.Process
                $proc.StartInfo = $psi

                if (-not $proc.Start()) {
                    throw "Could not start WinGet."
                }

                $stdoutTask = $proc.StandardOutput.ReadLineAsync()
                $stderrTask = $proc.StandardError.ReadLineAsync()
                $stdoutDone = $false
                $stderrDone = $false

                while (-not $proc.HasExited -or -not $stdoutDone -or -not $stderrDone) {
                    if (-not $stdoutDone -and $stdoutTask.IsCompleted) {
                        $line = $stdoutTask.GetAwaiter().GetResult()

                        if ($null -eq $line) {
                            $stdoutDone = $true
                        } else {
                            if (-not [string]::IsNullOrWhiteSpace($line)) {
                                Write-Log $line
                            }

                            $stdoutTask = $proc.StandardOutput.ReadLineAsync()
                        }
                    }

                    if (-not $stderrDone -and $stderrTask.IsCompleted) {
                        $line = $stderrTask.GetAwaiter().GetResult()

                        if ($null -eq $line) {
                            $stderrDone = $true
                        } else {
                            if (-not [string]::IsNullOrWhiteSpace($line)) {
                                Write-Log "ERROR: $line"
                            }

                            $stderrTask = $proc.StandardError.ReadLineAsync()
                        }
                    }

                    [System.Windows.Forms.Application]::DoEvents()
                    Start-Sleep -Milliseconds 20
                }

                $proc.WaitForExit()
                $exitCode = $proc.ExitCode

                if ($exitCode -eq 0) {
                    Write-Log "    done."
                } elseif ($exitCode -eq -1978335189) {
                    Write-Log "    no applicable update."
                } else {
                    Write-Log "    failed (exit $exitCode)"
                }
            } catch {
                Write-Log "ERROR: $($_.Exception.Message)"
            } finally {
                if ($null -ne $proc) {
                    $proc.Dispose()
                }
            }
        }

        Write-Log ""
        Write-Log "Finished."
    } catch {
        Write-Log "ERROR: $($_.Exception.Message)"
    } finally {
        if (-not $form.IsDisposed) {
            $btnInstall.Enabled = $true
            $btnAll.Enabled = $true
            $btnNone.Enabled = $true
            $tree.Enabled = $true
        }
    }
})

[void]$form.ShowDialog()
