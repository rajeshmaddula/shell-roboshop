#!/bin/bash

SG_ID="sg-0574b9e33f7cce2ef"
AMI_ID="ami-0055977a6e828a4f4"

 aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type "t3.micro" \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=frontend}]" \
   


