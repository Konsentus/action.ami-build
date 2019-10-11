FROM hashicorp/packer:1.4.3

ADD entrypoint.sh /entrypoint.sh

RUN apk add --no-cache jq
RUN apk add --no-cache aws-cli

ENTRYPOINT ["/entrypoint.sh"]
