#!/bin/bash -e
#
# See: http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-using-volumes.html
#
# Make sure both volumes have been created AND attached to this instance !
#
# We do not need a loop counter in the "until" statements below because
# there is a 5 minute limit on the CreationPolicy for this EC2 instance already.

. /home/centos/utils/utils.sh

EC2_INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id || die \"wget instance-id has failed: $?\")
EC2_AVAIL_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone || die \"wget availability-zone has failed: $?\")
EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"
DEVICE=/dev/xvdh
MOUNT_POINT=/mnt/data
MYSQL_DATA_DIR=$MOUNT_POINT/mysql

run_cmd "lvextend -l +100%FREE /dev/atomicos/root"
check_run_cmd "xfs_growfs  /"

echo "Instance ID: $EC2_INSTANCE_ID"
echo "Availability Zone: $EC2_AVAIL_ZONE"
echo "Region: $EC2_REGION"

volume_id=$(docker run --rm -t $(tty &>/dev/null && echo "-i") -e "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" -e "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" -e "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}" -v "$(pwd):/project" mesosphere/aws-cli ec2 describe-volumes --filters Name=tag-value,Values=ctindel-hh-mysql-prod --query 'Volumes[*].[VolumeId, State==`available`]' --output text | grep True | awk '{print $1}' | head -n 1)

echo "Volume ID: $volume_id"

docker run --rm -t $(tty &>/dev/null && echo "-i") -e "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" -e "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" -e "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}" -v "$(pwd):/project" mesosphere/aws-cli ec2 attach-volume --volume-id $volume_id --instance-id $EC2_INSTANCE_ID --device $DEVICE

######################################################################
# Volume /dev/sdh (which will get created as /dev/xvdh on Amazon Linux)

DATA_STATE="unknown"
until [ "${DATA_STATE}" == "attached" ]; do
    echo "Checking if Volume $DEVICE is attached"
  DATA_STATE=$(docker run --rm -t $(tty &>/dev/null && echo "-i") -e "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" -e "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" -e "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}" -v "$(pwd):/project" mesosphere/aws-cli ec2 describe-volumes \
    --region $EC2_REGION \
    --filters \
        Name=attachment.instance-id,Values=$EC2_INSTANCE_ID \
        Name=attachment.device,Values=$DEVICE \
    --query Volumes[].Attachments[].State \
    --output text)
  # There are weird non-printable characters in the string we need to remove
  DATA_STATE=$(echo $DATA_STATE | perl -pe 's/[^\w.-]+//g')
  sleep 5
done

echo "Volume $DEVICE is attached"

# Format /dev/xvdh if it does not contain a partition yet
if [ "$(file -b -s /dev/xvdh)" == "data" ]; then
    echo "Volume $DEVICE is blank, going to fdisk"
    fdisk $DEVICE << EOF
n
p
1


w
EOF

    echo "Volume $DEVICE is blank, creating filesystem"
    retry_run_cmd "mkfs.xfs ${DEVICE}1"
fi

if ! grep ${DEVICE}1 /etc/fstab > /dev/null
then
    echo "${DEVICE}1 $MOUNT_POINT xfs  defaults,pquota,prjquota  0 0" >> /etc/fstab
fi

if [ ! -d "$MOUNT_POINT" ]; then
    check_run_cmd "install -d -m 700 $MOUNT_POINT"
fi

check_run_cmd "mount $MOUNT_POINT"

if [ ! -d "$MYSQL_DATA_DIR" ]; then
    check_run_cmd "mkdir -p $MYSQL_DATA_DIR"
fi

echo "Mysql data directory mounted at $MYSQL_DATA_DIR"
