# == Class: windows_sharepoint
#
class windows_sharepoint::install (
  $ensure  = present,
  ## XML input file
  $base_path                                     = $windows_sharepoint::base_path,
  $user_xml                                      = $windows_sharepoint::user_xml,
  ## Install parameters
  $key                                           = $windows_sharepoint::key,
  $offline                                       = $windows_sharepoint::offline,
  $auto_admin_logon                              = $windows_sharepoint::auto_admin_logon,
  $setup_account_username                        = $windows_sharepoint::setup_account_username,
  $setup_account_password                        = $windows_sharepoint::setup_account_password,
  $disable_loopback_check                        = $windows_sharepoint::disable_loopback_check,
  $disable_unused_services                       = $windows_sharepoint::disable_unused_services,
  $disable_ie_enhanced_security                  = $windows_sharepoint::disable_ie_enhanced_security,
  $certificate_revocation_list_check             = $windows_sharepoint::certificate_revocation_list_check,
  
  ## Farm parameters
  $pass_phrase                                   = $windows_sharepoint::pass_phrase,
  $sp_farm_account                               = $windows_sharepoint::sp_farm_account,
  $sp_farm_password                              = $windows_sharepoint::sp_farm_password,
  
  $central_admin_provision                       = $windows_sharepoint::central_admin_provision,
  $central_admin_database                        = $windows_sharepoint::central_admin_database,
  $central_admin_port                            = $windows_sharepoint::central_admin_port,
  $central_admin_ssl                             = $windows_sharepoint::central_admin_ssl,
  
  String[1]$db_server                            = $windows_sharepoint::db_server,
  $db_alias                                      = $windows_sharepoint::db_alias,
  $db_alias_port                                 = $windows_sharepoint::db_alias_port,
  $db_alias_instance                             = $windows_sharepoint::db_alias_instance,
  
  $db_prefix                                     = $windows_sharepoint::db_prefix,
  $db_user                                       = $windows_sharepoint::db_user,
  $db_password                                   = $windows_sharepoint::db_password,
  $config_db                                     = $windows_sharepoint::config_db,
  
  ## Services part
  $sanboxed_code_service_start                   = $windows_sharepoint::sanboxed_code_service_start,
  $claims_to_windows_token_server_start          = $windows_sharepoint::claims_to_windows_token_server_start,
  $claims_to_windows_token_server_update_account = $windows_sharepoint::claims_to_windows_token_server_update_account,
  
  $smtp_install                                  = $windows_sharepoint::smtp_install,
  $smtp_outgoing_email_configure                 = $windows_sharepoint::smtp_outgoing_email_configure,
  $smtp_outgoing_server                          = $windows_sharepoint::smtp_outgoing_server,
  $smtp_outgoing_email_address                   = $windows_sharepoint::smtp_outgoing_email_address,
  $smtp_outgoing_reply_to_email                  = $windows_sharepoint::smtp_outgoing_reply_to_email,

  $incoming_email_start                          = $windows_sharepoint::incoming_email_start,
  $distributed_cache_start                       = $windows_sharepoint::distributed_cache_start,
  $workflow_timer_start                          = $windows_sharepoint::workflow_timer_start,
  $foundation_web_application_start              = $windows_sharepoint::foundation_web_application_start,

  $sp_app_pool_account                           = $windows_sharepoint::sp_app_pool_account,
  $sp_app_pool_password                          = $windows_sharepoint::sp_app_pool_password,
  $sp_services_account                           = $windows_sharepoint::sp_services_account,
  $sp_services_password                          = $windows_sharepoint::sp_services_password,
  $sp_search_account                             = $windows_sharepoint::sp_search_account,
  $sp_search_password                            = $windows_sharepoint::sp_search_password,
  $sp_super_reader_account                       = $windows_sharepoint::sp_super_reader_account,
  $sp_super_user_account                         = $windows_sharepoint::sp_super_user_account,
  $sp_crawl_account                              = $windows_sharepoint::sp_crawl_account,
  $sp_crawl_password                             = $windows_sharepoint::sp_crawl_password,
  $sp_sync_account                               = $windows_sharepoint::sp_sync_account,
  $sp_sync_password                              = $windows_sharepoint::sp_sync_password,
  $sp_usr_prf_account                            = $windows_sharepoint::sp_usr_prf_account,
  $sp_usr_prf_password                           = $windows_sharepoint::sp_usr_prf_password,
  $sp_excel_account                              = $windows_sharepoint::sp_excel_account,
  $sp_excel_password                             = $windows_sharepoint::sp_excel_password,

  ## Log
  $log_compress                                  = $windows_sharepoint::log_compress,
  $iis_logs_path                                 = $windows_sharepoint::iis_logs_path,
  $uls_logs_path                                 = $windows_sharepoint::uls_logs_path,
  $usage_log_spath                               = $windows_sharepoint::usage_logs_path,
  
  ###DefaultWebApp
  $remove_default_web_app                        = $windows_sharepoint::remove_default_web_app,
  $web_app_url                                   = $windows_sharepoint::web_app_url,
  $application_pool                              = $windows_sharepoint::application_pool,
  $web_app_name                                  = $windows_sharepoint::web_app_name,
  $web_app_port                                  = $windows_sharepoint::web_app_port,
  $web_app_database_name                         = $windows_sharepoint::web_app_database_name,
  
  ##DefaultSiteCol
  $site_url                                      = $windows_sharepoint::site_url,
  $site_col_name                                 = $windows_sharepoint::site_col_name,
  $site_col_template                             = $windows_sharepoint::site_col_template,
  $site_col_time24                               = $windows_sharepoint::site_col_time24,
  $site_col_lcid                                 = $windows_sharepoint::site_col_lcid,
  $site_col_locale                               = $windows_sharepoint::site_col_locale,
  $site_col_owner                                = $windows_sharepoint::site_col_owner,
  
  $mysite_host                                   = $windows_sharepoint::mysite_host,
  $mysite_managed_path                           = $windows_sharepoint::mysite_managed_path,
  
  $sp_version                                    = $windows_sharepoint::sp_version,
  $computer_name                                 = $windows_sharepoint::computer_name,
  $use_invoke_command                            = false,
) {

  file{"${base_path}/Puppet-SharePoint/generatexml.ps1":
    content => template('windows_sharepoint/autospinstaller.erb'),
    replace => yes,
  }

  # logoutput false so we don't display passwords
  exec{'generate_xml':
    provider  => 'powershell',
    command   => "\
\$ErrorActionPreference = 'Stop'; \
${base_path}/Puppet-SharePoint/generatexml.ps1",
    require   => File["${base_path}/Puppet-SharePoint/generatexml.ps1"],
    onlyif    => "If ((Test-Path '${base_path}/Puppet-SharePoint/xmlgenerated') -eq \$true){Exit 1;}; ",
    logoutput => false,
  }

  $reboot_check = @(REBOOT_CHECK)
    $ErrorActionPreference = "Stop";
    $results = $false;
    $results = Test-Path "C:/windows/windows_sharepoint_puppet_reboot.txt";
    If ($results -eq $true) { exit 0; } else { exit 1; };
    | END_REBOOT_CHECK

  # Note: Can't use $ErrorActionPreference = 'Stop' because Puppet will throw
  #   a Ruby parse error.

  $cmd_launch_installer_params = @("END_CMD_LAUNCH_INSTALLER_PARAMS"/$)
    \$raw_password = "${setup_account_password}";
    \$username = "${setup_account_username}";
    \$computer_name = "${::fqdn}";
    \$base_path = "${base_path}";
    | END_CMD_LAUNCH_INSTALLER_PARAMS

  if $use_invoke_command {
    $cmd_launch_installer_frag = @(END_CMD_LAUNCH_INSTALLER_FRAG)
      $ErrorActionPreference = 'Stop';
      Invoke-Command -ScriptBlock {
        $exe_pol = Get-ExecutionPolicy;
        Set-ExecutionPolicy Bypass -Force;
        Try {
          C:/Puppet-SharePoint/AutoSPInstaller/AutoSPInstallerMain.ps1 `
            -inputFile "C:/Puppet-SharePoint/AutoSPInstaller/AutoSPInstallerInput.xml" `
            -unattended | Out-File "C:/puppet-sharepoint/install.log";
        } Catch {
          Set-ExecutionPolicy $exe_pol -Force;
        }
      };
      | END_CMD_LAUNCH_INSTALLER_FRAG
    $cmd_launch_installer = "${cmd_launch_installer_params}; ${cmd_launch_installer_frag}"

  } else {
    $cmd_launch_installer_frag = @(END_CMD_LAUNCH_INSTALLER)
      $password = ConvertTo-SecureString $raw_password -AsPlainText -Force;
      $cred = New-Object System.Management.Automation.PSCredential ($username, $password);
      $arg_list = '-ExecutionPolicy Bypass .\AutoSPInstallerMain.ps1 -inputFile "' + $base_path + '\Puppet-SharePoint\AutoSPInstaller\AutoSPInstallerInput.xml" -unattended';
      $install_proc = Start-Process "$pshome\powershell.exe" `
        -Credential $cred `
        -Wait `
        -WorkingDirectory ($base_path + '\Puppet-SharePoint\AutoSPInstaller\') `
        -ArgumentList $arg_list `
        -PassThru `
        -RedirectStandardOutput "C:/puppet-sharepoint/install.log";
      If($install_proc.exitcode -ne 0) {Throw $install_proc;}
      Else {Write-Output $install_proc;}
      | END_CMD_LAUNCH_INSTALLER
    $cmd_launch_installer = "${cmd_launch_installer_params}; ${cmd_launch_installer_frag}"
  }

  $base_check_cmd = @(END_BASE_CHECK_CMD)
    If ((Test-Path C:/Windows/windows_sharepoint_puppet_reboot.txt) -eq $true) {
      $skip_checks = $true;
    } Else { 
      $skip_checks = $false;
      Try {Add-PSSnapin 'Microsoft.SharePoint.PowerShell' -ErrorAction "SilentlyContinue";}
      Catch {}
      $snapin = Get-PSSnapin | Where-Object {$_.name -like "*SharePoint.PowerShell*"};
      If($snapin.count -eq 0) {
        $check_failed = $true;
      } Else {
        $check_failed = $false;
      }
    };
    | END_BASE_CHECK_CMD

    $cmd_check_sp_state_service = @(END_CMD_CHECK_SP_STATE_SERVICE)
    If(!$skip_checks) { 
      $test_prop = $null;
      Try {$test_prop = Get-SPStateServiceApplication;}
      Catch {}
      If($test_prop -eq $null){ 
        $check_failed = $true; 
      };
    };
    | END_CMD_CHECK_SP_STATE_SERVICE

    $cmd_excel_service_check = @(END_CMD_EXCEL_SERVICE_CHECK)
      If(!$skip_checks) { 
        $test_prop = $null;
        Try {
          $test_prop = Get-SPExcelServiceApplication | Where-Object {
            $_.DisplayName -Like "*Excel Services*"
          };
        } Catch {};
        If($test_prop -eq $null) { 
          $check_failed = $true; 
        };
      };
      | END_CMD_EXCEL_SERVICE_CHECK

    $cmd_check_sp_profile_service = @(END_CMD_CHECK_SP_PROFILE_SERVICE)
      If(!$skip_checks) { 
        $test_prop = $null;
        Try {
          $test_prop = Get-SPStateServiceApplication | Where-Object {
            $_.DisplayName -Like "*User Profile*"
          };
        };
        If($test_prop -eq $null) { 
          $check_failed = $true;
        };
      };
      | END_CMD_CHECK_SP_PROFILE_SERVICE

    $cmd_cleanup_reg_and_exit = @(END_CMD_CLEANUP_REG_AND_EXIT)
      If(!$skip_checks) { 
        If($check_failed) { 
          Exit 1; 
          Throw "Verify failed."; 
        } Else { 
          New-ItemProperty `
            -Path "HKLM:\Software\AutoSPInstaller" `
            -Name 'PuppetSharePointInstallInProgress' `
            -Value 0 `
            -PropertyType 'String' `
            -Force | Out-Null;
          Exit 0; 
        };
      };
      | END_CMD_CLEANUP_REG_AND_EXIT

  $sp_foundation_install_unless_cmd = " \
${base_check_cmd}; \
${cmd_check_sp_state_service}; \
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
    command   => "Write-Host \"Triggering reboot.\";",
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

  case $sp_version {
    'Foundation': {
      $final_install_cmd = $sp_foundation_install_cmd
      $final_install_unless_cmd = $sp_foundation_install_unless_cmd
    }
    'Standard': {
      $final_install_cmd = $sp_standard_install_cmd
      $final_install_unless_cmd = $sp_standard_install_unless_cmd
    }
    'Enterprise': {
      $final_install_cmd  = $sp_ent_install_cmd
      $final_install_unless_cmd = $sp_ent_install_unless_cmd
    }
  }
  
  $cmd_fake_out_sp_setup_dotnet_ver = @(END_CMD_FAKE_OUT_SP_SETUP_DOTNET_VER/L)
    $ErrorActionPreference = 'Stop'; 
    $reg_path = "HKLM:\software\microsoft\NET Framework Setup\NDP\v4\Client"; 
    $reg_path_simple = "HKEY_LOCAL_MACHINE\software\microsoft\NET Framework Setup\NDP\v4\Client"; 
    setacl.exe \
      -ot reg \
      -on "$reg_path_simple" \
      -actn setowner \
      -ownr "n:Administrators" | Out-Null; 
    setacl.exe \
      -ot reg \
      -on "$reg_path_simple" \
      -actn setowner \
      -ownr "n:Administrators" \
      -actn ace \
      -ace "n:Administrators;p:full" | Out-Null; 
    $curVer = (Get-ItemProperty $reg_path).Version; 
    If($curVer -ne "4.5.50501") { 
      $curVer | out-file 'C:/windows/cur_dotnet_ver.txt' -Force; 
      New-ItemProperty -path $reg_path -Name "Version" -Value "4.5.50501" -Force; 
    };
    | END_CMD_FAKE_OUT_SP_SETUP_DOTNET_VER
  
  $cmd_fix_sp_setup_dotnet_ver = @(END_CMD_FIX_SP_SETUP_DOTNET_VER)
    $ErrorActionPreference = 'Stop'; 
    $reg_path = "HKLM:\software\microsoft\NET Framework Setup\NDP\v4\Client"; 
    $cur_ver = (Get-ItemProperty $reg_path).Version; 
    $orig_ver = Get-Content 'C:/Windows/cur_dotnet_ver.txt' -Force; 
    If($cur_ver -ne $orig_ver) { 
      New-ItemProperty -Path $reg_path -Name "Version" -Value $orig_ver -Force;
    };
    | END_CMD_FIX_SP_SETUP_DOTNET_VER
  
  $cmd_unless_fix_sp_setup_dotnet_ver = @(END_CMD_UNLESS_FIX_SP_SETUP_DOTNET_VER)
    $ErrorActionPreference = 'Stop'; 
    If((Test-Path "C:/Windows/cur_dotnet_ver.txt") -eq $false) {
      Exit 0;
    } Else { 
      $reg_path = "HKLM:\software\microsoft\NET Framework Setup\NDP\v4\Client"; 
      $cur_ver = (Get-ItemProperty $reg_path).Version; 
      $orig_ver = Get-Content 'C:/Windows/cur_dotnet_ver.txt' -Force; 
      If($cur_ver -ne $orig_ver) {Exit 1;} Else {Exit 0;};
    };
    | END_CMD_UNLESS_FIX_SP_SETUP_DOTNET_VER
  

  file{'C:\windows\windows_sharepoint_puppet_reboot.txt':
    ensure => 'absent',
  } ->
  exec {'fake_out_sp_setup_dotnet_ver':
    provider    => 'powershell',
    command     => $cmd_fake_out_sp_setup_dotnet_ver,
    unless      => $final_install_unless_cmd,
    logoutput   => true,
    } ->
  exec{'lauching_auto_sp_installer':
    provider  => 'powershell',
    command   => $final_install_cmd,
    timeout   => '7200',
    logoutput => true,
    unless    => $final_install_unless_cmd,
    before    => Exec['trigger_reboot_for_sp_install'],
  } ->
  exec {'fix_sp_setup_dotnet_ver':
    provider => 'powershell',
    command  => $cmd_fix_sp_setup_dotnet_ver,
    unless   => $cmd_unless_fix_sp_setup_dotnet_ver,
  }

  $cmd_onlyif_set_central_admin_port_1 = "\$central_admin_port = ${central_admin_port}"
  $cmd_onlyif_set_central_admin_port_2 =  @(END_CMD_UNLESS_SET_CENTRAL_ADMIN_PORT)
    If((Test-Path "HKLM:\SOFTWARE\AutoSPInstaller") -eq $true) {
      $reg_auto_sp_installer = $null;
      $reg_auto_sp_installer = Get-ItemProperty -Path "HKLM:\SOFTWARE\AutoSPInstaller" -ErrorAction SilentlyContinue
      If($reg_auto_sp_installer.PuppetSharePointInstallInProgress -eq '1') {
        Exit 1;
      } Else {
        Add-PSSnapin 'Microsoft.SharePoint.PowerShell' -ea SilentlyContinue;
        $snapin = Get-PSSnapin '*SharePoint.PowerShell' -ea SilentlyContinue;
        If($snapin.count -eq 1){
          $getSPStateServiceApplication = Get-SPStateServiceApplication;
          If($getSPStateServiceApplication -eq $null){
            Exit 1;
          } Else {
            $port = [Microsoft.SharePoint.Administration.SPAdministrationWebApplication]::Local.Sites.VirtualServer.Port;
            If($port -eq $central_admin_port){Exit 1;}
          }
        } Else {Exit 1;}
      } Else {
        $port = [Microsoft.SharePoint.Administration.SPAdministrationWebApplication]::Local.Sites.VirtualServer.Port;
        If($port -eq $central_admin_port){Exit 1;}
      };
    };
    | END_CMD_UNLESS_SET_CENTRAL_ADMIN_PORT
  
  $cmd_onlyif_set_central_admin_port = "${cmd_onlyif_set_central_admin_port_1}; ${cmd_onlyif_set_central_admin_port_2}"
    exec{'set_central_admin_port':
      provider => 'powershell',
      command  => " \
\$ErrorActionPreference = 'Stop'; \
Add-PSSnapin Microsoft.SharePoint.PowerShell -ea SilentlyContinue; \
Set-SPCentralAdministration -Port ${central_admin_port} -Confirm:\$false",
      onlyif   => $cmd_onlyif_set_central_admin_port,
    }

    if($remove_default_web_app){
      windows_sharepoint::webapplication{"default - $web_app_name":
        ensure                 => absent,
        url                    => $web_app_url,
        applicationpoolname    => $application_pool,
        webappname             => $web_app_name,
        databasename           => $web_app_database_name,
        applicationpoolaccount => $sp_app_pool_account,
      }

      Exec['generate_xml'] ~>
      Exec['lauching_auto_sp_installer'] ~>
      Exec['set_central_admin_port'] ~>
      Windows_sharepoint::Webapplication["default - $web_app_name"]

    } else {
      Exec['generate_xml'] ~>
      Exec['lauching_auto_sp_installer'] ~>
      Exec['set_central_admin_port']
    }

}
