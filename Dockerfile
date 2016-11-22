FROM alpine:edge
MAINTAINER gilley.joel@gmail.com

# docker run -d --name {container_name} -e VIRTUAL_HOST={virtual_hosts} -v /data/sites/{domain_name}:/DATA gilleyj/alpine-php7fpm"

# if edge libraries are needed use the following:
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

# Install our packages
# bash - debugging/login and I like bash
# ca-certificates 
# curl - used for downloading wp-cli
# nginx - http service
# supervisor - MY Prefered way of running this mess
# php_pack (et.al.) the list of PHP7-fpm modules needed to run
# mysql-client - needed to talk to DB
# forced cleanup of any cached apk files (incase --no-cache doesn't do what it needs to)
# call update-ca-certificates 
RUN	apk --update --no-cache add \
	--virtual .base_pack bash ca-certificates curl \
	--virtual .service_pack nginx supervisor \
	--virtual .php_pack \
	php7-fpm \
	php7-apcu \
	php7-bcmath \
	php7-ctype \
	php7-curl \
	php7-dom \
	php7-exif \
	php7-gd \
	php7-iconv \
	php7-intl \
	php7-json \
	php7-mcrypt \
	php7-mysqli \
	php7-opcache \
	php7-openssl \
	php7-pdo \
	php7-pdo_mysql \
	php7-phar \
	php7-session \
	php7-xml \
	php7-xmlreader \
	php7-zlib \
	mysql-client && \
	rm -rf /var/cache/apk/* && \
	update-ca-certificates

# our container confs
ENV DB_HOST="mariadb" \
	DB_NAME="wp_database" \
	DB_USER="wp_user"\
	DB_PASS="wp_password" \
	VIRTUAL_HOST="wordpress.site"

# Add the files
COPY container_confs /

# Add the www-data user and group, fail on error
RUN set -x ; \
	addgroup -g 82 -S www-data ; \
	adduser -u 82 -D -S -G www-data www-data && exit 0 ; exit 1 

# The following things are not really needed
#	sed -i -e 's/display_errors = Off/display_errors = On/g' /etc/php7/php.ini && \
# 	sed -i "s/nginx:x:100:101:nginx:\/var\/lib\/nginx:\/sbin\/nologin/nginx:x:100:101:nginx:\/DATA:\/bin\/bash/g" /etc/passwd && \
#   sed -i "s/nginx:x:100:101:nginx:\/var\/lib\/nginx:\/sbin\/nologin/nginx:x:100:101:nginx:\/DATA:\/bin\/bash/g" /etc/passwd- && \
#
# Turn off fix path info
# php to log to stdio device
# select php-fpm7 as default
# select php7 as default
# make sure our PID directories exist
# www-data user owns data and php-pid
# nginx/www-data owns nginx-pid
# add group/user read write permissions to data
# make sure our entrypoint is executable

RUN	sed -i -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php7/php.ini && \
	sed -i -e 's/;error_log = php_errors.log/error_log = \/proc\/self\/fd\/1/g' /etc/php7/php.ini && \
	ln -s /sbin/php-fpm7 /sbin/php-fpm && \
	ln -s /usr/bin/php7 /usr/bin/php && \
	mkdir -p /run/php /run/nginx /run/supervisord && \
	chown -R www-data:www-data /run/php /DATA && \
	chown -R nginx:www-data /run/nginx && \
	chmod -R ug+rw /DATA && \
	chmod +x /entrypoint.sh

# download the wp-cli
# move it to /usr/bin
# make it executable
# make www-data the owner
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	mv wp-cli.phar /usr/bin/wp-cli && \
	chmod +x /usr/bin/wp-cli && \
	chown www-data:www-data /usr/bin/wp-cli

# expose the port
EXPOSE 80

# expose the app volume
VOLUME ["/DATA"]

# the entry point definition
ENTRYPOINT ["/entrypoint.sh"]

# default command for entrypoint.sh
CMD ["supervisord"]


# docker run -d --name nginxproxy -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock -t gilleyj/alpine-nginx-proxy
# docker run --name mariadb -e MYSQL_ROOT_PASSWORD=password -d mariadb
# docker run -d --link mariadb --name wp_justa.com -v $(pwd)/container_confs/DATA:/DATA -e VIRTUAL_HOST=justa.com gilleyj/alpine-php7fpm


# docker run -d --link mariadb --name poop -v $(pwd)/container_confs/DATA:/DATA -e VIRTUAL_HOST=wpt.chegg gilleyj/alpine-php7fpm