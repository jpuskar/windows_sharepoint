##
## Microsoft SharePoint Group Resource
## Tested with SharePoint 2013
##

define windows_sharepoint::group(
  $ensure          = 'present',
  $groupname       = '',
  $ownername       = '',
  $member          = '',
  $description     = '',
  $weburl          = '',
  $permissionlevel = '',
){

  validate_re(
    $ensure,
    '^(present|absent)$',
    'valid values for ensure are \'present\' or \'absent\''
  )

  validate_re($permissionlevel,
    '^(Full Control|Edit|Contribute|Read|Design)$',
    'valid values for ensure are \'Full Control\', \'Edit\', \'Contribute\', \'Read\', \'Design\' '
  )

  if(empty($groupname)){
    fail('Group name can\'t be empty')
  }
  if(empty($ownername)){
    fail('Owner name can\'t be empty')
  }
  if(empty($weburl)){
    fail('SPWeb URL need to be provide')
  }
  #if(empty($farmpassword)){
  #  fail('You need to fill the farm password')
  #}

  if($ensure == 'present') {

    $cmd_ensure_sp_group_params = @("END_CMD_ENSURE_SP_GROUP_PARAMS"/$)
      \$owner_name       = "${ownername}";
      \$web_url          = "${weburl}";
      \$permission_level = "${permissionlevel}";
      \$member           = "${member}";
      \$description      = "${description}";
      \$group_name       = "${groupname}";
      | END_CMD_ENSURE_SP_GROUP_PARAMS

    $cmd_ensure_sp_group_frag = @(END_CMD_ENSURE_SP_GROUP_FRAG)
      Add-PSSnapin Microsoft.SharePoint.PowerShell -ea SilentlyContinue;
      $member = $null;
      $description = $null;
      $owner_qual_name = $env:userdomain + "\" + $owner_name;
      $web = Get-SPWeb $web_url;
      $web.AllowUnsafeUpdates = $true;
      If ($member -eq '') {$member = $null};
      If ($description -eq '') {$description = $null};
      $owner = $web | Get-SPUser -identity $owner_qual_name;
      $web.SiteGroups.Add($group_name, $owner, $member, $description);
      $group = $web.SiteGroups[$group_name];
      $web.RoleAssignments.Add($group);
      $roleAssignment = new-object Microsoft.SharePoint.SPRoleAssignment($group);
      $roleDefinition = $web.Site.RootWeb.RoleDefinitions[$permission_level];
      $roleAssignment.RoleDefinitionBindings.Add($roleDefinition);
      $web.RoleAssignments.Add($roleAssignment);
      $web.Update();
      $web.Dispose();
      $web.AllowUnsafeUpdates = $false;
      | END_CMD_ENSURE_SP_GROUP_FRAG
    $cmd_ensure_sp_group = "${cmd_ensure_sp_group_params}; ${cmd_ensure_sp_group_frag}"

    $onlyif_add_spgroup_param = @("END_ONLYIF_ADD_SPGROUP_PARAM"/$)
      \$weburl    = "${weburl}";
      \$groupname = "${groupname}";
      | END_ONLYIF_ADD_SPGROUP_PARAM

    $onlyif_add_spgroup_frag = @(END_ONLYIF_ADD_SPGROUP_FRAG)
      Add-PSSnapin Microsoft.SharePoint.PowerShell -ea SilentlyContinue;
      $site = Get-SPSite $weburl -ErrorAction SilentlyContinue;
      $url = $site.url;
      If($url -eq $weburl){
        If($site.RootWeb.Groups[$groupname] -ne $null) {
          Exit 1;
        };
      };
      | END_ONLYIF_ADD_SPGROUP_FRAG
    $onlyif_add_spgroup = "${onlyif_add_spgroup_param}; ${onlyif_add_spgroup_frag};"

    exec { "add_spgroup_${groupname}":
      provider => powershell,
      command  => $cmd_ensure_sp_group,
      timeout  => 900,
      onlyif   => $onlyif_add_spgroup,
    }
  } elsif($ensure == 'absent'){
  }
}
