FROM hashicorp/packer:1.4.3

LABEL "com.github.actions.name"="ami-build"
LABEL "com.github.actions.description"="build and ami using packer"
LABEL "com.github.actions.icon"="check-square"
LABEL "com.github.actions.color"="blue"

RUN apk add --no-cache jq
RUN apk add --no-cache python3
RUN pip3 install awscli
RUN pip3 install boto3

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
