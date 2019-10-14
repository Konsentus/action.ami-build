# action.ami-build

A GitHub action to deploy an AMI using Packer.

## Available tasks

### Validate

This task will take in a packer .json configuration file and run ```packer validate "${INPUT_CONFIG}"```.

#### Inputs

1. task - validate
1. config - name of the Packer configuration file, this file is expected to be stored in the root level of the git repo.

#### Outputs

None.

#### Example

```yaml
- name: Validate configuration
  uses: konsentus/action.ami-build@master
    with:
      task: validate
      config: packer.json
```

### Build

This task will take in a packer .json configuration file and run ```packer build "${INPUT_CONFIG}"``` created on the AWS account with ID AWS_ACCOUNT_ID.

#### Inputs

1. task - build
1. config - name of the Packer configuration file, this file is expected to be stored in the root level of the git repo.

#### Outputs

1. ami-id - The ami id of the created image is available for export.

#### Example

```yaml
- name: Build configuration
  id: build
  uses: konsentus/action.ami-build@master
  with:
    task: build
    config: packer.json
  env:
    AWS_ACCOUNT_ID: {AWS account ID for assuming role}
```

### Verify

This task verifies that the created ami is present in AWS

#### Inputs

1. task - verify
1. ami_id - This input should be pulled from the previous build action.

#### Outputs

#### Example

```yaml
- name: Verify creation
  uses: konsentus/action.ami-build@master
  with:
    task: verify
    ami_id: ${{ steps.build.outputs.ami-id }}
```

### Share With Org

This task shares the created AMI with a comma separated list of AWS Account IDs who you would like to have access to the AMI.

#### Inputs

1. task - share-with-org
1. ami_id - This input should be pulled from the previous build action.
1. aws_shared_account_ids - Comma separated list of AWS Account IDs.

#### Outputs

None.

#### Example

```yaml
- name: Share ami with other accounts
  uses: konsentus/action.ami-build@master
  with:
    task: share-with-org
    ami_id: ${{ steps.build.outputs.ami-id }}
    aws_shared_account_ids: 123456789101,123456789102
```

## Set Up

## Useful commands

### Running locally for testing

```shell
docker build -t action.ami-build:latest . && \
  docker run \
  -e INPUT_CONFIG=packer.json \
  -e INPUT_TASK=build \
  -e AWS_ACCESS_KEY_ID={AWS_ACCESS_KEY_ID} \
  -e AWS_SECRET_ACCESS_KEY={AWS_SECRET_ACCESS_KEY} \
  -e AWS_REGION={region} \
  -e AWS_ACCOUNT_ROLE={aws IAM role for assume role} \
  -e AWS_ACCOUNT_ID={AWS account ID for assuming role} \
  --workdir "/github/workspace" --rm -v "{path to cloned git repo}":"/github/workspace" action.ami-build:latest
```

```shell
docker build -t action.ami-build:latest . && \
  docker run \
  -e INPUT_CONFIG=packer.json \
  -e INPUT_TASK=share-with-org \
  -e INPUT_AMI_ID={created ami id} \
  -e INPUT_AWS_SHARED_ACCOUNT_IDS={comma seperated aws account id} \
  -e AWS_ACCESS_KEY_ID={AWS_ACCESS_KEY_ID} \
  -e AWS_SECRET_ACCESS_KEY={AWS_SECRET_ACCESS_KEY} \
  -e AWS_REGION={region} \
  -e AWS_ACCOUNT_ROLE=deploy \
  -e AWS_ACCOUNT_ID={aws IAM role for assume role} \
  --workdir "/github/workspace" --rm -v "{path to cloned git repo}":"/github/workspace" action.ami-build:latest
```
