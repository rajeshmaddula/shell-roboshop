#!/bin/bash

SG_ID="sg-0574b9e33f7cce2ef"
AMI_ID="ami-0055977a6e828a4f4"
DOMAIN_NAME="raws88s.online"
ZONE="Z06264382S55O9BHSS2H6"

for INSTANCE in $@
do
  INSTANCE_ID=$(
    aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type "t3.micro" \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE}]" \
    --query 'Instances[0].InstanceId' \
    --output text 
  )
   if [ $INSTANCE == frontend ]; then
      IP=$(
         aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text
      
   )
   RECORD_NAME=$DOMAIN_NAME

   IP=$(
         aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[*].Instances[*].PrivateIpAddress' \
    --output text
   )
   RECORD_NAME="$INSTANCE.$DOMAIN_NAME"

   fi

   echo "IP address: $IP"

   aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE \
    --change-batch '
    {
        "Comment": "Updating record",
        "Changes": [
            {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "'$RECORD_NAME'",
                "Type": "A",
                "TTL": 1,
                "ResourceRecords": [
                {
                    "Value": "'$IP'"
                }
                ]
            }
            }
        ]
    }
    '

   echo "record updated for $instance"

  done



