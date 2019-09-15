#!/bin/bash

trapIt () {
    "$@"& pid="$!";
    echo "CMD: $@"
    echo "PID: $pid"
    for SGNL in INT TERM CHLD USR1; do
        trap "ps ax; echo 'Trapped ${SGNL}. Sending signal ${SGNL} to PID ${pid}'; kill -${SGNL} ${pid} || true" "$SGNL";
    done;
    echo "Checking if pid ${pid} is still running"
    while kill -0 ${pid} > /dev/null 2>&1; do
        echo "Waiting ${pid} to complete..."
        wait ${pid}; ec="$?";
    done;
    exit ${ec};
};

ARGS='--port 8080'
trapIt /ppm/vendor/bin/ppm start --ansi "$@"
