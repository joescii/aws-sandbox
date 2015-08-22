#!/bin/bash

# Applies the terraform configuration to AWS

: ${AWS_ACCESS_KEY_ID:?"Must supply AWS_ACCESS_KEY_ID environment variable"}
: ${AWS_SECRET_ACCESS_KEY:?"Must supply AWS_SECRET_ACCESS_KEY environment variable"}
: ${AWS_DEFAULT_REGION:?"Must supply AWS_DEFAULT_REGION environment variable"}
: ${TF_STATE_BUCKET:?"Must supply TF_STATE_BUCKET environment variable (The S3 bucket to store terraform state)"}
: ${TF_STATE_KEY:?"Must supply TF_STATE_KEY environment variable (The S3 key to store terraform state)"}

# Create a timestamp for uniquefying stuff
timestamp=`date +"%Y%m%d%H%M%S"`

# Install terraform
mkdir terraform
cd terraform
wget https://dl.bintray.com/mitchellh/terraform/terraform_0.6.3_linux_amd64.zip
unzip terraform_0.6.3_linux_amd64.zip
cd ..

dos2unix *.tf

tf=./terraform/terraform

configureRemoteState () {
  ${tf} remote config \
    -backend=S3 \
    -backend-config="bucket=${TF_STATE_BUCKET}" \
    -backend-config="key=${TF_STATE_KEY}" 
}

# The first time you run this script, the following terraform configuration will report an error.
# No need to worry. It's only because you don't yet have state saved in S3.
configureRemoteState

remoteConfigStatus=$?
  
if [ ${remoteConfigStatus} -ne 0 ]; then
  echo "Configuration of remote state failed, most likely because it doesn't yet exist. Turning it off for now..."
  ${tf} remote config -disable
fi
  
${tf} apply \
  -var "access_key=${AWS_ACCESS_KEY_ID}" \
  -var "secret_key=${AWS_SECRET_ACCESS_KEY}" \
  
if [ ${remoteConfigStatus} -ne 0 ]; then
  echo "Turning remote state back on and pushing to S3..."
  configureRemoteState
  ${tf} remote push
fi
