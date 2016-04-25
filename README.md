# Deploy websites on IIS with powershell

Powershell scripts for managing .net 4 websites in IIS 7. Note that they require local admin priviliges.

## CreateSite.ps1

Script to install (or replace) a local website and app pool:

    CreateSite.ps1 [WebsiteName] [AppPoolName] [Port] [Path] ([domain\user] [password])

## CreateVirtualDirectory.ps1

Script to install (or replace) a virtual directory:

    CreateVirtualDirectory.ps1 [WebsiteName] [FolderName] [PhysicalPath] ([domain\user] [password])
    
## BindToDefaultPort.ps1
    
Script to install (or replace) a local website binding on port 80

    BindToDefaultPort.ps1 [WebsiteName] [host-header]    

## StopSite.ps1    

Script to stop a local website and app pool

    StopSite.ps1.ps1 [WebsiteName] [AppPoolName]
