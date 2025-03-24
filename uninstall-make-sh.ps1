# Paths
$ChocoBinPath = "C:\ProgramData\chocolatey\bin"
$ShExePath = "$ChocoBinPath\sh.exe"

# Uninstall GNU Make
Write-Host "Uninstalling GNU Make..."
choco uninstall make -y

# Uninstall BusyBox (which provided sh)
Write-Host "Uninstalling BusyBox..."
choco uninstall busybox -y

# Remove sh.exe if still present
if (Test-Path $ShExePath) {
    Remove-Item -Path $ShExePath -Force
    Write-Host "sh.exe removed."
} else {
    Write-Host "sh.exe was not found, skipping."
}

# Function to remove a directory from PATH
function Remove-FromPath {
    param ([string]$RemovePath)
    $CurrentPath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $NewPath = ($CurrentPath -split ";") -notmatch [regex]::Escape($RemovePath) -join ";"
    [System.Environment]::SetEnvironmentVariable("Path", $NewPath, "Machine")
    Write-Host "Removed $RemovePath from system PATH."
}

# Remove Chocolatey bin path from system PATH (if needed)
Remove-FromPath $ChocoBinPath

# Refresh environment variables
$RefreshEnvCmd = "$ChocoBinPath\refreshenv.cmd"
if (Test-Path $RefreshEnvCmd) {
    Write-Host "Refreshing environment variables..."
    & $RefreshEnvCmd
    Write-Host "Environment refreshed."
} else {
    Write-Host "Could not find refreshenv.cmd. Please restart your terminal or run 'refreshenv' manually."
}

Write-Host "Uninstallation complete!"
