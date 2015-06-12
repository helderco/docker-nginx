FROM helder/nginx:latest
MAINTAINER Helder Correia <me@heldercorreia.com>

# Fix sendfile issue with Virtualbox
RUN sed -i "/sendfile/d" /etc/nginx/nginx.conf \
 && sed -i "/server_tokens/d" /etc/nginx/nginx.conf
