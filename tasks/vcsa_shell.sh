#!/bin/sh
#Task to enable/disable VCSA Shell Access

APIKEY=`cat $PT_vcsa_api_key_file`
echo "Using APIKEY ${APIKEY} from ${PT_vcsa_api_key_file}"

if [ ! -z "${APIKEY}" ]; then 

    CMD="curl -k -v -X GET -H \"vmware-api-session-id: ${APIKEY}\" https://${PT_vcsa}/api/appliance/access/shell"
    RESULT=$(eval $CMD)
    echo "Result before operation: $RESULT"

    if [ "${PT_enable}" = "true" ]; then 
        echo "Enabling VCSA Shell..."
        CMD="/usr/bin/curl"
        if [ "${PT_use_insecure_https}" = "true" ]; then CMD="${CMD} -k"; fi
        CMD="${CMD} -X PUT"
        CMD="${CMD} -H \"vmware-api-session-id: ${APIKEY}\""
        CMD="${CMD} -H \"Content-Type: application/json\""
        CMD="${CMD} -d '{\"enabled\":true,\"timeout\":${PT_timeout}}'"
        CMD="${CMD} https://${PT_vcsa}/api/appliance/access/shell"
        RESULT=$(eval $CMD)
    fi

    if [ "${PT_enable}" = "false" ]; then 
        echo "Disabling VCSA Shell..."
        CMD="/usr/bin/curl"
        if [ "${PT_use_insecure_https}" = "true" ]; then CMD="${CMD} -k"; fi
        CMD="${CMD} -X PUT"
        CMD="${CMD} -H \"vmware-api-session-id: ${APIKEY}\""
        CMD="${CMD} -H \"Content-Type: application/json\""
        CMD="${CMD} -d '{\"enabled\":false,\"timeout\":0}'"
        CMD="${CMD} https://${PT_vcsa}/api/appliance/access/shell"
        RESULT=$(eval $CMD)
    fi

    CMD="curl -k -v -X GET -H \"vmware-api-session-id: ${APIKEY}\" https://${PT_vcsa}/api/appliance/access/shell"
    RESULT=$(eval $CMD)
    echo "Result after operation: $RESULT"

else
  echo "Could not retrieve APIKEY from ${PT_vcsa_api_key_file}"
fi