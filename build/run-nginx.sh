#!/bin/bash

trapIt () {
    "$@"& pid="$!";
    echo "PID: $pid"
    for SGNL in INT TERM CHLD USR1; do
        trap "echo 'Sending signal ${SGNL} for pid ${pid}'; kill -${SGNL} ${pid}" "$SGNL";
    done;
    echo "Checking if pid ${pid} is still running"
    while kill -0 ${pid} > /dev/null 2>&1; do
        echo "Waiting ${pid} to exit..."
        wait ${pid}; ec="$?";
    done;
    exit ${ec};
};

STATIC=/var/www/
args=" $@ "
if [[ ! ${args} =~ " --help " ]]; then
  ARG_STATIC=`/ppm/vendor/bin/ppm config --show-option="static-directory" "$@"`
fi

[[ ! -z "$ARG_STATIC" ]] && STATIC="${STATIC}${ARG_STATIC}"
sed -i "s#STATIC_DIRECTORY#${STATIC}#g" /etc/nginx/sites-enabled/default

nginx

mkdir -p /ppm/run
chmod -R 777 /ppm/run
ARGS='--port=8081 --socket-path=/ppm/run --pidfile=/ppm/ppm.pid'

# make sure static-directory is not served by php-pm
ARGS="$ARGS --static-directory=''"

trapIt /ppm/vendor/bin/ppm start --ansi ${ARGS} "$@"
