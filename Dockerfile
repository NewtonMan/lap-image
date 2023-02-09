FROM --platform=linux/amd64 ubuntu/apache2:latest
ARG DEBIAN_FRONTEND=noninteractive
USER root
RUN apt-get update && \
    apt-get install -y unzip vim net-tools apache2 wget curl lsb-release ca-certificates apt-transport-https software-properties-common gnupg2 varnish memcached redis redis-server sudo imagemagick libapache2-mod-php8.1 php8.1 php8.1-curl php8.1-mbstring php8.1-xml php8.1-pdo php8.1-pdo-mysql php8.1-mysql php8.1-dev php8.1-zip php8.1-imagick ffmpeg libapache2-mod-security2 unixodbc-dev odbc-postgresql tdsodbc
#RUN cd /tmp && wget https://github.com/coreruleset/coreruleset/archive/v3.3.0.zip && sha1sum v3.3.0.zip && echo ProvidedChecksum && unzip v3.3.0.zip && mv coreruleset-3.3.0/crs-setup.conf.example /etc/modsecurity/crs-setup.conf && mv coreruleset-3.3.0/rules/ /etc/modsecurity/ && find /etc/modsecurity/
#    echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' | tee /etc/apt/sources.list.d/newrelic.list && \
#    wget -O- https://download.newrelic.com/548C16BF.gpg | tee /etc/apt/trusted.gpg.d/newrelic.asc
# RUN apt-get update && \
#     apt install -y sudo imagemagick libapache2-mod-php8.1 php8.1 php8.1-curl php8.1-mbstring php8.1-xml php8.1-pdo php8.1-pdo-mysql php8.1-mysql php8.1-dev php8.1-zip php8.1-imagick ffmpeg
# RUN NR_INSTALL_SILENT=1 newrelic-install install && \
#     sed -i -e "s/REPLACE_WITH_REAL_KEY/646a26effc70b3e91f1e2ac8668e1c6cab05NRAL/" \
#   -e "s/newrelic.appname[[:space:]]=[[:space:]].*/newrelic.appname=\"website\"/" \
#   $(php -r "echo(PHP_CONFIG_FILE_SCAN_DIR);")/newrelic.ini
# RUN curl -Ls https://download.newrelic.com/install/newrelic-cli/scripts/install.sh | bash && NEW_RELIC_API_KEY=NRAK-SXUIMJXK8NKX7EDAPGM441PW9KJ NEW_RELIC_ACCOUNT_ID=3651834 /usr/local/bin/newrelic install -n logs-integration
# COPY ./scripts/* /root/
# RUN sh /root/odbc18-install.sh
# RUN echo "IncludeOptional /etc/modsecurity/*.conf" >> /etc/apache2/mods-enabled/security2.conf && \
#     echo "Include /etc/modsecurity/rules/*.conf" >> /etc/apache2/mods-enabled/security2.conf
RUN wget https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_amd64.deb && \
    dpkg -i mod-pagespeed-*.deb && \
    a2enmod pagespeed && \
    a2dismod pagespeed && \
    a2dismod mpm_event && \
    a2dismod security2 && \
#    sed -i 's/IncludeOptional \/usr\/share\/modsecurity-crs\/owasp-crs.load/# IncludeOptional \/usr\/share\/modsecurity-crs\/owasp-crs.load/g' /etc/apache2/mods-enabled/security2.conf && \
    a2enmod mpm_prefork && \
    a2enmod php8.1 && \
    a2enmod cache && \
    a2enmod cache_disk && \
    a2enmod expires && \
    a2enmod headers && \
    pecl install sqlsrv && pecl install pdo_sqlsrv && \
    printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/8.1/mods-available/sqlsrv.ini  && \
    printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/8.1/mods-available/pdo_sqlsrv.ini && \
    phpenmod -v 8.1 sqlsrv pdo_sqlsrv && \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer
# RUN sed -i 's/Listen 80/Listen 8080/g' /etc/apache2/ports.conf && \
#     a2dissite 000-default.conf && \
#     rm -rf /etc/apache2/sites-available/000-default.conf
RUN a2dissite 000-default.conf && \
    rm -rf /etc/apache2/sites-available/000-default.conf
#RUN sed -i 's/ulimit -l/#ulimit -l/g' /etc/init.d/varnish
#RUN sed -i 's/-a :6081/-a :80/g' /etc/default/varnish
COPY ./www /
RUN cp -r /vhosts /var/www/vhosts
COPY ./apache/conf/* /etc/apache2/conf-available/
COPY ./apache/vhosts/* /etc/apache2/sites-available/
RUN for site in `ls /etc/apache2/sites-available/`; do a2ensite $site; done
EXPOSE 80
