plan vmware_tasks::vm_list(
  Hash $config
) {

  # List VMs
  $cmd = "${config['curl']} -s -H \"vmware-api-session-id: ${config['vsphere_api_key']}\" https://${config['vsphere_host']}/api/vcenter/vm"
  $result = run_command($cmd,localhost,'Getting list of VMs',{'_catch_errors'=>true})

  if ($result.ok) {
    # Make it look good with some 'jq'
    $output = run_command(
      "json_data='${result[0].value['stdout']}'; jq -n \"\$json_data\"",
      localhost,
      "Making output look better with 'jq'"
    )
    out::message($output[0].value['stdout'])
  } else {
    fail_plan("Could not retrieve vm list. Try re-authentication in case session is expired. (Exit Code: ${result[0].value['exit_code']})")
  }

}
