plan vmware_tasks::vm_restart(
  Hash $config
) {

  # Get Inputs
  $vm_name = prompt('VM Name', 'default'=>'galleon.paulreed.ca')

  # Get VM ID
  $vm_id = run_plan(
    'vmware_tasks::get_vm_id_by_name',
    {
      'config' => $config,
      'vm_name' => $vm_name
    }
  )
  out::message($vm_id)

  #$result = run_command("${curl} -s -H \"vmware-api-session-id: ${api_key}\" https://${vhost}/api/vcenter/vm/${vm_id}/power", localhost)
  #out::message($result[0].value['stdout'])


}
