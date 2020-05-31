FROM centos:7

LABEL version="1.0" description="Imagem do freeradius integrado ao AD" maintainer="Ana Amarante anapma22@gmail.com"

ENV TZ America/Fortaleza
ENV SUPERVISOR_VERSION=4.0.2

RUN \
  rpm --rebuilddb && yum clean all; \
  yum install -y epel-release; \
  yum update -y; \
  yum install -y \
  python-setuptools \
  net-tools \
  freeradius \
  freeradius-utils \
  freeradius-krb5 \
  krb5-workstation \
  samba \
  samba-client \
  samba-winbind \
  samba-winbind-clients \
  samba-common \
  samba-common-tools \
  realmd sssd sssd-krb5 oddjob oddjob-mkhomedir adcli ntpdate ntp \
  vim tzdata && \
  yum clean all && rm -rf /tmp/yum*; \
  easy_install pip; \
  pip install supervisor==${SUPERVISOR_VERSION}

COPY entrypoint.sh /usr/local/bin/ 
RUN chmod +x /usr/local/bin/entrypoint.sh 

COPY supervisord.conf /etc/supervisord.conf

VOLUME ["/data"]

WORKDIR /etc/raddb

EXPOSE 1812/udp 1813/udp

ENTRYPOINT ["entrypoint.sh"]
