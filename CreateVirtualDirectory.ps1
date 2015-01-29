## Intro: Simple powershell script to install (or replace) a virtual directory
## Usage: CreateVirtualDirectory.ps1 [WebsiteName] [FolderName] [PhysicalPath] ([domain\user] [password])
## Note : These scripts require local admin priviliges!

# Load IIS tools
Import-Module WebAdministration
sleep 2 #see http://stackoverflow.com/questions/14862854/powershell-command-get-childitem-iis-sites-causes-an-error

# Get SiteName and AppPool from script args
$siteName     = $args[0]  # "default web site"
$folderName   = $args[1]  # "Files"
$physicalPath = $args[2]  # "\\UncServer\UncShare"
$user         = $args[3]  # "domain\username"
$password     = $args[4]  # "password1" 
if($siteName -eq $null)    { throw "Empty site name, Argument one is missing" }
if($folderName -eq $null) { throw "Empty folder name, Argument two is missing" }
if($physicalPath -eq $null)        { throw "Empty PhysicalPath, Argument three is missing" }

$backupName = "$(Get-date -format "yyyyMMdd-HHmmss")-$siteName"
"Backing up IIS config to backup named $backupName"
$backup = Backup-WebConfiguration $backupName

try { 

    "Adding a virtual directory '$folderName' to website '$siteName' for physical path $physicalPath"
   
    ## Init
    $virtualDirectoryPath = "IIS:\Sites\$siteName\$folderName"

    ## Create Virtual Directory where physicalpath is an UNC-path (New-WebVirtualDirectory wont do)
    $newItem = New-Item $virtualDirectoryPath -type VirtualDirectory -physicalPath $physicalPath -Force

    if($user -ne $null) {
        "Setting virtual directory Connect-As credentials to user $user"
        ## Change 'Connect As' settings (New-WebVirtualDirectory don't include Username and Password)
        Set-ItemProperty $virtualDirectoryPath -Name username -Value $user
        Set-ItemProperty $virtualDirectoryPath -Name password -Value $password
    }

    #"Virtual directory settings:"
    #Get-Item -Path $virtualDirectoryPath | fl *

    "Virtual directory '$folderName' created sucessfully"
} catch {
    "Error detected, running command 'Restore-WebConfiguration $backupName' to restore the web server to its initial state. Please wait..."
    sleep 3 #allow backup to unlock files
    Restore-WebConfiguration $backupName
    "IIS Restore complete. Throwing original error."
    throw
}

