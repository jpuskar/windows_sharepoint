windows_sharepoint

This is the windows_sharepoint module.

## Module Description

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

The parent version of this project was tested on the following, and therefore these probably still work:
- SharePoint Standard 2013 SP1
- SharePoint EnterPrise 2013 SP1

## Changelog
V 0.0.11
 - Lint fixes.

V 0.0.10:
 - Fixed regression issue in cmd_launch_installer_frag which caused SharePoint installation to fail.

V 0.0.9:
 - Refactored to use heredocs for readability.
 - Refactored to use underscores for word designation in variable names.
 - Added code to workaround newer dot net version when installing SharePoint.
 - Fixed several more installer bugs.

V 0.0.8:
 - Fixed inability to install SharePoint foundation.
 - Modified exec commands to work despite the Exec Powershell provider return code issues.
 - Added setup_account_username option.
 - Changed defaults for dbalias, dbaliasport, dbaliasinstance, dbserver for clarity.
 - Updated to AutoSpInstaller 3.99.60.
 - Added code to manage AutoSpInstaller reboots.

V 0.0.7 :
 - Add -ea option on powershell command
 - Update the way to execute SharePoint installation
 
### Setup Requirements
Depends on the following modules:
    - ['puppetlabs/powershell', '>=1.0.2'](https://forge.puppetlabs.com/puppetlabs/powershell),
    - ['puppetlabs/stdlib', '>= 4.2.1'](https://forge.puppetlabs.com/puppetlabs/stdlib)

## Usage

The module expects that:
- Setacl.exe is available in the system path.
- The modified AutoSpInstaller is extracted to $base_path\Puppet-SharePoint\.

The folder structure should look like this, if $base_path is kept to at the default of 'C:'.
- C:\Puppet-SharePoint\AutoSPInstaller\2013\
- C:\Puppet-SharePoint\AutoSPInstaller\AutoSPInstallerMain.ps1
- C:\Puppet-SharePoint\AutoSPInstaller\AutoSPInstallerInput.xml

## Resources

### windows_sharepoint
Installs and configures sharepoint.
See manifest file for parameters.

### webapplication
```puppet
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
```
### user
```puppet
    windows_sharepoint{'SQLServer':
      username   => "Jerome",
      login      => 'jre',
      group      => "SharePoint Owners",
      weburl     => 'https://sharepoint/sites/jre',
      admin      => true,
    }
```
##SP Group

```puppet
    windows_sharepoit{'SharePoint Owners':
      group           => "SharePoint Owners",
      weburl          => 'https://sharepoint/sites/jre',
      permissionlevel => 'Full Control',
      ownername       => 'jre',
    }
```

### webapplication
```puppet
    windows_sharepoint::services::reporting{"Reporting":
      databasename    => "ReportingServicesDB",
      databaseserver  => "SQL_ALIAS",
      serviceaccount  => "spservices",
    }
```

## Known issues
Please don't add a '/' after the WebApp URL and site url, if you do so AutoSpInstaller will throw an error and will not create the WebApp and site collection. 

The User profile Service Application will be installed but the synchronization will not work. You have to remove the UPA Service and create another one manually. Don't forget to give Replicate Right to the sync user.

License
-------
Apache License, Version 2.0

Contact
-------
[John Puskar](https://github.com/jpuskar)

Support
-------
Please log tickets and issues at [Github site](https://github.com/jpuskar/windows_sharepoint/issues)
