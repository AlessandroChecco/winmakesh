# Ensure script is running as Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires Administrator privileges. Please run PowerShell as Administrator."
    exit 1
}

# Function to remove an item from the system PATH safely
function Remove-FromPath {
    param ([string]$RemovePath)
    $CurrentPath = [System.Environment]::GetEnvironmentVariable("Path", "Machine") -split ";"

    if ($CurrentPath -contains $RemovePath) {
        $UpdatedPath = $CurrentPath -ne $RemovePath -join ";"
        [System.Environment]::SetEnvironmentVariable("Path", $UpdatedPath, "Machine")
        Write-Host "Removed $RemovePath from system PATH."
    } else {
        Write-Host "$RemovePath was not found in the PATH."
    }
}

# Detect Chocolatey's bin path dynamically
$ChocoPath = (Get-Command choco -ErrorAction SilentlyContinue).Source
if (-not $ChocoPath) {
    Write-Host "Chocolatey is not installed or not in the PATH. Skipping uninstallation steps."
    exit 1
}

$ChocoBinPath = [System.IO.Path]::GetDirectoryName($ChocoPath)

# Uninstall GNU Make and BusyBox via Chocolatey
Write-Host "Uninstalling GNU Make and BusyBox..."
choco uninstall make -y
choco uninstall busybox -y

# Remove manually created sh.exe (if it exists)
$ShExePath = "$ChocoBinPath\sh.exe"
if (Test-Path $ShExePath) {
    Remove-Item -Path $ShExePath -Force
    Write-Host "Removed manually created sh.exe."
} else {
    Write-Host "sh.exe was not found. No manual cleanup needed."
}


# Refresh environment variables
$RefreshEnvCmd = "$ChocoBinPath\refreshenv.cmd"
if (Test-Path $RefreshEnvCmd) {
    Write-Host "Refreshing environment variables..."
    & $RefreshEnvCmd
    Write-Host "Environment refreshed!"
} else {
    Write-Host "refreshenv.cmd not found. Please restart your terminal to apply changes."
}

Write-Host "Uninstallation complete. Chocolatey is still installed."
