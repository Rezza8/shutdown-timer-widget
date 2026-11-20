<# 
.SYNOPSIS
    Installs Shutdown Timer Widget
.DESCRIPTION
    Creates Program Files entry, Start Menu shortcut, and uninstaller
.NOTES
    Run as Administrator
#>

param(
    [switch]$Uninstall,
    [switch]$Silent
)

$AppName = "Shutdown Timer"
$AppExe = "ShutdownWidget.exe"
$InstallDir = "$env:ProgramFiles\$AppName"
$StartMenuDir = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\$AppName"
$DesktopPath = [Environment]::GetFolderPath("Desktop")
$UninstallKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\ShutdownTimerWidget"

function Write-Log {
    param($Message)
    if (-not $Silent) { Write-Host $Message }
}

if ($Uninstall) {
    Write-Log "Uninstalling $AppName..."
    
    # Remove Start Menu shortcut
    if (Test-Path $StartMenuDir) {
        Remove-Item $StartMenuDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "Removed Start Menu shortcuts"
    }
    
    # Remove Desktop shortcut
    $desktopShortcut = "$DesktopPath\$AppName.lnk"
    if (Test-Path $desktopShortcut) {
        Remove-Item $desktopShortcut -Force -ErrorAction SilentlyContinue
        Write-Log "Removed Desktop shortcut"
    }
    
    # Remove install directory
    if (Test-Path $InstallDir) {
        Remove-Item $InstallDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "Removed installation folder"
    }
    
    # Remove uninstall registry entry
    if (Test-Path $UninstallKey) {
        Remove-Item $UninstallKey -Force -ErrorAction SilentlyContinue
        Write-Log "Removed uninstall entry"
    }
    
    Write-Log "Uninstall complete!"
    exit 0
}

# Check admin rights
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Please run as Administrator"
    exit 1
}

Write-Log "Installing $AppName..."

# Create install directory
if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
}

# Copy executable (assumes running from same folder as EXE)
$sourceExe = "$PSScriptRoot\$AppExe"
if (-not (Test-Path $sourceExe)) {
    # Try current directory
    $sourceExe = "$(Get-Location)\$AppExe"
}
if (-not (Test-Path $sourceExe)) {
    Write-Error "Could not find $AppExe next to installer"
    exit 1
}

Copy-Item $sourceExe -Destination "$InstallDir\$AppExe" -Force
Write-Log "Copied executable to $InstallDir"

# Copy icon
$sourceIcon = "$PSScriptRoot\icon.ico"
if (Test-Path $sourceIcon) {
    Copy-Item $sourceIcon -Destination "$InstallDir\icon.ico" -Force
    Write-Log "Copied icon to $InstallDir"
}

# Create Start Menu folder
if (-not (Test-Path $StartMenuDir)) {
    New-Item -ItemType Directory -Path $StartMenuDir -Force | Out-Null
}

# Create Start Menu shortcut
$shortcutPath = "$StartMenuDir\$AppName.lnk"
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "$InstallDir\$AppExe"
$shortcut.WorkingDirectory = $InstallDir
$shortcut.Description = "Windows Shutdown Timer Widget"
$shortcut.IconLocation = "$InstallDir\$AppExe,0"
$shortcut.Save()
Write-Log "Created Start Menu shortcut"

# Create Desktop shortcut
$desktopShortcut = "$DesktopPath\$AppName.lnk"
$shortcut2 = $shell.CreateShortcut($desktopShortcut)
$shortcut2.TargetPath = "$InstallDir\$AppExe"
$shortcut2.WorkingDirectory = $InstallDir
$shortcut2.Description = "Windows Shutdown Timer Widget"
$shortcut2.IconLocation = "$InstallDir\$AppExe,0"
$shortcut2.Save()
Write-Log "Created Desktop shortcut"

# Create uninstaller
$uninstallScript = @"
param([switch]`$Silent)
& `"$PSCommandPath`" -Uninstall `$(if (`$Silent) { '-Silent' })
"@
$uninstallScriptPath = "$InstallDir\Uninstall.ps1"
$uninstallScript | Set-Content $uninstallScriptPath -Encoding UTF8

# Create uninstall registry entry
New-Item -Path $UninstallKey -Force | Out-Null
Set-ItemProperty -Path $UninstallKey -Name "DisplayName" -Value "$AppName"
Set-ItemProperty -Path $UninstallKey -Name "DisplayVersion" -Value "1.0.0"
Set-ItemProperty -Path $UninstallKey -Name "Publisher" -Value "OpenCode"
Set-ItemProperty -Path $UninstallKey -Name "InstallLocation" -Value $InstallDir
Set-ItemProperty -Path $UninstallKey -Name "UninstallString" -Value "powershell.exe -ExecutionPolicy Bypass -File `"$uninstallScriptPath`""
Set-ItemProperty -Path $UninstallKey -Name "QuietUninstallString" -Value "powershell.exe -ExecutionPolicy Bypass -File `"$uninstallScriptPath`" -Silent"
Set-ItemProperty -Path $UninstallKey -Name "NoModify" -Value 1 -Type DWord
Set-ItemProperty -Path $UninstallKey -Name "NoRepair" -Value 1 -Type DWord
Write-Log "Created uninstall entry in Add/Remove Programs"

Write-Log "Installation complete!"
Write-Log "You can find $AppName in Start Menu and on Desktop"