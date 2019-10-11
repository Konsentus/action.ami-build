# template.action
Basic template repo for Github actions

Please provide at a minimum the following sections:
1. Introduction to what the action is for
2. "How to use" guide for using the action in a workflow (providing lightweight examples is recommended)

docker build -t action.ami-build:latest . && docker run -e INPUT_TASK=validate --work-dir "/github/workspace" --rm -v "/Users/jonmoss/projects/ami.service":"/github/workspace"

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


org - 584000169098