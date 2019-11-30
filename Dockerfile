FROM centos:7
LABEL Description="This image contains Zerotier One and ztncui" Vendor="Key Networks (https://key-networks.com)"
ADD VERSION .

COPY build.sh /usr/bin/
RUN build.sh

EXPOSE 80/tcp
EXPOSE 443/tcp

COPY exec.sh /usr/sbin/
ENTRYPOINT ["/usr/sbin/exec.sh"]
