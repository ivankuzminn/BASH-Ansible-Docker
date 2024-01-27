FROM ubuntu 
RUN apt update && apt install apache2 apache2-utils -y && apt clean
RUN a2enmod proxy proxy_fcgi
EXPOSE 80
CMD ["apache2ctl", "-D","FOREGROUND"]
