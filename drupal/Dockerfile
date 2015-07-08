FROM helder/nginx-dev

COPY etc /etc/nginx
COPY default.conf /etc/nginx/conf.d/

# Fix sendfile issue with Virtualbox
RUN sed -i "/sendfile/d" /etc/nginx/nginx.conf \
 && sed -i "/server_tokens/d" /etc/nginx/nginx.conf
