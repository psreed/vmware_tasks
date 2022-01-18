plan vmware_tasks::auth(
  String $vsphere_host = '',
  String $vsphere_api_keyfile = '~/.vsphere_api_key',
  Boolean $allow_insecure_ssl = false
){

  #Setup curl command as a variable for secure/insecure SSL
  if ($allow_insecure_ssl) { $curl='/usr/bin/curl -k' } else { $curl='/usr/bin/curl' }

  #Prompt for vsphere user secure password
  $host = prompt('vSphere Host', 'default' => $vsphere_host)
  $vsphere_user = prompt('vSphere Username', 'default' => 'administrator@vsphere.local')
  $vsphere_password = prompt('vSphere Password', 'sensitive' => true)

  # Base64 encode the user/password combination for Basic Auth
  # Must use run_task instead of run_command in order to preserve sensitive types
  $b64_encoded = run_task('vmware_tasks::base64', localhost, {
    'input_string' => "${vsphere_user}:${vsphere_password.unwrap}"
  })

  if ($b64_encoded[0].status == 'success') {

    # Use curl to grab the API Key
    $curl_result = run_command("${curl} -s -X POST -H \"Authorization: Basic ${b64_encoded[0].value['_output'].strip()}\" https://${host}/api/session",
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
        #$result = write_file($api_key, $vsphere_api_keyfile, localhost)
        $result = run_command("echo -n ${api_key} > ${vsphere_api_keyfile}", localhost, "Writing API key to ${vsphere_api_keyfile}")
        if ($result[0].status == 'success') {
          out::message("API Key successfully retrieved and written to file: ${vsphere_api_keyfile}")
        } else {
          fail_plan("Failed to write API key to file ${vsphere_api_keyfile}")
        }
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
