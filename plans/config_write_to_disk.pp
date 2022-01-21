#Plan to write configuration to disk on localhost
#@api private
plan vmware_tasks::config_write_to_disk(
  String $config_file,
  Hash $config
) {

  out::message("Writing config to disk on localhost, file: ${config_file}")
  #out::message($config)

  $out_keys = $config.map |$key,$value| { $key }
  $out_values = $config.map |$key,$value| { $value }
  $outfiledata="${out_keys.join('||')} ** ${out_values.join('||')}"
  #out::message($outfiledata)
  file::write($config_file,$outfiledata)

}
