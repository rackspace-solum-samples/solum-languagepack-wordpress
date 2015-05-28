#
# Solum Java Language Pack
#

# Pull base image.
FROM php:5.6-apache

#set up mod rewrite for apache
RUN a2enmod rewrite

# install the PHP extensions we need
RUN apt-get update && apt-get install -y libpng12-dev libjpeg-dev && rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-install gd

# set the volume to wordpress source code
VOLUME /var/www/html

# set some needed versions (default it to 4.2.2) 
ENV WORDPRESS_VERSION 4.2.2
ENV WORDPRESS_UPSTREAM_VERSION 4.2.2
ENV WORDPRESS_SHA1 d3a70d0f116e6afea5b850f793a81a97d2115039

# upstream tarballs include ./wordpress/ so this gives us /usr/src/wordpress
RUN curl -o wordpress.tar.gz -SL https://wordpress.org/wordpress-${WORDPRESS_UPSTREAM_VERSION}.tar.gz \
	&& echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c - \
	&& tar -xzf wordpress.tar.gz -C /usr/src/ \
	&& rm wordpress.tar.gz \
	&& chown -R www-data:www-data /usr/src/wordpress

COPY docker-entrypoint.sh /entrypoint.sh

# grr, ENTRYPOINT resets CMD now
ENTRYPOINT ["/entrypoint.sh"]
#run apache2 as foreground
CMD ["apache2-foreground"]