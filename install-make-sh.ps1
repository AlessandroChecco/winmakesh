# Ensure script is running as Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires Administrator privileges. Please run PowerShell as Administrator."
    exit 1
}

# Function to add a path to the system PATH without duplication
function Add-ToPath {
    param ([string]$NewPath)
    $CurrentPath = [System.Environment]::GetEnvironmentVariable("Path", "Machine") -split ";"
    
    if ($CurrentPath -notcontains $NewPath) {
        $UpdatedPath = ($CurrentPath + $NewPath) -join ";"
        [System.Environment]::SetEnvironmentVariable("Path", $UpdatedPath, "Machine")
        Write-Host "Added $NewPath to system PATH."
    } else {
        Write-Host "$NewPath is already in the PATH."
    }
}

# Dynamically find Chocolatey path
$ChocoPath = (Get-Command choco -ErrorAction SilentlyContinue).Source
if (-not $ChocoPath) {
    Write-Host "Chocolatey is not installed. Installing..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    
    # After installing Chocolatey, update its path
    $ChocoPath = (Get-Command choco -ErrorAction SilentlyContinue).Source
    if (-not $ChocoPath) {
        Write-Host "Error: Chocolatey installation failed. Please install it manually."
        exit 1
    }
}

# Extract Chocolatey bin path dynamically
$ChocoBinPath = [System.IO.Path]::GetDirectoryName($ChocoPath)

# Install make and busybox
Write-Host "Installing GNU Make and BusyBox..."
choco install make -y
choco install busybox -y

# Define paths
$BusyBoxPath = "$ChocoBinPath\busybox.exe"
$ShExePath = "$ChocoBinPath\sh.exe"

# Check if another sh.exe exists (e.g., Git Bash, MSYS2)
$ExistingSh = Get-Command sh -ErrorAction SilentlyContinue
if ($ExistingSh) {
    Write-Host "Warning: Another sh.exe is already installed at $($ExistingSh.Source)."
    Write-Host "Renaming BusyBox to sh.exe may cause conflicts. Skipping renaming..."
} else {
    # Create a renamed sh.exe that ensures the correct PATH inside BusyBox
    Copy-Item -Path "$BusyBoxPath" -Destination "$ShExePath" -Force
    Write-Host "sh.exe created from BusyBox."
}

# Add Chocolatey's bin directory to the system PATH
Add-ToPath $ChocoBinPath

# Explicitly call refreshenv from Chocolatey's installed location
$RefreshEnvCmd = "$ChocoBinPath\refreshenv.cmd"
if (Test-Path $RefreshEnvCmd) {
    Write-Host "Refreshing environment variables..."
    & $RefreshEnvCmd
    Write-Host "Environment refreshed! You can now use 'sh' and 'make'."
} else {
    Write-Host "Warning: refreshenv.cmd not found. Restart your terminal or run 'refreshenv' manually."
}

Write-Host "Installation complete! You can now use 'sh.exe' and 'make' directly."
