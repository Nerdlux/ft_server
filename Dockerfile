# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: jruiz-ro <jruiz-ro@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/07/07 08:26:40 by jruiz-ro          #+#    #+#              #
#    Updated: 2020/07/13 12:09:59 by jruiz-ro         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

	#Crear la imagen: docker build -t "nombre" .
	#Iniciar contenedor: docker container run -d -p 80:80 -p 443:443 --name="prueba" test
	#Shell del docker: docker exec -it <nombre> bash
	#Install Server
	#Install MySQL
	#Installar PHP
	#Modulos PhP mas utilizados
	#Libreria certificados SSL
	#Install Make
	#Install GoLang for SSL
	#Install curl to download wordpress
#Aconsejan correr nginx con daemon off:
#For Docker containers (or for debugging),
#the daemon off; directive tells Nginx to stay in the foreground.
#For containers this is useful as best practice is for one container = one process.
#One server (container) has only one service.

FROM debian:buster

RUN apt-get update \
	&& apt-get -y install wget \
	&& apt-get -y install apt-utils \
	&& apt-get -y install nginx \
	&& apt-get -y install mariadb-server \
	&& apt-get -y install php-fpm php-mysql \
	&& apt-get -y install php-mbstring php-zip \
	php-gd php-xml php-pear php-gettext php-cgi \
	&& apt-get -y install libnss3-tools \
	&& apt-get -y install make \
	&& apt-get -y install golang \
	&& apt-get -y install curl

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
COPY srcs/default /etc/nginx/sites-available/default
RUN rm /etc/nginx/sites-enabled/default && \
	ln -s /etc/nginx/sites-available/default etc/nginx/sites-enabled/

COPY srcs/phpMyAdmin-5.0.1-all-languages var/www/html/phpmyadmin
COPY srcs/config.inc.php var/www/html/phpmyadmin/config.inc.php
RUN chmod 775 var/www/html/phpmyadmin/config.inc.php && chown -R www-data:www-data /var/www/html/phpmyadmin
COPY srcs/phpmyadmin.sql ./

COPY srcs/wordpress tmp/wordpress
RUN mkdir /var/www/html/wordpress
RUN chown -R www-data:www-data /var/www/html/wordpress
RUN cp -a /tmp/wordpress/. /var/www/html/wordpress
RUN cd /var/www/html

COPY srcs/mkcert-1.0.0 /tmp/mkcert-1.0.0
RUN cd /tmp/mkcert-1.0.0 && make
RUN cd /tmp/mkcert-1.0.0/bin && chmod +x mkcert
RUN cd /tmp/mkcert-1.0.0/bin && cp mkcert /usr/bin/
RUN mkcert -install && mkcert localhost

COPY srcs/index.html /var/www/html

EXPOSE 80 443

RUN chmod -R 777 var/www/html/wordpress

ENTRYPOINT service php7.3-fpm start && service mysql start && mysql -u root < phpmyadmin.sql && service nginx start && sleep infinity && wait && bash
