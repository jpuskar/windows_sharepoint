##
# This class put files and directory in basepath/Puppet-SharePoint
# 
##
class windows_sharepoint::prepsp(
  $base_path                    = $windows_sharepoint::base_path,
  $language_pack_spath          = $windows_sharepoint::language_packs_path,
  $updates_path                 = $windows_sharepoint::updates_path,
  $sp_path                      = $windows_sharepoint::sp_path,
  $sp_version                   = $windows_sharepoint::sp_version,
  $autospinstaller_pkg_ensure   = $windows_sharepoint::autospinstaller_pkg_ensure,
  $autospinstaller_pkg_name     = $windows_sharepoint::autospinstaller_pkg_name,
  $autospinstaller_pkg_source   = $windows_sharepoint::autospinstaller_pkg_source,
  $autospinstaller_pkg_provider = $windows_sharepoint::autospinstaller_pkg_provider,
  $setacl_pkg_ensure            = $windows_sharepoint::setacl_pkg_ensure,
  $setacl_pkg_name              = $windows_sharepoint::setacl_pkg_name,
  $setacl_pkg_source            = $windows_sharepoint::setacl_pkg_source,
  $setacl_pkg_provider          = $windows_sharepoint::setacl_pkg_provider,
  $setacl_install_dir           = $windows_sharepoint::setacl_pkg_provider,
) {

  $new_base_path = "${base_path}/Puppet-SharePoint"
  file{ $new_base_path:
    ensure => 'directory',
  }

  if(!empty($language_packs_path)){
    exec{'copy_language_packs':
      command => " \
\$lps = get-item '${language_packs_path}\\*'; \
\$base = '${new_base_path}/2013/LanguagePacks'; \
foreach(\$lp in \$lps){ \
 \$destination = \$base + '/' + \$lp.Name; \
 \$source = \$lp.FullName + '/*'; \
 if((test-path \$destination) -eq \$false){ \
  New-Item -Path \$base -Name \$lp.Name -type Directory; \
  Copy-Item -Path \$source -Destination \$destination -Force -Recurse; \
 } \
}",
      provider => 'powershell',
      onlyif   => " \
\$lps = get-item '${language_packs_path}\\*'; \
if(\$lps -ne \$null){ \
 \$base = '${new_base_path}/2013/LanguagePacks'; \
 \$exist='false';\
 foreach(\$lp in \$lps){ \
  \$destination = \$base + '\\' + \$lp.Name; \
  \$source = \$lp.FullName + '/*'; \
  if((test-path \$destination) -eq \$true){\$exist = 'true'} \
 }; \
 if(\$exist -eq 'true'){exit 1;} \
} else {exit 1;}",
      timeout  => '600',
    }
  }

  package{$autospinstaller_pkg_name:
    ensure   => $autospinstaller_pkg_ensure,
    source   => $autospinstaller_pkg_source,
    provider => $autospinstaller_pkg_provider,
  } ->
  exec {'extract_auto_sp_installer':
    command  => 'Copy-Item -Recurse c:/Scripts/AutoSPInstaller/* C:/Puppet-SharePoint',
    provider => 'powershell',
    unless   => 'If(Test-Path "C:/Puppet-SharePoint/AutoSPInstaller"){Exit 0;} Else {Exit 1;}',
  }

  package{$setacl_pkg_name:
    ensure   => $setacl_pkg_ensure,
    source   => $setacl_pkg_source,
    provider => $setacl_pkg_provider,
  } ->
  exec {'copy_setacl':
    command  => "Copy-Item \"${setacl_install_dir}/setacl.exe\" C:/windows",
    provider => 'powershell',
    unless   => 'If(Test-Path "C:\windows\setacl.exe") {Exit 0;} Else {Exit 1;}'
  }

  $cmd_copy_updates_params = @("END_CMD_COPY_UPDATES_PARAMS"/$)
    \$updates_path = "${updates_path}";
    \$new_base_path = "${new_base_path}";
    | END_CMD_COPY_UPDATES_PARAMS

  $cmd_copy_updates_frag = @(END_CMD_COPY_UPDATES_FRAG)
    $source = $updates_path + '/*';
    $destination = $new_base_path + '/2013/Updates';
    Copy-Item -Path $source -Destination $destination -Force -Recurse;
    | END_CMD_COPY_UPDATES_FRAG
  $cmd_copy_updates = "${cmd_copy_updates_params}; ${cmd_copy_updates_frag};"

  $onlyif_copy_updates_frag = @(END_ONLYIF_COPY_UPDATES_FRAG)
    $lps = Get-Item ($updates_path + '/*');
    If($lps -ne $null) {
      $base = $new_base_path + '/2013/Updates';
      $exist = 'false';
      Foreach($lp in $lps) {
        $destination = $base + '/' +$lp.Name;
        If((Test-Path $destination) -eq $true) {
          $exist = 'true';
        }
      };
      If($exist -eq 'true'){Exit 1;}
    } Else { Exit 1; }
    | END_ONLYIF_COPY_UPDATES_FRAG
  $onlyif_copy_updates = "${cmd_copy_updates_params}; ${onlyif_copy_updates_frag};"

  if(!empty($updates_path)){
    exec{'copy_updates':
      command  => $cmd_copy_updates,
      provider => 'powershell',
      onlyif   => $onlyif_copy_updates,
      timeout  => '600',
    }
  }

  if(!empty($language_packs_path) and !empty($updates_path)) {
    Exec['copy_language_packs'] ~> Exec['copy_updates']
  }

}
