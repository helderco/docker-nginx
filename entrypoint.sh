#!/bin/bash
set -e

DEFAULT_VHOST=/etc/nginx/sites-enabled/default.conf

# If you provide your own virtual host file, exit now
if [ -f $DEFAULT_VHOST ]; then
  exec "$@"
fi

: ${CONF_APP:=default}
: ${CONF_PROJECT:=$CONF_APP}
: ${CONF_SOCKET:=$CONF_PROJECT}

# Find app name based on link alias convention (i.e: <app_name>_app)
if [ "$CONF_APP" = "default" ]; then
  app=$(env | grep -e '_APP_NAME=' | head -n1 | sed -E 's/^(.*)_APP_NAME=.*$/\1/')
  link_alias="${app}_APP"
  [ ! -z "$app" ] && CONF_APP=${app,,}
fi

# If not socket found, try standard ports for a default tcp upstream
if [ -z $CONF_UPSTREAM ] && [ ! -f /var/run/${CONF_SOCKET}.sock ]; then
  ports=( 9000 )
  for port in "${ports[@]}"; do
    test_port="${CONF_APP^^}_APP_PORT_${port}_TCP_PORT"
    if [ ! -z ${!test_port} ]; then
      CONF_UPSTREAM="${CONF_APP}_app:$port"
      break
    fi
  done
fi

# Default root to nginx welcome message
if [ -z $CONF_ROOT ] && [ ! -d /usr/src/app ]; then
  CONF_ROOT=/usr/share/nginx/html
fi

# Find all context variables (starting with CONF_)
vars=()
for variable in $(set -o posix; set | grep '^CONF_' | cut -d= -f1); do
  value=${!variable}
  variable=${variable,,}
  vars+=("${variable#conf_}='$value'")
done
vars=$(IFS=, ; echo "${vars[*]}")

# Use jinja to create our default.conf vhost based on context
python2 > $DEFAULT_VHOST <<- SCRIPT
from jinja2 import Environment, FileSystemLoader
env = Environment(loader=FileSystemLoader('/etc/nginx/templates'))
template = env.get_template('vhost/${CONF_APP}')
print template.render($vars)
SCRIPT

exec "$@"
