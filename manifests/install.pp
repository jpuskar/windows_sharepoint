# == Class: windows_sharepoint
#
# Full description of class windows_sharepoint here.
#
# === Parameters
#
# === Examples
#
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2014 Your name here, unless otherwise noted.
#
class windows_sharepoint::install 
(
  $ensure  = present,
  ## XML input file
  $xmlinputfile                              = hiera('windows_sharepoint::xmlinputfile', ''),               # if specify all other options will be desactivated
  $basepath                                  = hiera('windows_sharepoint::basepath', 'C:\\'),
  $userxml                                   = hiera('windows_sharepoint::userxml', 'C:\users.xml'),
  ## Install parameters
  $key                                       = hiera('windows_sharepoint::key', ''),
  $offline                                   = hiera('windows_sharepoint::offline', false),
  $autoadminlogon                            = hiera('windows_sharepoint::autoadminlogon', true),
  $setup_account_username                    = hiera('windows_sharepoint::setup_account_username', ''),
  $setup_account_password                    = hiera('windows_sharepoint::setup_account_password', ''),
  $disableloopbackcheck                      = hiera('windows_sharepoint::disableloopbackcheck', true),
  $disableunusedservices                     = hiera('windows_sharepoint::disableunusedservices', true),
  $disableieenhancedsecurity                 = hiera('windows_sharepoint::disableieenhancedsecurity', true),
  $certificaterevocationlistcheck            = hiera('windows_sharepoint::certificaterevocationlistcheck', true),
  
  ## Farm parameters
  $passphrase                                = hiera('windows_sharepoint::passphrase', ''),
  $spfarmaccount                             = hiera('windows_sharepoint::spfarmaccount', ''),
  $spfarmpassword                            = hiera('windows_sharepoint::spfarmpassword', ''),                 # if empty will check XML File
  
  $centraladminprovision                     = hiera('windows_sharepoint::centraladminprovision', 'localhost'),       #where to provision
  $centraladmindatabase                      = hiera('windows_sharepoint::centraladmindatabase', 'Content_Admin'),
  $centraladminport                          = hiera('windows_sharepoint::centraladminport', 4242),
  $centraladminssl                           = hiera('windows_sharepoint::centraladminssl', false),
  
  $dbserver                                  = hiera('windows_sharepoint::dbserver', 'localhost'),                  # name of alias, or name of SQL Server
  $dbalias                                   = hiera('windows_sharepoint::dbalias', false),
  $dbaliasport                               = hiera('windows_sharepoint::dbaliasport', 1433),                  # if empty default will used
  $dbaliasinstance                           = hiera('windows_sharepoint::dbaliasinstance', 'MSSQLSERVER'),                  # name of SQL Server
  
  $dbprefix                                  = hiera('windows_sharepoint::dbprefix', 'SP2013'),            # Prefix for DB
  $dbuser                                    = hiera('windows_sharepoint::dbuser', ''),
  $dbpassword                                = hiera('windows_sharepoint::dbpassword', ''),
  $configdb                                  = hiera('windows_sharepoint::configdb', 'ConfigDB'),
  
  ## Services part
  $sanboxedcodeservicestart                  = hiera('windows_sharepoint::sanboxedcodeservicestart', false),
  $claimstowindowstokenserverstart           = hiera('windows_sharepoint::claimstowindowstokenserverstart', false),
  $claimstowindowstokenserverupdateaccount   = hiera('windows_sharepoint::claimstowindowstokenserverupdateaccount', false),
  
  $smtpinstall                               = hiera('windows_sharepoint::smtpinstall', false),
  $smtpoutgoingemailconfigure                = hiera('windows_sharepoint::smtpoutgoingemailconfigure', false),
  $smtpoutgoingserver                        = hiera('windows_sharepoint::smtpoutgoingserver', ''),
  $smtpoutgoingemailaddress                  = hiera('windows_sharepoint::smtpoutgoingemailaddress', ''),
  $smtpoutgoingreplytoemail                  = hiera('windows_sharepoint::smtpoutgoingreplytoemail', ''),

  $incomingemailstart                        = hiera('windows_sharepoint::incomingemailstart', 'localhost'),
  $distributedcachestart                     = hiera('windows_sharepoint::distributedcachestart', 'localhost'),
  $workflowtimerstart                        = hiera('windows_sharepoint::workflowtimerstart', 'localhost'),
  $foundationwebapplicationstart             = hiera('windows_sharepoint::foundationwebapplicationstart', 'localhost'),

  $spapppoolaccount                          = hiera('windows_sharepoint::spapppoolaccount', ''),
  $spapppoolpassword                         = hiera('windows_sharepoint::spapppoolpassword', ''),                 # if empty will check XML File
  $spservicesaccount                         = hiera('windows_sharepoint::spservicesaccount', ''),
  $spservicespassword                        = hiera('windows_sharepoint::spservicespassword', ''),                 # if empty will check XML File
  $spsearchaccount                           = hiera('windows_sharepoint::spsearchaccount', ''),
  $spsearchpassword                          = hiera('windows_sharepoint::spsearchpassword', ''),                 # if empty will check XML File
  $spsuperreaderaccount                      = hiera('windows_sharepoint::spsuperreaderaccount', ''),
  $spsuperuseraccount                        = hiera('windows_sharepoint::spsuperuseraccount', ''),
  $spcrawlaccount                            = hiera('windows_sharepoint::spcrawlaccount', ''),
  $spcrawlpassword                           = hiera('windows_sharepoint::spcrawlpassword', ''),                 # if empty will check XML File
  $spsyncaccount                             = hiera('windows_sharepoint::spsyncaccount', ''),
  $spsyncpassword                            = hiera('windows_sharepoint::spsyncpassword', ''),                # if empty will check XML File
  $spusrprfaccount                           = hiera('windows_sharepoint::spusrprfaccount', ''),
  $spusrprfpassword                          = hiera('windows_sharepoint::spusrprfpassword', ''),                # if empty will check XML File
  $spexcelaccount                            = hiera('windows_sharepoint::spexcelaccount', ''),
  $spexcelpassword                           = hiera('windows_sharepoint::spexcelpassword', ''),                # if empty will check XML File

  ## Log
  $logcompress                               = hiera('windows_sharepoint::logcompress', true),
  $iislogspath                               = hiera('windows_sharepoint::iislogspath', 'C:\SPLOGS\IIS'),
  $ulslogspath                               = hiera('windows_sharepoint::ulslogspath', 'C:\SPLOGS\ULS'),
  $usagelogspath                             = hiera('windows_sharepoint::usagelogspath', 'C:\SPLOGS\USAGE'),
  
  ###DefaultWebApp
  $removedefaultwebapp                       = hiera('windows_sharepoint::removedefaultwebapp', false),             # if true the default web app will be removed.
  $webappurl                                 = hiera('windows_sharepoint::webappurl', 'https://localhost'),
  $applicationPool                           = hiera('windows_sharepoint::applicationPool', 'SharePointDefault_App_Pool'),
  $webappname                                = hiera('windows_sharepoint::webappname', 'SharePoint Default Web App'),
  $webappport                                = hiera('windows_sharepoint::webappport', 443),
  $webappdatabasename                        = hiera('windows_sharepoint::webappdatabasename', 'Content_SharePointDefault'),
  
  ##DefaultSiteCol
  $siteurl                                   = hiera('windows_sharepoint::siteurl', 'https://localhost'),
  $sitecolname                               = hiera('windows_sharepoint::sitecolname', 'WebSite'),
  $sitecoltemplate                           = hiera('windows_sharepoint::sitecoltemplate', 'STS#0'),
  $sitecoltime24                             = hiera('windows_sharepoint::sitecoltime24', true),
  $sitecollcid                               = hiera('windows_sharepoint::sitecollcid', 1033),
  $sitecollocale                             = hiera('windows_sharepoint::sitecollocale', 'en-us'),
  $sitecolowner                              = hiera('windows_sharepoint::sitecolowner', ''),
  
  $mysitehost                                = hiera('windows_sharepoint::mysitehost', ''),
  $mysitemanagedpath                         = hiera('windows_sharepoint::mysitemanagedpath', 'personal'),
  
  $spversion                                 = hiera('windows_sharepoint::spversion', 'Foundation'),
  $computername                              = hiera('windows_sharepoint::computername', $::hostname),
)
{
  if(!empty($xmlinputfile)){ # Install with xml file
    ## need to copy $xmlinputfile to C:\Puppet-SharePoint\AutoSPInstaller
    fail('not yet implemented')
  }else{ ## Install without a xml file
    if($spversion != 'Foundation'){
      #fail('XML File will be generated only for Foundation version. For others version please fill you AutoSPInstallerInput.xml file')
      notice("using $spversion")
    }
    if((empty($spfarmaccount) or empty($spapppoolaccount) or empty($spservicesaccount) or empty($spsearchaccount) or empty($spcrawlaccount) or empty($spsuperreaderaccount) or empty($spsuperuseraccount)) and $spversion == 'Foundation'){
       fail('All Accounts need to be specify (spfarmaccount, spapppoolaccount, spservicesaccount, spsearchaccount, spcrawlaccount, spsuperreaderaccount, spsuperuseraccount)')
    }

    if((empty($spfarmaccount) or empty($spapppoolaccount) or empty($spservicesaccount) or empty($spsearchaccount) or empty($spcrawlaccount) or empty($spsuperreaderaccount) or empty($spsuperuseraccount) or empty($spsyncaccount) or empty($spusrprfaccount)) and $spversion == 'Standard'){
       fail('All Accounts need to be specify except spexcelaccount')
    }

    if((empty($spfarmaccount) or empty($spapppoolaccount) or empty($spservicesaccount) or empty($spsearchaccount) or empty($spcrawlaccount) or empty($spsuperreaderaccount) or empty($spsuperuseraccount) or empty($spsyncaccount) or empty($spusrprfaccount) or empty($spexcelaccount)) and $spversion == 'Enterprise'){
       fail('All Accounts need to be specify')
    }

    if($autoadminlogon == true and empty(setup_account_password)){
      fail('If autoadminlogin is set to true you need to specify your setup password')
    }
    if(empty($dbserver)){
      fail('DBServer is mandatory')
    }
    if($dbalias == true and empty(dbaliasinstance)){
      fail('Can\'t set DBalias to true without specify a dbaliasinstance')
    }
    if(empty($sitecolowner)){
      fail('Site Col Owner can\'t be empty')
    }
    if(empty(key)){
      fail('A serial number (key) is mandatory')
    }
    if(empty(passphrase)){
      fail('PassPhrase is empty')
    }
    if($centraladminport < 1023 or $centraladminport > 32767 or $centraladminport == 443 or centraladmindatabase == 80){
      fail('centraladminport can\'t be set to this value. CentralAdminPort need to be superior at 1023, inferior at 32767 and different of 443 and 80')
    }

    file{"$basepath\\Puppet-SharePoint\\generatexml.ps1":
      content => template('windows_sharepoint/autospinstaller.erb'),
      replace => yes,
    }

    # logoutput false so we don't display passwords
    exec{'generate_xml':
      provider  => powershell,
      command   => "\
\$ErrorActionPreference = 'Stop'; \
$basepath\\Puppet-SharePoint\\generatexml.ps1",
      require   => File["$basepath\\Puppet-SharePoint\\generatexml.ps1"],
      onlyif    => "if ((test-path '${basepath}\\Puppet-SharePoint\\xmlgenerated') -eq \$true){exit 1;}; ",
      logoutput => false,
    }

    $reboot_check = " \
\$ErrorActionPreference = \"Stop\"; \
\$results = \$false; \
\$results = test-path \"C:\\windows\\windows_sharepoint_puppet_reboot.txt\"; \
if (\$results -eq \$true) { \
 exit 0; \
 } else { \
 exit 1; \
};"

    # Note: Can't use $ErrorActionPreference = 'Stop' because Puppet will throw
    #   a Ruby parse error.
    $cmd_launch_installer = " \
\$password = ConvertTo-SecureString '${setup_account_password}' -AsPlainText -Force; \
\$cred= New-Object System.Management.Automation.PSCredential (\"${setup_account_username}\", \$password); \
\$install_proc = Start-Process \"\$pshome\\powershell.exe\" \
 -Credential \$cred \
 -Wait \
 -WorkingDirectory '${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\' \
 -ArgumentList ' \
  -ExecutionPolicy Bypass \
  .\\AutoSPInstallerMain.ps1 \
  -inputFile \"${basepath}\\Puppet-SharePoint\\AutoSPInstaller\\AutoSPInstallerInput.xml\" \
  -unattended '\
 -PassThru \
 -RedirectStandardOutput \"C:\\puppet-sharepoint\\install.log\"; \
if(\$install_proc.exitcode -ne 0) {Throw}; "

    $base_check_cmd = " \
if ((Test-Path C:\\Windows\\windows_sharepoint_puppet_reboot.txt) -eq \$true) { \
 \$skip_checks = \$true; \
} else { \
 \$skip_checks = \$false; \
 Add-PSSnapin 'Microsoft.SharePoint.PowerShell'; \
 \$snapin = Get-PSSnapin '*SharePoint.PowerShell'; \
 if(\$snapin.count -eq 0) { \
  \$check_failed = \$true; \
 } else { \
  \$check_failed = \$false; \
 }
} ;"

    $cmd_check_sp_state_service = " \
if(!\$skip_checks) { \
 \$test_prop = \$null; \
 \$test_prop = Get-SPStateServiceApplication; \
 if(\$test_prop -eq \$null){ \
   \$check_failed = \$true; \
 } \
} ;"

    $cmd_excel_service_check = " \
if(!\$skip_checks) { \
 \$test_prop = \$null; \
 \$test_prop = Get-SPExcelServiceApplication | ?{ \
  \$_.DisplayName -Match \"Excel Services \" \
 }; \
if(\$test_prop -eq \$null) { \
  \$check_failed = \$true; \
 }\
} ; "

    $cmd_check_sp_profile_service = " \
if(!\$skip_checks) { \
 \$test_prop = \$null; \
 \$test_prop = Get-SPStateServiceApplication | ?{ \
  \$_.DisplayName -Match \"User Profile \" \
 }; \
 if(\$test_prop -eq \$null){ \
   \$check_failed = \$true; \
 } \
}; "

    $cmd_cleanup_reg_and_exit = " \
\$ErrorActionPreference = 'Stop'; \
if(!\$skip_checks) { \
 if(\$check_failed) { \
  exit 1; \
  Throw \"Verify failed.\"; \
 } else { \
  New-ItemProperty \
   -Path \"HKLM:\\Software\\AutoSPInstaller\\\" \
   -Name 'PuppetSharePointInstallInProgress' \
   -Value 0 \
   -PropertyType 'String' \
   -Force | Out-Null; \
  exit 0; \
 }\
}; "

    $sp_foundation_install_unless_cmd = " \
${base_check_cmd} \
${cmd_check_sp_state_service} \
${cmd_cleanup_reg_and_exit}; "

    $sp_standard_install_unless_cmd = " \
${base_check_cmd} \
${cmd_check_sp_profile_service} \
${cmd_cleanup_reg_and_exit}; "

    $sp_ent_install_unless_cmd = " \
${base_check_cmd} \
${cmd_excel_service_check} \
${cmd_cleanup_reg_and_exit}; "

    exec{'trigger_reboot_for_sp_install':
      provider  => 'powershell',
      command   => "write-host \"Triggering reboot.\";",
      onlyif    => $reboot_check,
      logoutput => true,
      notify    => Reboot['after_auto_sp_install'],
    }

    reboot{'after_auto_sp_install':
      when => 'refreshed',
    }

    $sp_foundation_install_cmd = " \
${cmd_launch_installer} \
${sp_foundation_install_unless_cmd}"

    $sp_standard_install_cmd = "\
${cmd_launch_installer} \
${sp_standard_install_unless_cmd}"

    $sp_ent_install_cmd = " \
${cmd_launch_installer} \
${sp_ent_install_unless_cmd}"

    if($spversion == 'Foundation'){
      $final_install_cmd = $sp_foundation_install_cmd
      $final_install_unless_cmd = $sp_foundation_install_unless_cmd
    }elsif($spversion == 'Standard'){
      $final_install_cmd = $sp_standard_install_cmd
      $final_install_unless_cmd = $sp_standard_install_unless_cmd
    }elsif($spversion == 'Enterprise'){
      $final_install_cmd  = $sp_ent_install_cmd
      $final_install_unless_cmd = $sp_ent_install_unless_cmd
    }

    file{'C:\windows\windows_sharepoint_puppet_reboot.txt':
      ensure => 'absent',
    } ->
    exec {'fake_out_sp_setup_dotnet_ver':
      provider  => 'powershell',
      command   => " \
\$ErrorActionPreference = 'Stop'; \
\$reg_path = \"HKLM:\\software\\microsoft\\NET Framework Setup\\NDP\\v4\\Client\"; \
\$reg_path_simple = \"HKEY_LOCAL_MACHINE\\software\\microsoft\\NET Framework Setup\\NDP\\v4\\Client\"; \
setacl.exe \
 -ot reg \
 -on \"\$reg_path_simple\" \
 -actn setowner \
 -ownr \"n:Administrators\" | out-null; \
setacl.exe \
 -ot reg \
 -on \"\$reg_path_simple\" \
 -actn setowner \
 -ownr \"n:Administrators\" \
 -actn ace \
 -ace \"n:Administrators;p:full\" | out-null; \
\$curVer = (Get-ItemProperty \$reg_path).Version; \
if(\$curVer -ne \"4.5.50501\") { \
 \$curVer | out-file 'C:\\windows\\cur_dotnet_ver.txt' -Force; \
 New-ItemProperty -path \$reg_path -Name \"Version\" -Value \"4.5.50501\" -Force; \
}; ",
      logoutput => true,
    } ->
    notify{'Calling AutoSpInstaller.':} ->
    exec{'lauching_auto_sp_installer':
      provider => powershell,
      command  => $final_install_cmd,
      timeout  => "7200",
      unless   => $final_install_unless_cmd,
      before   => Exec['trigger_reboot_for_sp_install'],
    } ->
    exec {'fix_sp_setup_dotnet_ver':
      provider => 'powershell',
      command  => " \
\$reg_path = \"HKLM:\\software\\microsoft\\NET Framework Setup\\NDP\\v4\\Client\"; \
\$reg_path_simple = \"HKEY_LOCAL_MACHINE\\software\\microsoft\\NET Framework Setup\\NDP\\v4\\Client\"; \
\$orig_ver = gc 'C:\\Windows\\cur_dotnet_ver.txt' -Force; \
\$curVer = \$reg_path.Version; \
if(\$curVer -ne \$orig_ver) { \
﻿New-ItemProperty -path \$reg_path -Name \"Version\" -Value \$orig_ver -Force; \
}; "
    }

    exec{'SetCentralAdmin Port':
      provider => powershell,
      command  => " \
\$ErrorActionPreference = 'Stop'; \
Add-PSSnapin Microsoft.SharePoint.PowerShell -ea SilentlyContinue;\
Set-SPCentralAdministration -Port ${centraladminport} -Confirm:\$false",
      onlyif   => "\
if((test-path \"HKLM:\\SOFTWARE\\AutoSPInstaller\\\") -eq \$true) { \
 if((Get-ItemProperty -Path \"HKLM:\\SOFTWARE\\AutoSPInstaller\\\" -ErrorAction SilentlyContinue).PuppetSharePointInstallInProgress -eq '1') {\
  exit 1;\
 } else {\
  Add-PSSnapin 'Microsoft.SharePoint.PowerShell' -ea SilentlyContinue; \
  \$snapin = Get-PSSnapin '*SharePoint.PowerShell' -ea SilentlyContinue; \
  if(\$snapin.count -eq 1){ \
   \$getSPStateServiceApplication = Get-SPStateServiceApplication; \
   if(\$getSPStateServiceApplication -eq \$null){ \
    exit 1; \
   } else { \
    \$port = [Microsoft.SharePoint.Administration.SPAdministrationWebApplication]::Local.Sites.VirtualServer.Port; \
    if(\$port -eq ${centraladminport}){exit 1;} \
   } \
  } else {exit 1;} \
 } else { \
  \$port = [Microsoft.SharePoint.Administration.SPAdministrationWebApplication]::Local.Sites.VirtualServer.Port;\
  if(\$port -eq ${centraladminport}){exit 1;}\
 } \
}",
    }

    if($removedefaultwebapp){
      windows_sharepoint::webapplication{"default - $webappname":
        url                    => "${webappurl}",
        applicationpoolname    => "${applicationPool}",
        webappname             => "${webappname}",
        databasename           => "${webappdatabasename}",
        applicationpoolaccount => "${spapppoolaccount}",
        ensure                 => absent,
      }

      Exec['generate_xml'] ~>
      Exec['Lauching AutoSPInstaller'] ~>
      Exec['SetCentralAdmin Port'] ~>
      Windows_sharepoint::Webapplication["default - $webappname"]

    } else {
      Exec['generate_xml'] ~>
      Exec['lauching_auto_sp_installer'] ~>
      Exec['SetCentralAdmin Port']
    }

    # Exec['lauching_auto_sp_installer'] ~> Exec['trigger_reboot_for_sp_install']

  }
}
