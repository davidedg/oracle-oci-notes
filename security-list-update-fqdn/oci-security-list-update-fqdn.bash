#!/bin/bash

set -e

# This requires OCI policy:
#
#Allow dynamic-group Instance-OCI1 to inspect security-lists in tenancy
#Allow dynamic-group Instance-OCI1 to manage security-lists in tenancy
#
# and a Dynamic Group with the matching OCID of the instance calling this script


# FQDN to permit - only 1 IP allowed
DYNDNS='dynamic.dyndns.org'
# OCID of Security List to modify
SECURITY_LIST_ID='ocid1.securitylist.oc1.....' # insert your own
# Description of the Rule - used to identify which rule to modify
RULEDESCID='DynamicDNSIdentifier'

##########################################################################

# Resolve the Dynamic FQDN to an IP address
NEW_IP="$(dig +short $DYNDNS)/32"

# Get current ingress rules json
OLD_RULES_JSON=$(oci --auth instance_principal network security-list get --security-list-id $SECURITY_LIST_ID --query 'data."ingress-security-rules"' --output json)



# Find current permitted IP
OLD_IP=$(echo "$OLD_RULES_JSON" | jq -r --arg RULEDESCID "$RULEDESCID" '.[] | select(.description==$RULEDESCID) | .source') #'
echo "Current permitted IP: $OLD_IP"

if [[ "$NEW_IP" == "$OLD_IP" ]]; then
  echo "IP not changed - $NEW_IP"
  exit
fi

echo "New permitted IP:     $NEW_IP"

# Replace the new IP in the json structure
NEW_RULES_JSON=$(echo "$OLD_RULES_JSON" | jq --arg RULEDESCID "$RULEDESCID" --arg NEW_IP "$NEW_IP" 'map(if .description == $RULEDESCID then .source = $NEW_IP else . end)') #'


# Update the security list
oci --auth instance_principal network security-list update --security-list-id $SECURITY_LIST_ID --ingress-security-rules "$NEW_RULES_JSON" --force
