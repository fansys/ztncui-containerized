FROM centos:7
LABEL Description="This image contains Zerotier One and ztncui" Vendor="Key Networks (https://key-networks.com)" Version="1.1"

COPY build.sh /usr/bin/
RUN build.sh

EXPOSE 3443

COPY exec.sh /usr/sbin/
ENTRYPOINT ["/usr/sbin/exec.sh"]
