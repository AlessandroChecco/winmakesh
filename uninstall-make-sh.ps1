# Ensure script is running as Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires Administrator privileges. Please run PowerShell as Administrator."
    exit 1
}

# Find Chocolatey dynamically
$ChocoPath = (Get-Command choco -ErrorAction SilentlyContinue).Source
$ChocoBinPath = [System.IO.Path]::GetDirectoryName($ChocoPath)

# Paths for sh and make
$ShExePath = "$ChocoBinPath\sh.exe"

# Uninstall GNU Make
Write-Host "Uninstalling GNU Make..."
choco uninstall make -y

# Uninstall BusyBox
Write-Host "Uninstalling BusyBox..."
choco uninstall busybox -y

# Remove renamed sh.exe (if it was manually created)
if (Test-Path $ShExePath) {
    Remove-Item -Path $ShExePath -Force
    Write-Host "sh.exe removed."
} else {
    Write-Host "sh.exe was not found, skipping."
}

# Function to remove only specific entries from PATH
function Remove-FromPath {
    param ([string]$RemovePath)
    $CurrentPath = [System.Environment]::GetEnvironmentVariable("Path", "Machine") -split ";"
    $NewPath = $CurrentPath -notmatch [regex]::Escape($RemovePath) -join ";"
    
    if ($NewPath -ne ($CurrentPath -join ";")) {
        [System.Environment]::SetEnvironmentVariable("Path", $NewPath, "Machine")
        Write-Host "Removed $RemovePath from PATH."
    } else {
        Write-Host "$RemovePath was not found in PATH."
    }
}

# Do not remove Chocolatey path, only custom paths
Remove-FromPath "$ChocoBinPath"

# Refresh environment variables safely
$RefreshEnvCmd = "$ChocoBinPath\refreshenv.cmd"
if (Test-Path $RefreshEnvCmd) {
    Write-Host "Refreshing environment variables..."
    & $RefreshEnvCmd
} else {
    Write-Host "Warning: refreshenv.cmd not found. Restart your terminal to apply changes."
}

Write-Host "Uninstallation complete!"
