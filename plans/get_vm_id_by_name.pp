# @api private
plan vmware_tasks::get_vm_id_by_name(
  Hash $config,
  String $vm_name,
) {

  $cmd = "${config['curl']} -s -H \"vmware-api-session-id: ${config['vsphere_api_key']}\" https://${config['vsphere_host']}/api/vcenter/vm?names=${vm_name}"
  $result = run_command($cmd,localhost,'Getting list of VMs',{'_catch_errors'=>true})
  if ($result.ok) {
    return $result[0].value['stdout']
    #TODO: Parse this output and return just the vm id instead of the whole object
  }
  return 0
}
