FROM rockylinux:9-minimal
RUN microdnf update -y
RUN microdnf upgrade \
  --refresh \
  --best \
  --nodocs \
  --noplugins \
  --setopt=install_weak_deps=0
RUN microdnf \
  --refresh \
  --best \
  --nodocs \
  --noplugins \
  --setopt=install_weak_deps=0 install curl sudo sed dnf findutils jq grep -y
RUN microdnf \
  --refresh \
  --best \
  --nodocs \
  --noplugins \
  --setopt=install_weak_deps=0 install rpmfusion-free-release -y
RUN curl "https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-8.noarch.rpm" > rpmfusion-nonfree.rpm
RUN rpm -ivh rpmfusion-nonfree.rpm; rm rpmfusion-nonfree.rpm
RUN microdnf \
  --refresh \
  --best \
  --nodocs \
  --noplugins \
  --setopt=install_weak_deps=0 install 'dnf-command(config-manager)' -y
RUN dnf config-manager --set-enabled crb
RUN curl -s https://weewx.com/yum/weewx-el9.repo| sed 's;gpgcheck=1;gpgcheck=0;g' > /etc/yum.repos.d/weewx.repo
RUN microdnf \
  --refresh \
  --best \
  --nodocs \
  --noplugins \
  --setopt=install_weak_deps=0 install weewx-5.2.0-1.el9 python3-paho-mqtt python3-mysqlclient httpd python3 python3-pip shadow-utils rsync wget openssh-clients -y
RUN pip install ephem
RUN echo "[Logging]" >> /etc/weewx/weewx.conf
RUN echo "  [[root]]"  >> /etc/weewx/weewx.conf
RUN echo "    level = INFO" >> /etc/weewx.conf
RUN echo "    handlers = console," >> /etc/weewx/weewx.conf
RUN cat /etc/weewx/weewx.conf
RUN usermod -s /bin/bash weewx
#RUN rm /etc/httpd/conf.d/ssl.conf
RUN sed 's;Listen 80;Listen 8080;g' -i /etc/httpd/conf/httpd.conf
RUN sed 's;ServerName localhost:80;ServerName localhost:8080;g' -i /etc/httpd/conf/httpd.conf
RUN sed 's;ErrorLog "logs/error_log";ErrorLog /dev/stdout;g' -i /etc/httpd/conf/httpd.conf
RUN sed 's;    CustomLog "logs/access_log" combined;    CustomLog /dev/stdout combined;g' -i /etc/httpd/conf/httpd.conf
ARG TIMESTAMP
RUN echo "Build time: $TIMESTAMP"
RUN weectl extension install https://github.com/gss2002/weewx-mqtt/archive/refs/heads/master.zip -y
RUN weectl extension install https://github.com/gss2002/weewx-exfoliation/archive/refs/heads/master.zip -y
RUN weectl extension install https://github.com/gss2002/weewx-forecast/archive/refs/heads/master.zip -y
USER weewx
CMD ['weewxd', '/etc/weewx/weewx.conf']
