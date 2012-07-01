#!/usr/bin/env bash

cd $(dirname $0)
PWD=`pwd`
[ -z "$HTTPD" ] && export HTTPD=$(which httpd || which apache2)

HOSTS=/etc/hosts
HOSTX=conf/hosts-extra

echo "Creating Apache config"

perl tools/mkconfig.pl --domain localhost \
  conf/httpd.conf.in conf/httpd.conf || exit

egrep 'Listen|ServerName' conf/httpd.conf

function _shutdown() {
  PIDFILE=$PWD/logs/httpd.pid
  if [ -f $PIDFILE ] ; then
    PID=`cat $PIDFILE`
    echo "Shutting down httpd ($PID)"
    kill $PID
  fi
}

trap _shutdown SIGINT
# Comment this line to retain logs across runs
rm -f $PWD/logs/*_log
$HTTPD -f $PWD/conf/httpd.conf 
sleep 1
tail -f $PWD/logs/*_log
