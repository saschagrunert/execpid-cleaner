FROM alpine
RUN apk add --no-cache bash findutils
COPY run.sh /
ENTRYPOINT ["/run.sh"]
