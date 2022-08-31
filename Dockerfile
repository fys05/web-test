FROM nginx
COPY ./www /usr/share/nginx/www
COPY ./default.conf /etc/nginx/conf.d/default.conf
