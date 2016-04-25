## Intro: Simple powershell script to install (or replace) a local website binding on port 80
## Usage: BindTodefaultPort.ps1 [WebsiteName] [host-header]
## Note : These scripts require local admin priviliges!

# Load IIS tools
Import-Module WebAdministration
sleep 2 #see http://stackoverflow.com/questions/14862854/powershell-command-get-childitem-iis-sites-causes-an-error

# Get SiteName and AppPool from script args
$siteName    = $args[0]  # "default web site"
$hostHeader = $args[1]  # "localhost"
$port        = 80

if($siteName -eq $null)    { throw "Empty site name, Argument one is missing" }
if($hostHeader -eq $null) { throw "Empty host header, Argument two is missing" }

$backupName = "$(Get-date -format "yyyyMMdd-HHmmss")-$siteName"
"Backing up IIS config to backup named $backupName"
$backup = Backup-WebConfiguration $backupName

try { 
   
	"Adding host header '$hostHeader' binding on port $port for site $siteName"
	New-WebBinding -Protocol http -Port $port -HostHeader $hostHeader -Name $siteName

} catch {
    "Error detected, running command 'Restore-WebConfiguration $backupName' to restore the web server to its initial state. Please wait..."
    sleep 3 #allow backup to unlock files
    Restore-WebConfiguration $backupName
    "IIS Restore complete. Throwing original error."
    throw
}

