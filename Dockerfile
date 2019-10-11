FROM hashicorp/packer:1.4.3

RUN apk add --no-cache jq
RUN apk add --no-cache python3
RUN pip3 install awscli
RUN pip3 install boto3

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
