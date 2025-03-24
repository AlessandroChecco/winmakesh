# Function to update the system PATH
function Add-ToPath {
    param ([string]$NewPath)
    $CurrentPath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    if ($CurrentPath -notlike "*$NewPath*") {
        [System.Environment]::SetEnvironmentVariable("Path", "$CurrentPath;$NewPath", "Machine")
        Write-Host "Added $NewPath to system PATH."
    } else {
        Write-Host "$NewPath is already in the PATH."
    }
}

# Chocolatey install path
$ChocoBinPath = "C:\ProgramData\chocolatey\bin"

# Check if Chocolatey is installed
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    $env:Path += ";$ChocoBinPath"
}

# Install make and busybox
Write-Host "Installing GNU Make and BusyBox..."
choco install make -y
choco install busybox -y

# Define paths
$BusyBoxPath = "$ChocoBinPath\busybox.exe"
$ShExePath = "$ChocoBinPath\sh.exe"

# Create a renamed sh.exe that ensures the correct PATH inside BusyBox
Copy-Item -Path "$BusyBoxPath" -Destination "$ShExePath" -Force
Write-Host "sh.exe created from BusyBox."

# Add paths to the system PATH
Add-ToPath $ChocoBinPath

# Explicitly call refreshenv from Chocolatey's installed location
$RefreshEnvCmd = "$ChocoBinPath\refreshenv.cmd"
if (Test-Path $RefreshEnvCmd) {
    Write-Host "Refreshing environment variables..."
    & $RefreshEnvCmd
    Write-Host "Environment refreshed! You can now use 'sh' and 'make'."
} else {
    Write-Host "Could not find refreshenv.cmd. Please restart your terminal or run 'refreshenv' manually."
}

Write-Host "Installation complete! You can now use 'sh.exe' and 'make' directly."
