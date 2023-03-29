FROM nginx

RUN apt-get update -qq && apt-get -y install apache2-utils

ENV RAILS_ROOT /app
WORKDIR $RAILS_ROOT

RUN mkdir log

COPY public public/
COPY docker/nginx/enable_sites.conf /tmp/enable_sites.nginx
RUN envsubst '$RAILS_ROOT' < /tmp/enable_sites.nginx > /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD [ "nginx", "-g", "daemon off;" ]
