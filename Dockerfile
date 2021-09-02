FROM registry.fedoraproject.org/fedora:34
RUN dnf install -y findutils
COPY run.sh /
ENTRYPOINT ["/run.sh"]
