# == Class: windows_sharepoint
#
# Full description of class windows_sharepoint here.
#
# === Parameters
#
# removedefaultwebapp : A default web app its created when installing SharePoint, you can remove it by set this parameters to true
#
# === Examples
#
# class{'windows_sharepoint':
#   languagepackspath => 'C:\\source\\LanguagePacks',
#   sppath => 'C:\\source\\sharepoint.exe',
#   spversion  => 'Foundation',
#   setup_account_password  => 'P@ssw0rd',
#   spfarmaccount => 's-spfarm',
#   dbserver => 'SQL_ALIAS',
#   dbaliasinstance => 'localhost',
#   spapppoolaccount => 'spapppool',
#   spservicesaccount => 'spservices',
#   spsearchaccount => 'spsearch',
#   spcrawlaccount => 'spcrawl',
#   spsuperreaderaccount => 'spsuperreader',
#   spsuperuseraccount => 'spsuperuser',
#   removedefaultwebapp => true,
#   sitecolowner => 'spfarm',
#   key => 'SYOUR-PRODU-CTKEY-OFSPS-2012S',
#   passphrase => 'WeN33daCompl1cat3DP@ssphrase',
# }
# === Authors
#
# Jerome RIVIERE <www.jerome-riviere.re>
# John Puskar https://github.com/jpuskar
#
# === Copyright
#
# Copyright 2014, unless otherwise noted.
#
class windows_sharepoint (
  ## Prep SP
  $base_path                                     = 'C:',
  $language_packs_path                           = undef,
  $updates_path                                  = undef,
  $sp_path                                       = 'c:/install_files/sharepoint.7z',
  $sp_version                                    = 'Foundation',
  
  ## XML input file
  $user_xml                                      = undef, #'C:/users.xml',
  ## Install parameters
  $key                                           = undef,
  $offline                                       = false,
  $auto_admin_logon                              = false,
  $setup_account_username                        = 'Administrator',
  $disable_loopback_check                        = true,
  $disable_unused_services                       = true,
  $disable_ie_enhanced_security                  = true,
  $certificate_revocation_list_check             = true,
  
  $central_admin_provision                       = 'localhost',
  $central_admin_database                        = 'Content_Admin',
  $central_admin_port                            = 4242,
  $central_admin_ssl                             = false,

  $db_server                                     = 'SQL_ALIAS',
  $db_alias                                      = false,
  $db_alias_port                                 = '1433',
  $db_alias_instance                             = 'MSSQLSERVER',
  
  $db_prefix                                     = 'SP2013',
  $db_user                                       = undef,
  $db_password                                   = undef,
  $config_db                                     = 'ConfigDB',
  
  ## Services part
  $sanboxed_code_service_start                   = false,
  $claims_to_windows_token_server_start          = false,
  $claims_to_windows_token_server_update_account = false,
  
  $smtp_install                                  = false,
  $smtp_outgoing_email_configure                 = false,
  $smtp_outgoing_server                          = undef,
  $smtp_outgoing_email_address                   = undef,
  $smtp_outgoing_reply_to_email                  = undef,

  $incoming_email_start                          = 'localhost',
  $distributed_cache_start                       = 'localhost',
  $workflow_timer_start                          = 'localhost',
  $foundation_web_application_start              = 'localhost',

  $sp_app_pool_account                           = 'svc_sp_app_pool',
  $sp_app_pool_password                          = 'vagrant',
  $sp_services_account                           = 'svc_sp_services',
  $sp_services_password                          = 'vagrant',
  $sp_search_account                             = 'svc_sp_search',
  $sp_search_password                            = 'vagrant',
  $sp_super_reader_account                       = 'svc_sp_sreader',
  $sp_super_user_account                         = 'svc_sp_susr',
  $sp_crawl_account                              = 'svc_sp_crawl',
  $sp_crawl_password                             = 'vagrant',
  $sp_sync_account                               = 'svc_sp_sync',
  $sp_sync_password                              = 'vagrant',
  $sp_usr_prf_account                            = 'svc_sp_usr_prf',
  $sp_usr_prf_password                           = 'vagrant',
  $sp_excel_account                              = 'svc_sp_excel',
  $sp_excel_password                             = 'vagrant',

  ## Log
  $log_compress                                  = true,
  $iis_logs_path                                 = 'C:\SPLOGS\IIS',
  $uls_logs_path                                 = 'C:\LOGS\ULS',
  $usage_logs_path                               = 'C:\LOGS\USAGE',
  
  ###DefaultWebApp
  $remove_default_web_app                        = false,
  $web_app_url                                   = "https://${::fqdn}",
  $application_pool                              = 'SharePointDefault_App_Pool',
  $web_app_name                                  = 'SharePoint Default Web App',
  $web_app_port                                  = 443,
  $web_app_database_name                         = 'Content_SharePointDefault',
  
  ##DefaultSiteCol
  $site_url                                      = 'https://localhost',
  $site_col_name                                 = 'WebSite',
  $site_col_template                             = 'STS#0',
  $site_col_time24                               = true,
  $site_col_lcid                                 = 1033,
  $site_col_locale                               = 'en-us',
  $site_col_owner                                = 'Administrator',
  
  $mysite_host                                   = undef,
  $mysite_managed_path                           = 'personal',

  $computer_name                                 = $::hostname,

  # Mandatory
  $setup_account_password,
  $pass_phrase,
  $sp_farm_account,
  $sp_farm_password,
){

  # TODO: validate base_path has no last trailing slash.
  validate_re(
    $sp_version,
    '^(Foundation|Standard|Enterprise)$',
    'valid values for mode are \'Foundation\' or \'Standard\' or \'Enterprise\''
  )

  if(empty($sp_path)){
    fail('sp_path cannot be empty.')
  }

    $base_accounts_to_check = [
    $sp_farm_account,
    $sp_app_pool_account,
    $sp_services_account,
    $sp_search_account,
    $sp_crawl_account,
    $sp_super_reader_account,
    $sp_super_user_account,
  ]

  case $sp_version {
    'Foundation': {$other_accounts_to_check = []}
    'Standard':   {$other_accounts_to_check = [$sp_sync_account, $sp_usr_prf_account]}
    'Enterprise': {$other_accounts_to_check = [$sp_sync_account, $sp_usr_prf_account, $sp_excel_account]}
    default: {fail('sp_version must be one of: Foundation, Standard, Enterprise.')}
  }

  $all_accounts_to_check = concat($base_accounts_to_check, $other_accounts_to_check)
  $accounts_are_specified = reduce($all_accounts_to_check, true) |$memo, $entry| {
      $memo and ($entry =~ String[1])
  }
  if(!$accounts_are_specified) {
    fail('Some required accounts are not specified.')
  }

  if($auto_admin_logon and empty($setup_account_password)){
    fail('If auto_admin_logon is set to true, then setup_account_password must not be empty.')
  }

  if(empty($db_server)){
    fail('db_server must not be empty.')
  }

  if($db_alias == true and empty($db_alias_instance)){
    fail('If db_alias is true, then db_alias_instance must not be empty.')
  }
  if(empty($site_col_owner)){
    fail('site_col_owner cannot be empty')
  }

  if($sp_version != 'Foundation' and empty($key)){
    fail('Key (serial number) cannot be empty unless sp_version is Foundation.')
  }

  if(empty($pass_phrase)){
    fail('Pass_phrase cannot be empty.')
  }

  if(
    $central_admin_port < 1023
    or $central_admin_port > 32767
    or $central_admin_port == 443
    or $central_admin_database == 80
  ) {
    fail('central_admin_port must be > 1023, < 32767, and != [443, 80].')
  }

  class{'windows_sharepoint::prepsp':}
  class{'windows_sharepoint::stage_bin':}
  class{'windows_sharepoint::install':}

  anchor{'windows_sharepoint::begin':} ->
  Class['windows_sharepoint::prepsp'] ->
  Class['windows_sharepoint::stage_bin'] ->
  Class['windows_sharepoint::install'] ->
  anchor{'windows_sharepoint::end':}

}
