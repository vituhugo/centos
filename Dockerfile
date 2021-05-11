FROM centos:7

COPY oracle /oracle

ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
    systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*; \
    yum install -y \
        https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
        https://rpms.remirepo.net/enterprise/remi-release-7.rpm \
        yum-utils \
        libaio &&\
    rpm -i /oracle/oracle-instantclient-basic-21.1.0.0.0-1.x86_64.rpm &&\
    rpm -i /oracle/oracle-instantclient-devel-21.1.0.0.0-1.x86_64.rpm &&\
    rpm -i /oracle/oracle-instantclient-sqlplus-21.1.0.0.0-1.x86_64.rpm &&\
    yum -y install httpd; yum clean all; systemctl enable httpd.service &&\
    sh -c "echo /usr/lib/oracle/21/client64/lib > /etc/ld.so.conf.d/oracle-instantclient.conf" && ldconfig && \
    yum-config-manager --enable remi-php74 &&\
    yum update -y &&\ 
    yum install -y \
        php \
        php-cli \
        php-fpm \
        php-json \
        php-common \
        php-zip \
        php-gd \
        php-mbstring \
        php-curl \
        php-xml \
        php-pear \
        php-bcmath \
		php-oci8 \
		nginx &&\
    yum remove -y httpd &&\
    mkdir -m 777 \
        /run/php-fpm &&\
    yum -y clean all &&\
    rm -rf /var/cache/yum /oracle &&\
    chmod 777 -R \
        /var/www/html \
        /var/log \
        /var/run/php-fpm/ \
        /var/lib/nginx \
        /run &&\
    ln -sf /dev/stdout /var/log/nginx/access.log &&\
    ln -sf /dev/stderr /var/log/nginx/error.log


COPY php.ini /etc/
COPY fpm-www.conf /etc/php-fpm.d/www.conf
COPY nginx-default.conf /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 6600 9000
VOLUME [ "/sys/fs/cgroup" ]

WORKDIR /var/www/html

CMD ["/start.sh"]
