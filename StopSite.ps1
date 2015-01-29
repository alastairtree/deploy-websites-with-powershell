## Intro: Simple powershell script to stop a local website and app pool
## Usage: StopSite.ps1.ps1 [WebsiteName] [AppPoolName]
## Note : These scripts require local admin priviliges!

# Load IIS tools
Import-Module webadministration

# Get SiteName and AppPool from script args
$siteName = $args[0] # "default web site"
$appPoolName = $args[1] # "DefaultAppPool"

"Stopping website and app pool on $env:COMPUTERNAME"

# Stop the website if it exists and is running, dont error if it doesn't
if (Test-Path "IIS:\Sites\$siteName") {
    if ((Get-WebsiteState -Name $siteName).Value -ne "Stopped") {
        stop-website -Name $siteName
        echo "Stopped website '$siteName'"
    } else {
        echo "WARNING: Site '$siteName' was already stopped. Have you already run this?"
    }
} else {
    echo "WARNING: Could not find a site called '$siteName' to stop. Assuming this is a new install"
}

# Stop the AppPool if it exists and is running, dont error if it doesn't
if (Test-Path "IIS:\AppPools\$appPoolName") {
if ((Get-WebAppPoolState -Name $appPoolName).Value -ne "Stopped") {
        Stop-WebAppPool -Name $appPoolName
        echo "Stopped AppPool '$appPoolName'"
    } else {
        echo "WARNING: AppPool '$appPoolName' was already stopped. Have you already run this?"
    }
} else {
    echo "WARNING: Could not find an AppPool called '$appPoolName' to stop. Assuming this is a new install"
}