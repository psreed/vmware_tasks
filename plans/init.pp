plan vmware_tasks(
  String $function       = '',
  String $config_content = '',
  # Note: Bolt/Puppet/Ruby doesn't expand '~', but we can use the ENV HOME instead
  String $config_file    =  "${system::env('HOME')}/.vmware_tasks.config.json"
) {

  # Read configuration, prefer direct passed config, fallback to read local file.
  if ($config_content != '') {
    $config = $config_content
  } elsif (file::readable($config_file)) {
    $read_config = run_plan('vmware_tasks::config_read_from_disk', { 'config_file'   => $config_file, '_catch_errors' => true })
    if (convert_to($read_config.type,String) =~ 'bolt/plan-failure') { $config = {} } else { $config = $read_config }
  } else {
    $config = {}
    out::message("###################\n## WARNING! \n## Config file is empty. Please run 'Configuration Setup' before running other plans! \n#####################") #lint:ignore:140chars
  }

  log::debug("Current Configuration: \n${config}\n")

  #Build Menu
  if ($function == '') {
    if ($config.has_key('vsphere_api_key'))
    {
      $menu=[
        'Set Configuration',
        'Authorize with vSphere',
        'List VMs',
        'Restart a VM',
        'Enable SSH Access on VCSA'
      ]
    } elsif ($config.has_key('vsphere_host')) {
      $menu=['Set Configuration','Authorize with vSphere']
    } else {
      $menu=['Set Configuration']
    }

    out::message("\nMenu Options:\n")
    $selection = prompt::menu('Select an option', $menu, 'default' => 'Set Configuration')
    out::message("Selected: ${selection}")
  } else { $selection = $function }

  $result = case $selection {
    'Set Configuration':        { run_plan('vmware_tasks::config_setup', { 'config_file'=>$config_file } )}
    'Authorize with vSphere':   { run_plan('vmware_tasks::auth',         { 'config'=>$config, 'config_file'=>$config_file } )}
    'List VMs':                 { run_plan('vmware_tasks::vm_list',      { 'config'=>$config } )}
    'Restart a VM':             { run_plan('vmware_tasks::vm_restart',   { 'config'=>$config } )}
    'Enable SSH Access on VCSA':{ run_task('vmware_tasks::vcsa_ssh', localhost, {
      'vcsa'                => $config['vsphere_host'],
      'use_insecure_https'  => $config['insecure_ssl_b'],
      'api_key'             => $config['vsphere_api_key'],
      'enable'              => true
    } )}

    default: { }
  }
}
