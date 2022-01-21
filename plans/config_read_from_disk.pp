# Plan to read configuration from file on localhost
#@api private
plan vmware_tasks::config_read_from_disk(
  String $config_file
) {
  if (file::readable($config_file)) {
    $config_in=file::read($config_file)
  } else {
    fail_plan("Could not read config file: ${config_file}")
  }

  $config_keys=$config_in.split(' \*\* ')[0].split('\|\|')
  $config_values=$config_in.split(' \*\* ')[1].split('\|\|')
  $config = Hash($config_keys.map | Integer $idx, String $value | { [$value, $config_values[$idx]] }.flatten)

  #add extra config
  if ($config['insecure_ssl']=~'(?i)true') {
    $extra_config_curl='/usr/bin/curl -k'
    $extra_config_insecure_ssl_b = true
  } else {
    $extra_config_curl = '/usr/bin/curl'
    $extra_config_insecure_ssl_b = false
  }

  $extra_config = {
    'curl'           => $extra_config_curl,
    'insecure_ssl_b' => $extra_config_insecure_ssl_b
  }
  return merge($config,$extra_config)
}
