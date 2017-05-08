##
# This class stages sharepoint binaries.
#
##
class windows_sharepoint::stage_bin(
  $base_path           = $windows_sharepoint::base_path,
  $language_packs_path = $windows_sharepoint::language_packs_path,
  $updates_path        = $windows_sharepoint::updates_path,
  $sp_path             = $windows_sharepoint::sp_path,
  $sp_version          = $windows_sharepoint::sp_version,
  $stage_prereqs       = false,
  $prereq_archive_path = 'c:\\install_files\\foundation\\prerequisiteinstallerfiles',
) {

  if($sp_version == 'Foundation') {
      if $stage_prereqs {
        $prereq_files = hiera_hash('windows_sharepoint::prereq_files', {} )
        $prereq_files.each |$file, $file_properties| {
          archive::artifactory {$file:
            archive_path => $prereq_archive_path,
            extract      => false,
            cleanup      => false,
            url          => $file_properties[url], # lint:ignore:variable_scope
          }
        }
        exec{'copy_sp':
          command  => 'Copy-Item -Recurse C:\\install_files\\foundation C:\\Puppet-SharePoint\\2013',
          provider => 'powershell',
          onlyif   => "if((test-path '${base_path}\\Puppet-SharePoint\\2013\\foundation\\setup.exe') -eq \$true){exit 1}",
          timeout  => '600',
          require  => Archive::Artifactory[keys($prereq_files)],
        }
      }
    else {
        exec{'copy_sp':
          command  => 'Copy-Item -Recurse C:\\install_files\\foundation C:\\Puppet-SharePoint\\2013',
          provider => 'powershell',
          onlyif   => "if((test-path '${base_path}\\Puppet-SharePoint\\2013\\foundation\\setup.exe') -eq \$true){exit 1}",
          timeout  => '600',
        }
    }
  } else {
      windows_isos{'SPStandard':
        ensure  => present,
        isopath => $sp_path,
        xmlpath => "${base_path}\\Puppet-SharePoint\\isos.xml",
      } ->
      file{"${base_path}\\Puppet-SharePoint\\spcopy.ps1":
        content => template('windows_sharepoint/prepsp-server.erb'),
      } ->
      exec{'extract_sp':
        command  => "${base_path}\\Puppet-SharePoint\\spcopy.ps1;",
        provider => 'powershell',
        onlyif   => "if((test-path '${base_path}\\Puppet-SharePoint\\2013\\SharePoint\\setup.exe') -eq \$true){exit 1}",
        timeout  => '600',
      }
  }
}
