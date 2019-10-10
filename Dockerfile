FROM alpine:latest

ADD entrypoint.sh /entrypoint.sh

RUN apk add --no-cache bash

ENTRYPOINT ["/entrypoint.sh"]
