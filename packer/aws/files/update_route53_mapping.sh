#!/bin/bash

source /home/elastic/es/functions.sh

# This script will look up the value of the "Name" tag
#  and associate the dynamically assigned public hostname
#  with that Name tag value + .sa.elastic.co
# This makes it so that you don't need to associate an elastic IP
# NOTE: You have to call the tag "Name" and not "name" or "NAME"
#  because the AWS CLI filters interface is case sensitive

echo "Begin update_route53_mapping.sh" 

# The zone ID was assigned by infra team so just hardcoding it here
HOSTED_ZONE_ID="Z1NX9AB6R0TE36"
SA_DOMAIN="sa.elastic.co"
TTL=30
INSTANCE_ID=$(ec2metadata | grep 'instance-id:' | cut -d ' ' -f 2)
PUBLIC_HOSTNAME=$(ec2metadata | grep 'public-hostname:' | cut -d ' ' -f 2)
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}')

# Sometimes instance metadata doesn't quite exist yet so we'll wait for the
#  Name tag to exist before we load the rest of the metadata
NAME_TAG_VALUE=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=Name" --region=$REGION --output=text | cut -f5)
while [ -z "$NAME_TAG_VALUE" ]; do
    echo "ERROR: empty \"Name\" tag value for instance ID $INSTANCE_ID, retrying"
    NAME_TAG_VALUE=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=Name" --region=$REGION --output=text | cut -f5)
done

NO_DNS_UPDATE_TAG_VALUE=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=NO_DNS_UPDATE" --region=$REGION --output=text | cut -f5)
ENV_TAG_VALUE=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=env" --region=$REGION --output=text | cut -f5)

# Since we need the Name tag in AWS to have -dev | -staging | -prod at the end
#  for the AWS console to be useful, we want to chop that part off and instead
#  use a subdomain of .dev.sa.elastic.co etc.
short_hostname=$(echo $NAME_TAG_VALUE | sed -e 's/-dev$//g' | sed -e 's/-staging$//g' | sed -e 's/-prod$//g')

# We only want to update the DNS entry if they don't have the NO_DNS_UPDATE
#  tag set.  They might do this for example if they want to associate the
#  DNS entry to an ELB for example.
if [ -z "$NO_DNS_UPDATE_TAG_VALUE" ]; then
    cat << EOF > /tmp/update_route53_mapping.json
{
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "$short_hostname.$ENV_TAG_VALUE.$SA_DOMAIN",
        "Type": "CNAME",
        "TTL" : $TTL,
        "ResourceRecords": [
          {"Value": "$PUBLIC_HOSTNAME"}
        ]
      }
    }
  ]
}
EOF

    retry_run_cmd "aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch file:///tmp/update_route53_mapping.json"
    check_run_cmd "rm -f /tmp/update_route53_mapping.json"

    echo "Successfully associated instance $INSTANCE_ID with public hostname $PUBLIC_HOSTNAME to DNS CNAME for $short_hostname.$ENV_TAG_VALUE.$SA_DOMAIN"
else
    echo "NO_DNS_UPDATE tag was set, skipping route53 update for $INSTANCE_ID"
fi

# Update the syste hostname
check_run_cmd "hostnamectl set-hostname $short_hostname.$ENV_TAG_VALUE.$SA_DOMAIN"

# Update /etc/resolv.conf to search our domain
check_run_cmd "echo \"search $ENV_TAG_VALUE.$SA_DOMAIN\" >> /etc/resolv.conf"
check_run_cmd "echo \"search $SA_DOMAIN\" >> /etc/resolv.conf"

exit 0
