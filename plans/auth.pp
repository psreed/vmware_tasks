plan vmware_tasks::auth(
#  String $vsphere_host = '',
#  String $vsphere_api_keyfile = '~/.vsphere_api_key',
#  Boolean $allow_insecure_ssl = false
  Hash $config,
  String $config_file
){

  #Setup curl command as a variable for secure/insecure SSL
  #if ($config['insecure_ssl']=~'(?i)true') { $curl='/usr/bin/curl -k' } else { $curl='/usr/bin/curl' }

  log::debug("Config in plan 'auth': ${config}")

  #Prompt for vsphere user secure password
  $host = prompt('vSphere Host', 'default' => $config['vsphere_host'])
  $vsphere_user = prompt('vSphere Username', 'default' => $config['vsphere_user'])
  $vsphere_password = prompt('vSphere Password', 'sensitive' => true)

  # Base64 encode the user/password combination for Basic Auth
  # Must use run_task instead of run_command in order to preserve sensitive types
  $b64_encoded = run_task('vmware_tasks::base64', localhost, {
    'input_string' => "${vsphere_user}:${vsphere_password.unwrap}"
  })

  if ($b64_encoded[0].status == 'success') {

    # Use curl to grab the API Key
    $curl_result = run_command("${config['curl']} -s -X POST -H \"Authorization: Basic ${b64_encoded[0].value['_output'].strip()}\" https://${host}/api/session",
      localhost,
      'Retrieving API Key from vSphere Host',
      {'_catch_errors'=>true}
    )

    if ($curl_result[0].status == 'success') {
      # Validate the key
      $api_key=$curl_result[0].value['stdout'].strip().regsubst("^\"|\"$",'','G')
      if ($api_key =~ 'error') {
        fail_plan("API Key authentication failed. Check username and password. \n ${api_key}\n")
      }
      if ($api_key != '') {
        #write the key out to the specified file for further use
        run_plan('vmware_tasks::config_write_to_disk', {
          'config'=>merge($config,{'vsphere_api_key'=>$api_key}),
          'config_file'=>$config_file
        })
      } else {
        fail_plan('Could not parse output from vsphere host.')
      }
    } else {
      if ($curl_result[0].value['exit_code']==60) {
        fail_plan('Authorization call to vSphere API Failed. SSL certificate problem: unable to get local issuer certificate. (maybe try \'allow_insecure_ssl\'?)') #lint:ignore:140chars
      } else {
        #out::message($curl_result[0])
        fail_plan('Authorization call to vSphere API Failed. Check vSphere host, username and password.')
      }
    }

  } else {
    fail_plan('Failed to parse Base64 encoded vsphere_user:vsphere_password string.')
  }
}
