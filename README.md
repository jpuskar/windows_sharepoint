# windows_sharepoint

This is  a fork of jriviere's windows_sharepoint module.

## Module Description

This module allow you to:

- Install SharePoint 2013.
- Manage SharePoint users and groups.

This module uses a modified version of [AutoSPInstaller Project](http://autospinstaller.codeplex.com/). The modified version is available at the following git repo: [jpuskar/AutoSpInstaller](https://github.com/jpuskar/AutoSpInstaller).

The account used for installing SharePoint must:

- be a local admin on each server
- have SQL sa rights on the database.

Tested with :

- SharePoint Foundation 2013 SP1 on Server 2012 R2

The parent version of this project was tested on the following, and therefore these probably still work:

- SharePoint Standard 2013 SP1
- SharePoint EnterPrise 2013 SP1

## Changelog

V 0.0.7.1:

### Summary

- Fixed inability to install SharePoint foundation.
- Fixed several installer problems such as the dotnet 4.6 SharePoint installer bug.
- Modified exec commands to work despite the Exec Powershell provider return code issues.
- Added setup_account_username option.
- Changed defaults for dbalias, dbaliasport, dbaliasinstance, dbserver for clarity.
- Updated to AutoSpInstaller 3.99.60.

### Details

#### manifests/init.pp

- Added class anchors.
- Added class windows_sharepoint::stage_bin.

#### manifests/install.pp

- Added param setup_account_username.
- Refactored exec commands for deduplication and to workaround powershell exec provider return code issues.
- Added code to call setacl.exe in order to workaround SharePoint 2013 installer bug.
- Added code to manage AutoSpInstaller reboots.

#### manifests/prepsp.pp

- Refactored for readability.

#### templates/autospinstaller.erb

- Excluded some nodes when installing Sharepoint Foundation.
- Removed automatic domain prepending to usernames to support cross-domain installs.

V 0.0.7 :

- Add -ea option on powershell command
- Update the way to execute SharePoint installation

### Setup Requirements

Depends on the following modules:

- ['puppetlabs/powershell', '>=1.0.2'](https://forge.puppetlabs.com/puppetlabs/powershell),
- ['puppetlabs/stdlib', '>= 4.2.1'](https://forge.puppetlabs.com/puppetlabs/stdlib)

In addition, the module expects that:

- setacl.exe is available in the system path.
- the modified AutoSpInstaller package is extracted to $basepath\\Puppet-SharePoint\\.

The folder structure should look like this, if $basepath is kept to at the default of 'C:'.

- C:\Puppet-SharePoint\\AutoSPInstaller\2013\
- C:\Puppet-SharePoint\\AutoSPInstaller\AutoSPInstallerMain.ps1
- C:\Puppet-SharePoint\\AutoSPInstaller\AutoSPInstallerInput.xml

## Resources

### ::windows_sharepoint

Installs and configures sharepoint.

    class{'windows_sharepoint':
        sppath                 => "C:\\Puppet-SharePoint\\sharepoint.exe",
        setup_account_password => "vagrant",
        setup_account_username => "vagrant",
    }

### windows_sharepoint::webapplication

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

### windows_sharepoint::user

    windows_sharepoit{'SQLServer':
        username   => "Jerome",
        login      => 'jre',
        group      => "SharePoint Owners",
        weburl     => 'https://sharepoint/sites/jre',
        admin      => true,
    }

Parameters:

- $username
  - Fullname of the user
- $login
  - SamAccountName
- $weburl
  - URL of the site where we want to add user
- $group
  - Group name where we want put the user
- $admin
  - Is SiteColAdmin? Default : false

### windows_sharepoint::group

    windows_sharepoit{'SharePoint Owners':
        group           => "SharePoint Owners",
        weburl          => 'https://sharepoint/sites/jre',
        permissionlevel => 'Full Control',
        ownername       => 'jre',
    }

Parameters:

- $weburl
  - URL of the site where we want to add user
- $group
  - Group name where we want put the user
- $permissionlevel
  - Permissions for the group Full Control|Edit|Contribute|Read|Design
- $ownername
  - Owner of the group
- $description
  - group description

### windows_sharepoint::services::reporting

Allow installation and configuration of SharePoint reporting service integrated mode

    windows_sharepoint::services::reporting{"Reporting":
        databasename    => "ReportingServicesDB",
        databaseserver  => "SQL_ALIAS",
        serviceaccount  => "spservices",
    }

Parameters:

- $defaultsrvgrp
  - Add the service to the default service app group. Default: True.
- $apppoolname
  - App Pool name. The app pool will be created.
- $servicename
  - Service Name. Default: SQL Server Reporting Service Application.
- $proxyname
  - Proxy Name. Default: SQL Server Reporting Service Application Proxy.

## Known Issues

Please don't add a '/' after the WebApp URL and site url, if you do so AutoSpInstaller will throw an error and will not create the WebApp and site Coll.

The User profile Service Application will be installed but the synchronisation will not work. You have to remove the UPA Service and create another one manually. (Puppet can't get back the control with infinite powershell start-process instance :(, so I have to disable this steps. ). (Don't forget to give Replicate Right to the sync user.)

## License

-------
Apache License, Version 2.0

## Contact

-------

- [John Puskar](https://github.com/jpuskar/)
- [Jerome RIVIERE](https://github.com/ninja-2)

## Support

-------
Please log tickets and issues at the [Github site](https://github.com/jpuskar/windows_sharepoint/issues).
