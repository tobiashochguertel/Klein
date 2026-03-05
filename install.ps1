param (
    [switch]$Reconfigure
)

$ErrorActionPreference = "Stop"
$AppDir = "$env:LOCALAPPDATA\Klein"
$ConfigPath = "$AppDir\config.toml"

Write-Host "===========================" -ForegroundColor Cyan
Write-Host "  Klein IDE Setup/Config   " -ForegroundColor Cyan
Write-Host "===========================" -ForegroundColor Cyan

# 1. Ensure Directory Exists
if (-not (Test-Path -Path $AppDir)) {
    New-Item -ItemType Directory -Path $AppDir | Out-Null
    Write-Host "Created application directory at $AppDir"
}

# 2. Configuration Step
function Prompt-Configuration {
    Write-Host "`n--- Configuration ---" -ForegroundColor Yellow
    
    # Check for Git Bash
    $gitBashExists = Test-Path "C:\Program Files\Git\bin\bash.exe"
    $gitBashLocalExists = Test-Path "$env:LOCALAPPDATA\Programs\Git\bin\bash.exe"
    
    if (-not $gitBashExists -and -not $gitBashLocalExists) {
        Write-Host "WARNING: Git Bash was not found in standard locations." -ForegroundColor Red
        Write-Host "We highly recommend installing Git Bash for the best terminal experience in Klein." -ForegroundColor Yellow
        Write-Host "You can download it from: https://gitforwindows.org/" -ForegroundColor Cyan
        $installGit = Read-Host "Would you like to install Git Bash later? (y/n)"
        if ($installGit -eq 'n') {
            Write-Host "You can continue, but terminal features might be limited to PowerShell or CMD."
        }
    }

    $workspace = Read-Host "Enter your default workspace/projects path (Leave blank for $env:USERPROFILE)"
    if ([string]::IsNullOrWhiteSpace($workspace)) {
        $workspace = $env:USERPROFILE
    }

    # Verify workspace exists or create it
    if (-not (Test-Path -Path $workspace)) {
        $createWs = Read-Host "Path '$workspace' does not exist. Create it? (y/N)"
        if ($createWs -eq 'y') {
            New-Item -ItemType Directory -Path $workspace | Out-Null
        }
        else {
            Write-Host "Warning: Workspace path may be invalid." -ForegroundColor Yellow
        }
    }

    if ($gitBashExists -or $gitBashLocalExists) {
        $shell = "bash"
    }
    else {
        $shell = "auto"
    }

    $configContent = @"
# Klein IDE Configuration
default_workspace = `"$workspace`"
shell = `"$shell`"
"@

    $configContent | Out-File -FilePath $ConfigPath -Encoding utf8
    Write-Host "Configuration saved to $ConfigPath" -ForegroundColor Green
}

if ($Reconfigure) {
    Prompt-Configuration
    Write-Host "`nReconfiguration complete!" -ForegroundColor Green
    exit
}

# 3. Installation Step (Placeholder for actual binary download)
Write-Host "`n--- Installation ---" -ForegroundColor Yellow
# Assuming Cargo is installed since this is a Rust project currently
$cargoExists = Get-Command "cargo" -ErrorAction SilentlyContinue

if ($cargoExists) {
    Write-Host "Cargo detected. Building from source..."
    # Ideally, this script would be curled from a repo, so it assumes we are in the repo or downloads it.
    # For now, it alerts the user how to build it.
    Write-Host "Please run 'cargo install --path .' from the project root to install." -ForegroundColor Cyan
}
else {
    Write-Host "Cargo not detected. Please install Rust (https://rustup.rs/) or download the pre-compiled binary." -ForegroundColor Red
}

Prompt-Configuration

Write-Host "`nInstallation & Configuration Complete!" -ForegroundColor Green
Write-Host "You can run this script later with '-Reconfigure' to update your settings." -ForegroundColor Cyan
