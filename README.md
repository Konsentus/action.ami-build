# action.ami-build

A GitHub action to deploy an AMI using Packer.

## Available tasks

### Validate

This task will take in a packer .json configuration file and run ```packer validate "${INPUT_CONFIG}"```.

#### Inputs

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
    AWS_ACCOUNT_ID: 310407442083
```

### Verify

This task verifies that the created ami is present in AWS

#### Inputs

#### Outputs

#### Example

### Share With Org

#### Inputs

#### Outputs

#### Example

## Set Up

## Useful commands

### Running locally for testing

```shell
docker build -t action.ami-build:latest . && docker run -e INPUT_TASK=validate --work-dir "/github/workspace" --rm -v "/Users/jonmoss/projects/ami.service":"/github/workspace"
```

```shell
docker build -t action.ami-build:latest . && \
  docker run \
  -e INPUT_CONFIG=packer.json \
  -e INPUT_TASK=build \
  -e AWS_ACCESS_KEY_ID=AKIA43NHZYIHO64AVPYW \
  -e AWS_SECRET_ACCESS_KEY=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 \
  -e AWS_REGION=eu-west-2 \
  -e AWS_ACCOUNT_ROLE=deploy \
  -e AWS_ACCOUNT_ID=310407442083 \
  -e AWS_ACCOUNT_ROLE=deploy \
  --workdir "/github/workspace" --rm -v "/Users/jonmoss/projects/ami.services":"/github/workspace" action.ami-build:latest
```

org - 584000169098