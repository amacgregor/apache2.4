FROM ubuntu:15.04

RUN apt-get update && apt-get install -y apache2 libapache2-mod-proxy-html libapache2-mod-fcgid apache2-mpm-prefork

RUN a2enmod proxy proxy_ajp proxy_http rewrite deflate headers proxy_balancer proxy_connect proxy_html macro xml2enc

COPY ./config/apache2.conf /etc/apache2/apache2.conf
COPY ./config/macro/ /etc/apache2/macro/

ADD ./config/000-docker.conf /etc/apache2/sites-available/
RUN a2dissite *.conf && a2ensite 000-docker.conf

# Set Apache environment variables (can be changed on docker run with -e)
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_SERVERADMIN admin@localhost
ENV APACHE_SERVERNAME localhost
ENV APACHE_SERVERALIAS docker.localhost
ENV APACHE_DOCUMENTROOT /srv/www
ENV VIRTUAL_HOST localhost.com
ENV PHP_FPM_HOST 127.0.0.1
ENV PHP_FPM_PORT 9001

# Restart apache2 because we changed configuration directives
RUN apache2ctl restart

EXPOSE 80 443

ADD start.sh /start.sh
RUN chmod 0755 /start.sh
CMD ["bash", "start.sh"]
