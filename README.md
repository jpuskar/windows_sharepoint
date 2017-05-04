windows_sharepoint

This is the windows_sharepoint module.

##Module Description

This module allow you to manage SharePoint 2013.
Features include:
 - Installation
 - Users
 - Groups
 - Web Applications

You can found the original module on the forge [jriviere/windows_sharepoint](https://forge.puppetlabs.com/jriviere/windows_sharepoint) or my fork on [GitHub](https://github.com/jpuskar/windows_sharepoint).

This module uses a heavily modified version of the [AutoSPInstaller Project](http://autospinstaller.codeplex.com/). The modified version is available here: [jpuskar/AutoSpInstaller](https://github.com/jpuskar/AutoSpInstaller). You must make this modified version avaliable as a chocolatey package.

The account used for installing SharePoint must be local admin, and puppet must be run as this account manually.

Tested with :
  - SharePoint Foundation 2013 SP1
  - SQL 2012 R2 Express
  - SQL 2014 R2 Express
  - Windows Server 2012 R2

This module is only compatible with SharePoint 2013.


##Changelog

V 0.0.8 :
 - Refactored to use heredocs for readability.
 - Refactored to use underscores for word designation in variable names.
 - Added code to workaround newer dot net version when installing SharePoint.
 - Fixed various bugs with installing SharePoint 2013 Foundation.

V 0.0.7 :
 - Add -ea option on powershell command
 - Update the way to execute SharePoint installation
 
###Setup Requirements
Depends on the following modules:
    - ['puppetlabs/powershell', '>=1.0.2'](https://forge.puppetlabs.com/puppetlabs/powershell),
    - ['puppetlabs/stdlib', '>= 4.2.1'](https://forge.puppetlabs.com/puppetlabs/stdlib)

##Usage

##SharePointInstall
Class windows_sharepoint :
Permit installation of SharePoint

    class{'windows_sharepoint':
      languagepackspath     => "C:\\source\\LanguagePacks",   # path where we are going to take the updates and put them in the correct folder for autospinstaller (not yet implemented)
      updatespath            => "C:\\source\\Updates",         # path where we are going to take the extracted languagepacks and put them in the correct folder for autospinstaller. (Works)
      sppath                 => "C:\\source\\sharepoint.exe",  # path where we will find the exe file of sharepoint Foundation
      dbserver               => "SQL_ALIAS",                   # the alias created by autospinstaller
      dbaliasinstance         => "COMPUTERNAME",
      setupaccountpassword  => "P@ssw0rd",
      spfarmaccount         => "spfarm",
      spapppoolaccount      => "spapppool",
      spservicesaccount     => "spservices",
      spsearchaccount       => "spsearch",
      spcrawlaccount        => "spcrawl",
      spsuperreaderaccount  => "spsuperreader",
      spsuperuseraccount    => "spsuperuser",
      spsyncaccount         => "spsyncaccount",                  # Mandatory with Standard and enterprise
      spusrprfpassword      => "spusrprfaccount",                # Mandatory with Standard and enterprise
      spexcelaccount        => "spexcelaccount",                 # Mandatory with enterprise
      key                   => "SYOUR-PRODU-CTKEY-OFSPS-2012S",
      passphrase            => "P@ssPhrase@2014",               #SharePoint Farm PassPhrase.Must be at least 8 charaters with upper character, lower character, numbers, specialcharacter (3 of this 4 categories)
      webappurl             => "https://localhost",
      applicationPool       => "Default AppPool",
      webappname            => "WebApp",
      webappport            => 443,
      webappdatabasename    => "Default_ContentDB",
      siteurl               => "https://localhost",
      sitecolname              => "Home",
      sitecollcid            => "1033",
      sitecollocale         => "en-us",
      sitecolowner          => "spfarm",
    }

Parameters:
```
    $removedefaultwebapp         # If set to true this will delete the default created webapp
```
##webapplication
Ressource windows_sharepoint::webapplication :
Permit installation of SharePoint

    windows_sharepoint::webapplication{"default - $webappname":
      url                    => "http://localhost",
      applicationpoolname    => "AppPool_TestPuppet",
      webappname             => "Test Puppet",
      databasename           => "SP2013_Content_TestPuppet",
      applicationpoolaccount => "s-spapppool",
      ensure                 => present,
      usessl                 => false,
      webappport             => 6789,
    }

##user
Resource: windows_sharepoint::user

    windows_sharepoit{'SQLServer':
      username   => "Jerome",
      login      => 'jre',
      group      => "SharePoint Owners",
      weburl     => 'https://sharepoint/sites/jre',
      admin      => true,
    }

Parameters:
```
    $username         # Fullname of the user
    $login            # SamAccountName
    $weburl           # URL of the site where we want to add user
    $group            # Group name where we want put the user
    $admin            # Is SiteColAdmin ? Default : false
```

##SP Group
Resource: windows_sharepoint::group

````
    windows_sharepoit{'SharePoint Owners':
      group           => "SharePoint Owners",
      weburl          => 'https://sharepoint/sites/jre',
      permissionlevel => 'Full Control',
      ownername       => 'jre',
    }
````
Parameters:
```
    $weburl           # URL of the site where we want to add user
    $group            # Group name where we want put the user
    $permissionlevel  # Permissions for the group Full Control|Edit|Contribute|Read|Design
    $ownername        # Owner of the group
    $description      # group description
```

##webapplication
Ressource windows_sharepoint::services::reporting :
Allow installation and configuration of SharePoint reporting service integrated mode
```
    windows_sharepoint::services::reporting{"Reporting":
      databasename    => "ReportingServicesDB",
      databaseserver  => "SQL_ALIAS",
      serviceaccount  => "spservices",
    }
```
Parameters:
```
    $defaultsrvgrp    # Add the service to the default service app group. Default True
    $apppoolname      # App Pool name . The app pool will be created.
    $servicename      # Service Name. Default : SQL Server Reporting Service Application
    $proxyname        # Proxy Name. Default : SQL Server Reporting Service Application Proxy
```
## Known issues
Please don't add a '/' after the WebApp URL and site url, if you do so AutoSpInstaller will throw an error and will not create the WebApp and site Coll. 

The User profile Service Application will be installed but the synchronisation will not work. You have to remove the UPA Service and create another one manually. (Puppet can't get back the control with infinite powershell start-process instance :(, so I have to disable this steps. ). (Don't forget to give Replicate Right to the sync user.)

License
-------
Apache License, Version 2.0

Contact
-------
[Jerome RIVIERE](https://github.com/ninja-2)

Support
-------
Please log tickets and issues at [Github site](https://github.com/insentia/windows_sharepoint/issues)
