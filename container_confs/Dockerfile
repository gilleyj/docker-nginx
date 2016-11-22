FROM alpine:edge
MAINTAINER gilley.joel@gmail.com

LABEL   devoply.type="site" \
        devoply.cms="wordpress" \
        devoply.framework="wordpress" \
        devoply.language="php7" \
        devoply.require="gilleyj/nginx-proxy gilleyj/mariadb" \
        devoply.recommend="redis" \
        devoply.description="nginx php7.0-fpm deployed with wordpress-cli." \
        devoply.name="WordPress" \
        devoply.params="docker run -d --name {container_name} -e VIRTUAL_HOST={virtual_hosts} -v /data/sites/{domain_name}:/DATA gilleyj/alpine-php7fpm"


# if edge libraries are needed use the following:
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

# install base packages - BASH should only be used for debugging, it's almost a meg in size
# install ruby basic packages
# clean up the apk cache (no-cache still caches the indexes)
# Make the app directory
# install the fake sqs gem without docs
RUN	apk --update --no-cache add \
	--virtual .base_pack bash ca-certificates curl \
	--virtual .nginx_pack nginx \
	--virtual .super_pack supervisor \
	--virtual .php_service \
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
	rm -rf /var/cache/apk/*

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

# I don't know what fix_pathinfo does
# we're going to display errors no we're not 	sed -i -e 's/display_errors = Off/display_errors = On/g' /etc/php7/php.ini && \
# we're going to display to stdio device
RUN	sed -i -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php7/php.ini && \
	sed -i -e 's/;error_log = php_errors.log/error_log = \/proc\/self\/fd\/1/g' /etc/php7/php.ini && \
	ln -s /sbin/php-fpm7 /sbin/php-fpm

# 	sed -i "s/nginx:x:100:101:nginx:\/var\/lib\/nginx:\/sbin\/nologin/nginx:x:100:101:nginx:\/DATA:\/bin\/bash/g" /etc/passwd && \
#   sed -i "s/nginx:x:100:101:nginx:\/var\/lib\/nginx:\/sbin\/nologin/nginx:x:100:101:nginx:\/DATA:\/bin\/bash/g" /etc/passwd- && \

RUN ln -s /usr/bin/php7 /usr/bin/php && \
	mkdir -p /run/php /run/nginx /run/supervisord && \
	chown -R www-data:www-data /run/php /DATA && \
	chown -R nginx:www-data /run/nginx && \
	chmod -R ug+rw /DATA && \
	chmod +x /entrypoint.sh

# install wp-cli
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

# docker run -d --link some-mariadb --name wordpress -v $(pwd)/container_confs/DATA:/DATA -e VIRTUAL_HOST=justa.com gilleyj/alpine-php7fpm

# docker run -d --name nginxproxy -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock -t gilleyj/alpine-nginx-proxy
# docker run --name mariadb -e MYSQL_ROOT_PASSWORD=password -d mariadb
# docker run -d --link mariadb --name wp_justa.com -v $(pwd)/container_confs/DATA:/DATA -e VIRTUAL_HOST=justa.com gilleyj/alpine-php7fpm


# docker run -d --link mariadb --name poop -v $(pwd)/container_confs/DATA:/DATA -e VIRTUAL_HOST=wpt.chegg gilleyj/alpine-php7fpm