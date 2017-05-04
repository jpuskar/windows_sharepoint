##
# This ressource can add and remove sitecollection on sharepoint
# 
##
define windows_sharepoint::sitecollection(
  $ensure                 = 'present',
  $sitecolurl             = '',
  $sitecolname            = '',
  $sitecoltemplate        = 'STS#0',
  $owneralias             = '',
  $lcid                   = '1033',
  $contentdatabase        = '',
  $description            = 'SiteCol Description',
){
  validate_re($ensure, '^(present|absent)$', 'valid values for mode are \'present\' or \'absent\'')
  if(empty($sitecolurl)){
    fail('You need to specify an url for the sitecollection')
  }
  if(empty($sitecolname)){
    fail('You need to specify a name for the sitecollection')
  }
  if(empty($owneralias)){
    fail('You need to specify the owneralias for the sitecollection')
  }
  if(empty($description)){
    fail('You need to specify a description for the sitecollection')
  }
 if($ensure == present){

   $cmd_create_site_col = @("END_CMD_CREATE_SITE_COL"/$)
      Add-PSSnapin 'Microsoft.SharePoint.PowerShell' -ea SilentlyContinue;
      \$new_sp_site_params = @{};
      \$new_sp_site_params.Add("Name","${sitecolname}");
      \$new_sp_site_params.Add("Url","${sitecolurl}");
      \$new_sp_site_params.Add("OwnerAlias","${owneralias}");
      \$new_sp_site_params.Add("Description","${description}");
      \$new_sp_site_params.Add("Template","${sitecoltemplate}");
      If('${contentdatabase}' -eq '') {
       \$new_sp_site_params.Add("ContentDatabase","${contentdatabase}");
      };
      New-SPSite @new_sp_site_params;
      | END_CMD_CREATE_SITE_COL

    $cmd_onlyif_create_site_col = @("END_CMD_ONLYIF_CREATE_SITE_COL"/$)
      If((Test-Path "HKLM:\\SOFTWARE\\AutoSPInstaller\\") -eq \$true) {
        If((Get-ItemProperty -Path "HKLM:\\SOFTWARE\\AutoSPInstaller\\" -ErrorAction SilentlyContinue).PuppetSharePointInstallInProgress -eq '1') {
          Exit 1;
        } Else {
          Add-PSSnapin 'Microsoft.SharePoint.PowerShell' -ErrorAction SilentlyContinue;
          \$getspsite = Get-SPSite -Identity '${sitecolurl}' -ErrorAction SilentlyContinue;
          If(\$null -eq \$getspsite) {exit 0;}else{exit 1;}
        }
      } Else {
        Add-PSSnapin 'Microsoft.SharePoint.PowerShell' -ea SilentlyContinue;
        \$getspsite = Get-SPSite -Identity '${sitecolurl}' -ErrorAction SilentlyContinue;
        If(\$getspsite -eq \$null){Exit 0;}Else{Exit 1;}
      }
      | END_CMD_ONLYIF_CREATE_SITE_COL

    exec{"sitecol_create_{sitecolname}":
      command => $cmd_create_site_col,
      provider => "powershell",
      onlyif   => $cmd_onlyif_create_site_col,
      timeout  => "1200",
    }
  } else {

   $cmd_sitecol_remove_params = @("END_CMD_SITECOL_REMOVE_PARAMS"/$)
   \$sitecolurl = "${sitecolurl}";
   END_CMD_SITECOL_REMOVE_PARAMS

   $onlyif_sitecol_remove_frag = @(END_ONLYIF_SITECOL_REMOVE_FRAG)
     If((Test-Path "HKLM:\SOFTWARE\AutoSPInstaller\") -eq $true) {
       If((Get-ItemProperty -Path "HKLM:\SOFTWARE\AutoSPInstaller\" -ErrorAction SilentlyContinue).PuppetSharePointInstallInProgress -eq '1') {
         Exit 1;
       } Else {
         Add-PSSnapin 'Microsoft.SharePoint.PowerShell' -ea SilentlyContinue;
         $getspsite = Get-SPSite -Identity $sitecolurl -ErrorAction SilentlyContinue;
         If($getspsite -eq $null) {Exit 1;}
       }
     } Else {
       Add-PSSnapin 'Microsoft.SharePoint.PowerShell' -ErrorAction SilentlyContinue;
       $getspsite = Get-SPSite -Identity $sitecolurl -ErrorAction SilentlyContinue;
       If($getspsite -eq $null){ Exit 1; }
     }
     | END_ONLYIF_SITECOL_REMOVE_FRAG
   $onlyif_sitecol_remove = "${cmd_sitecol_remove_params}; ${onlyif_sitecol_remove_frag}"

    exec{"sitecol_remove_${sitecolname}":
      command => "Add-PSSnapin 'Microsoft.SharePoint.PowerShell' -ea SilentlyContinue;Remove-SPSite -Identity '${sitecolurl}' -Confirm:\$false -GradualDelete",
      provider => "powershell",
      onlyif   => $onlyif_sitecol_remove,
      timeout  => "600",
    }
  }
}