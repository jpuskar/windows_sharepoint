##
# This class put files and directory in basepath/Puppet-SharePoint
# 
##
class windows_sharepoint::prepsp(
  $basepath          = $basepath,
  $languagepackspath = $languagepackspath,
  $updatespath       = $updatespath,
  $sppath            = $sppath,
  $spversion         = $spversion,
) {
  validate_re($spversion, '^(Foundation|Standard|Enterprise)$', 'valid values for mode are \'Foundation\' or \'Standard\' or \'Enterprise\'')
  if(empty($sppath)){
    fail('You need to specify the sharepoint installation path')
  }

  $new_base_path = "${basepath}\\Puppet-SharePoint"
  file{ $new_base_path:
    ensure => 'directory',
  }

  if(!empty($languagepackspath)){
    exec{'copy_language_packs':
      command => " \
\$lps = get-item '${languagepackspath}\\*'; \
\$base = '${new_base_path}\\2013\\LanguagePacks'; \
foreach(\$lp in \$lps){ \
 \$destination = \$base + '\\' + \$lp.Name; \
 \$source = \$lp.FullName + '/*'; \
 if((test-path \$destination) -eq \$false){ \
  New-Item -Path \$base -Name \$lp.Name -type Directory; \
  Copy-Item -Path \$source -Destination \$destination -Force -Recurse; \
 } \
}",
      provider => 'powershell',
      onlyif   => " \
\$lps = get-item '${languagepackspath}\\*'; \
if(\$lps -ne \$null){ \
 \$base = '${new_base_path}\\2013\\LanguagePacks'; \
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
  
  if(!empty($updatespath)){
    exec{'copy_updates':
      command => "\
\$source = '${updatespath}\\*'; \
\$destination = '${new_base_path}\\2013\\Updates'; \
Copy-Item -Path \$source -Destination \$destination -Force -Recurse;",
      provider => "powershell",
      onlyif   => "\
\$lps = get-item '${updatespath}\\*'; \
if(\$lps -ne \$null){\$base = '${new_base_path}\\2013\\Updates'; \
\$exist='false';foreach(\$lp in \$lps){ \
 \$destination = \$base + '\\' +\$lp.Name; \
 if((test-path \$destination) -eq \$true){\$exist = 'true'; }}; \
 if(\$exist -eq 'true'){exit 1;} \
} else {exit 1;}",
      timeout  => "600",
    }
  }

  if(!empty($languagepackspath) and !empty($updatespath)) {
    Exec['copy_language_packs'] ~> Exec['copy_updates']
  }

}
