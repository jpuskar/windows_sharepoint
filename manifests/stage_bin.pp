##
# This class stages sharepoint binaries.
#
##
class windows_sharepoint::stage_bin(
  $basepath          = $basepath,
  $languagepackspath = $languagepackspath,
  $updatespath       = $updatespath,
  $sppath            = $sppath,
  $spversion         = $spversion,
) {

  if($spversion == 'Foundation') {
    exec{'extract_sp':
      command => " \
\$ErrorActionPreference = 'Stop'; \
write-output \"username: \$env:username \"; \
Start-Process '${sppath}' -ArgumentList '/extract:C:\\Puppet-SharePoint\\2013\\Foundation /q' -Wait",
      provider => 'powershell',
      onlyif   => "if((test-path '${basepath}\\Puppet-SharePoint\\2013\\Foundation\\setup.exe') -eq \$true){exit 1}",
      timeout  => '600',
    }
  } else {
      windows_isos{'SPStandard':
        ensure   => present,
        isopath  => $sppath,
        xmlpath  => "${basepath}\\Puppet-SharePoint\\isos.xml",
      } ->
      file{"$basepath\\Puppet-SharePoint\\spcopy.ps1":
        content => template('windows_sharepoint/prepsp-server.erb'),
      } ->
      exec{'extract SP':
        command => "$basepath\\Puppet-SharePoint\\spcopy.ps1;",
        provider => 'powershell',
        onlyif   => "if((test-path '${basepath}\\Puppet-SharePoint\\2013\\SharePoint\\setup.exe') -eq \$true){exit 1}",
        timeout  => '600',
      }
  }
}
