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

# Default subdirs for root
if [ -z $CONF_PUBLIC ]; then
  case "$CONF_APP" in
    django) CONF_PUBLIC=public ;;
    symfony1) CONF_PUBLIC=web ;;
  esac
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
