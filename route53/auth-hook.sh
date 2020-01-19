#!/bin/bash
#
# 30 2 * * * certbot renew --post-hook "service nginx reload"
#

export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""

#CERTBOT_DOMAIN="example.com"
#CERTBOT_VALIDATION="TEST"
ACTION="UPSERT"

printf -v QUERY 'HostedZones[?Name == `%s.`]|[?Config.PrivateZone == `false`].Id' "${CERTBOT_DOMAIN}"
HOSTED_ZONE_ID="$(aws route53 list-hosted-zones --query "${QUERY}" --output text)"

aws route53 change-resource-record-sets \
--hosted-zone-id "${HOSTED_ZONE_ID}" \
--change-batch "{
  \"Changes\": [{
    \"Action\": \"${ACTION}\",
    \"ResourceRecordSet\": {
      \"Name\": \"_acme-challenge.${CERTBOT_DOMAIN}.\",
      \"ResourceRecords\": [{\"Value\": \"\\\"${CERTBOT_VALIDATION}\\\"\"}],
      \"Type\": \"TXT\",
      \"TTL\": 30
    }
  }]
}"

# Sleep to make sure the change has time to propagate over to DNS
sleep 25
