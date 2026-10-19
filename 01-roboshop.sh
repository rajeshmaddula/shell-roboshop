#!/bin/bash

SG_ID="sg-0574b9e33f7cce2ef"
AMI_ID="ami-0055977a6e828a4f4"

for instance in $@
do
INSTANCE_ID=$(aws ec2 run-instances 
        --image-id $AMI_ID \
        --instance-type t3.micro \
        --security-group-ids $SG_ID \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
        --query 'Instances[0].InstanceId' \
        --output text)

        if [ $instance == frontend ]; then
           IP=$(
            aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \  
            --query 'Reservations[].Instances[].PublicIpAddress' \   
            --output text
            )
        else
        IP=$(
            aws ec2 describe-instances 
            --instance-ids $INSTANCE_ID \   
            --query 'Reservations[].Instances[].PrivateIpAddress' \   
            --output text
            )
        fi

        echo "IP address: $IP"
done

