## Intro: Simple powershell script to install (or replace) a local website and app pool
## Usage: CreateSite.ps1 [WebsiteName] [AppPoolName] [Port] [Path] ([domain\user] [password])
## Note : These scripts require local admin priviliges!

# Load IIS tools
Import-Module WebAdministration
sleep 2 #see http://stackoverflow.com/questions/14862854/powershell-command-get-childitem-iis-sites-causes-an-error

# Get SiteName and AppPool from script args
$siteName    = $args[0]  # "default web site"
$appPoolName = $args[1]  # "DefaultAppPool"
$port        = $args[2]  # "80"
$path        = $args[3]  # "c:\sites\test"
$user        = $args[4]  # "domain\username"
$password    = $args[5]  # "password1"

if($siteName -eq $null)    { throw "Empty site name, Argument one is missing" }
if($appPoolName -eq $null) { throw "Empty AppPool name, Argument two is missing" }
if($port -eq $null)        { throw "Empty port, Argument three is missing" }
if($path -eq $null)        { throw "Empty path, Argument four is missing" }

$backupName = "$(Get-date -format "yyyyMMdd-HHmmss")-$siteName"
"Backing up IIS config to backup named $backupName"
$backup = Backup-WebConfiguration $backupName

try { 
    # delete the website & app pool if needed
    if (Test-Path "IIS:\Sites\$siteName") {
        "Removing existing website $siteName"
        Remove-Website -Name $siteName
    }

    if (Test-Path "IIS:\AppPools\$appPoolName") {
        "Removing existing AppPool $appPoolName"
        Remove-WebAppPool -Name $appPoolName
    }

    #remove anything already using that port
    foreach($site in Get-ChildItem IIS:\Sites) {
        if( $site.Bindings.Collection.bindingInformation -eq ("*:" + $port + ":")){
            "Warning: Found an existing site '$($site.Name)' already using port $port. Removing it..."
             Remove-Website -Name  $site.Name 
             "Website $($site.Name) removed"
        }
    }

    "Create an appPool named $appPoolName under v4.0 runtime, default (Integrated) pipeline"
    $pool = New-WebAppPool $appPoolName
    $pool.managedRuntimeVersion = "v4.0"
    $pool.processModel.identityType = 2 #NetworkService
	
	if ($user -ne $null -AND $password -ne $null) {
	    "Setting AppPool to run as $user"
		$pool.processmodel.identityType = 3
		$pool.processmodel.username = $user
		$pool.processmodel.password = $password
	} 
	
    $pool | Set-Item

    if ((Get-WebAppPoolState -Name $appPoolName).Value -ne "Started") {
        throw "App pool $appPoolName was created but did not start automatically. Probably something is broken!"
    }

    "Create a website $siteName from directory $path on port $port"
    $website = New-Website -Name $siteName -PhysicalPath $path -ApplicationPool $appPoolName -Port $port

    if ((Get-WebsiteState -Name $siteName).Value -ne "Started") {
        throw "Website $siteName was created but did not start automatically. Probably something is broken!"
    }

    "Website and AppPool created and started sucessfully"
} catch {
    "Error detected, running command 'Restore-WebConfiguration $backupName' to restore the web server to its initial state. Please wait..."
    sleep 3 #allow backup to unlock files
    Restore-WebConfiguration $backupName
    "IIS Restore complete. Throwing original error."
    throw
}

