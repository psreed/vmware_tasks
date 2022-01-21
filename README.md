# vmware_tasks

## Plans:

### vmware_tasks

just run `bolt plan run vmware_tasks` for a menu of options. 

1. run the setup option to create a local config file 
2. run the authentication option to update the local config with a usable session key
3. run the other plans that will show up in the list after an API key is available
4. if plans fail, try re-authenticating (likely your session has expired)