FROM registry.access.redhat.com/ubi8/ubi
COPY run.sh /
ENTRYPOINT ["/run.sh"]
