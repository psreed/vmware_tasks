plan vmware_tasks::config_setup(
  String $config_file
) {

  # Get current config values from config file, if there is one.
  $get_config = run_plan('vmware_tasks::config_read_from_disk', { 'config_file'   => $config_file, '_catch_errors' => true })
  if (convert_to($get_config.type,String) =~ 'bolt/plan-failure') { $config = {} } else { $config = $get_config }
  log::debug("Setup: Current Configuration:\n${config}")

  if ($config['vsphere_host']) { $def_vsphere_host = $config['vsphere_host'] } else { $def_vsphere_host='' }
  if ($config['vsphere_user']) { $def_vsphere_user = $config['vsphere_user'] } else { $def_vsphere_user='administrator@vsphere.local' } #lint:ignore:140chars
  if ($config['insecure_ssl']) { $def_insecure_ssl = $config['insecure_ssl'] } else { $def_insecure_ssl=false }
  if (($def_insecure_ssl.type == Type[Boolean] and $def_insecure_ssl==true)
    or ($def_insecure_ssl.type == Type[String] and $def_insecure_ssl=~'(?i)true')
  ) { $def_insecure_ssl_yn='Y' } else {$def_insecure_ssl_yn ='N'}

  $in_vsphere_host = prompt('vSphere Host','default'=>$def_vsphere_host)
  $in_vsphere_user = prompt('vSphere Host','default'=>$def_vsphere_user)
  $in_insecure_ssl_yn = prompt('Use insecure SSL (curl -k option)? [Y/N]','default'=>$def_insecure_ssl_yn)
  if ($in_insecure_ssl_yn =~ '(?i)y') {
    $in_insecure_ssl=true
  } else {$in_insecure_ssl=false}

  out::message("Insecure: ${in_insecure_ssl}")

  $newconfig = {
    'vsphere_host' => $in_vsphere_host,
    'vsphere_user' => $in_vsphere_user,
    'insecure_ssl' => $in_insecure_ssl,
  }

  run_plan('vmware_tasks::config_write_to_disk', { 'config' => $newconfig, 'config_file' =>  $config_file })

}
