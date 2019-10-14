#!/bin/bash -l

## Standard ENV variables provided
# ---
# GITHUB_ACTION=The name of the action
# GITHUB_ACTOR=The name of the person or app that initiated the workflow
# GITHUB_EVENT_PATH=The path of the file with the complete webhook event payload.
# GITHUB_EVENT_NAME=The name of the event that triggered the workflow
# GITHUB_REPOSITORY=The owner/repository name
# GITHUB_BASE_REF=The branch of the base repository (eg the destination branch name for a PR)
# GITHUB_HEAD_REF=The branch of the head repository (eg the source branch name for a PR)
# GITHUB_REF=The branch or tag ref that triggered the workflow
# GITHUB_SHA=The commit SHA that triggered the workflow
# GITHUB_WORKFLOW=The name of the workflow that triggerdd the action
# GITHUB_WORKSPACE=The GitHub workspace directory path. The workspace directory contains a subdirectory with a copy of your repository if your workflow uses the actions/checkout action. If you don't use the actions/checkout action, the directory will be empty

# for logging and returning data back to the workflow,
# see https://help.github.com/en/articles/development-tools-for-github-actions#logging-commands
# echo ::set-output name={name}::{value}
# -- DONT FORGET TO SET OUTPUTS IN action.yml IF RETURNING OUTPUTS

# exit with a non-zero status to flag an error/failure
# exit 1 - Failure result thats expected
# exit 2 - Failure to work correctly

build_config() {
  echo "Task build starting."

  OUTPUT=$(packer build "${INPUT_CONFIG}")
  CODE=$?
  echo "${OUTPUT}"
  if [ "${CODE}" -eq "0" ]; then
    echo "pulling ami id from manifest"
    ami_id=$(cat manifest.json | jq '.builds[1].artifact_id' | cut -d ":" -f2 | tr -d \")
    echo ::set-output name=ami_id::"${ami_id}"
    exit 0
  else
    echo "Build not completed sucessfully. exited with code ${CODE}."
    exit 2
  fi
}

check_config() {
  if [ -z "$1" ] || [ ! -f "$1" ]; then
    echo "Configuration file does not exist or is not a file."
    exit 2
  fi
}

assume_role() {
  echo "Assuming role"
  CREDS=$(aws sts assume-role --role-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${AWS_ACCOUNT_ROLE}" --role-session-name ami-builder --output json)

  export AWS_ACCESS_KEY_ID
  export AWS_SECRET_ACCESS_KEY
  export AWS_SESSION_TOKEN
  export AWS_DEFAULT_REGION=${AWS_REGION}

  AWS_ACCESS_KEY_ID=$(jq -r .Credentials.AccessKeyId <<< ${CREDS})
  AWS_SECRET_ACCESS_KEY=$(jq -r .Credentials.SecretAccessKey <<< ${CREDS})
  AWS_SESSION_TOKEN=$(jq -r .Credentials.SessionToken <<< ${CREDS})
}

if [ -z "${INPUT_TASK}" ]; then
  echo "Task not defined."
  exit 2
fi

if [ "${INPUT_TASK}" == "validate" ]; then
  check_config "${INPUT_CONFIG}"
  echo "Task validate starting."
  packer validate "${INPUT_CONFIG}"
  exit $?
fi

if [ "${INPUT_TASK}" == "build" ]; then
  assume_role
  check_config "${INPUT_CONFIG}"
  build_config
fi

if [ "${INPUT_TASK}" == "verify" ]; then
  assume_role
  echo "Task verify starting."
  echo "${INPUT_AMI_ID}"
  aws ec2 describe-images --image-id "${INPUT_AMI_ID}"
  exit $?
fi

if [ "${INPUT_TASK}" == "share-with-org" ]; then
  assume_role
  echo "Task share-with-org starting."
  image_attribute_string=""
  # Building a string of form {UserId=111111111111},{111111111112}
  # First without the comma e.g. {UserId=111111111111}{111111111112}
  for account_id in $(echo "${INPUT_AWS_SHARED_ACCOUNT_IDS}" | sed "s/,/ /g")
    do
      image_attribute_string+="{UserId=${account_id}}"
    done
  # Find replace }{ with },{
  image_attribute_string=$(echo "${image_attribute_string}" | sed 's/}{/},{/g')

  aws ec2 modify-image-attribute --image-id "${INPUT_AMI_ID}" --launch-permission "Add=[${image_attribute_string}]"
  exit $?
fi