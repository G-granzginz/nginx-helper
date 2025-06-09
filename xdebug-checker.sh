#!/bin/bash

# File: xdebug-check.sh
# Usage: bash xdebug-check.sh

PHP_VERSION="8.2"
SOCK_PATH="/run/php/php${PHP_VERSION}-fpm.sock"
XDEBUG_LOG="/var/log/xdebug/xdebug.log"
DEBUG_PORT=9003
DEBUG_HOST="127.0.0.1"

echo "🔍 PHP-FPM Socket: $SOCK_PATH"
if [ -S "$SOCK_PATH" ]; then
    echo "✅ PHP-FPM socket is active."
else
    echo "❌ PHP-FPM socket NOT found."
fi

echo -e "\n🔍 Checking PHP-FPM process user:"
ps -o user:20,pid,cmd -C php-fpm${PHP_VERSION}

echo -e "\n🔍 Xdebug ini loaded in PHP-FPM:"
php-fpm${PHP_VERSION} -i | grep -i xdebug | grep -E "client_host|client_port|log|mode|start_with_request"

echo -e "\n🔍 Checking if port $DEBUG_PORT on host $DEBUG_HOST is reachable..."
nc -zv "$DEBUG_HOST" "$DEBUG_PORT"
NC_RESULT=$?

if [ "$NC_RESULT" -eq 0 ]; then
    echo "✅ Debug port $DEBUG_PORT is reachable."
else
    echo "❌ Cannot reach $DEBUG_HOST:$DEBUG_PORT. Check VSCode listener or firewall."
fi

echo -e "\n📄 Last 10 lines of Xdebug log:"
tail -n 10 "$XDEBUG_LOG"

echo -e "\n✅ Done."
