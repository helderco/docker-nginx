FROM ubuntu:14.04
MAINTAINER Helder Correia <me@heldercorreia.com>

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C300EE8C
RUN echo "deb http://ppa.launchpad.net/nginx/stable/ubuntu trusty main" >> /etc/apt/sources.list

ENV NGINX_VERSION 1.8.0-1+trusty1

RUN apt-get update && \
    apt-get install -y ca-certificates nginx-extras=${NGINX_VERSION} && \
    rm -rf /var/lib/apt/lists/*

RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME ["/var/cache/nginx"]

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
