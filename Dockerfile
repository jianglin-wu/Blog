FROM nginx:alpine
COPY ./public /usr/nginx/www/html
EXPOSE 80
