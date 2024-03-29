#!/usr/bin/env bash

UNAME=`uname`
case $UNAME in
        "Linux") HOST=`hostname -s`;;
        "SunOS") HOST=`hostname`;;
        *) HOST=`hostname -s`;;
esac

INSTALL_DIR=/usr/lib/tsung/
ERL=/usr/bin/erl
MAIN_DIR=$HOME/.tsung
LOG_DIR=$MAIN_DIR/log
LOG_OPT="log_file \"$LOG_DIR/tsung.log\""
VERSION=1.7.1_dev
NAMETYPE="-sname"

LISTEN_PORT=8090
USE_PARENT_PROXY=false
PGSQL_SERVER_IP=127.0.0.1
PGSQL_SERVER_PORT=5432
NAME=tsung
RECORDER=tsung_recorder

TSUNGPATH=$INSTALL_DIR/tsung-$VERSION/ebin
RECORDERPATH=$INSTALL_DIR/tsung_recorder-$VERSION/ebin
CONTROLLERPATH=$INSTALL_DIR/tsung_controller-$VERSION/ebin

CONF_OPT_FILE="$HOME/.tsung/tsung.xml"
DEBUG_LEVEL=5
RECORDER_PLUGIN="http"
ERL_RSH=" -rsh ssh "
ERL_OPTS=" -smp auto +P 250000 +A 16 +K true  "
COOKIE='tsung'

stop() {
    $ERL $ERL_OPTS $ERL_RSH -noshell  $NAMETYPE killer -setcookie $COOKIE -pa $TSUNGPATH -pa $RECORDERPATH -s tsung_recorder stop_all $HOST -s init stop
    RET=$?
    if [ $RET == 1 ]; then
        echo "FAILED"
    else
        echo "[OK]"
        rm $PIDFILE
    fi
}

status() {
    PIDFILE="/tmp/tsung_recorder.pid"
    if [ -f $PIDFILE ]; then
      echo "Tsung recorder started [OK]"
    else
      echo "Tsung recorder not started "
    fi
}

start() {
    echo "Starting Tsung recorder on port $LISTEN_PORT"
    $ERL $ERL_OPTS $ERL_RSH -noshell $NAMETYPE $RECORDER -setcookie $COOKIE  \
    -s tsung_recorder \
    -pa $TSUNGPATH -pa $RECORDERPATH -pa $CONTROLLERPATH \
    -tsung_recorder debug_level $DEBUG_LEVEL \
    -tsung_recorder $LOG_OPT \
    -tsung_recorder parent_proxy $USE_PARENT_PROXY \
    -tsung_recorder plugin ts_proxy_$RECORDER_PLUGIN \
    -tsung_recorder proxy_log_file \"$MAIN_DIR/tsung_recorder.xml\" \
    -tsung_recorder pgsql_server \"${PGSQL_SERVER_IP}\" \
    -tsung_recorder pgsql_port ${PGSQL_SERVER_PORT} \
    -tsung_recorder proxy_listen_port $LISTEN_PORT &
    echo $! > /tmp/tsung_recorder.pid
}

version() {
    echo "Tsung Recorder version $VERSION"
    exit 0
}

checkconfig() {
    if [ ! -e $CONF_OPT_FILE ]
    then
        echo "Config file $CONF_OPT_FILE doesn't exist, aborting !"
        exit 1
    fi
}

maindir() {
    if [ ! -d $MAIN_DIR ]
    then
        echo "Creating local Tsung directory $MAIN_DIR"
        mkdir $MAIN_DIR
    fi
}

logdir() {
        if [ ! -d $LOG_DIR ]
        then
                echo "Creating Tsung log directory $LOG_DIR"
                mkdir $LOG_DIR
        fi
}

record_tag() {
    shift
    SNAME=tsung_recordtag
    $ERL -noshell $NAMETYPE $SNAME -setcookie $COOKIE -pa $TSUNGPATH -pa $RECORDERPATH -run ts_proxy_recorder recordtag $HOST "$*" -s init stop
}

checkrunning(){
    if [ -f $PIDFILE ]; then
        CURPID=`cat $PIDFILE`
        if kill -0 $CURPID 2> /dev/null ; then
            echo "Can't start: Tsung recorder already running !"
            exit 1
        fi
    fi
}

usage() {
    prog=`basename $0`
    echo "Usage: $prog <options> start|stop|restart"
    echo "Options:"
    echo "    -p <plugin>    plugin used for the recorder"
    echo "                     available: http, pgsql,webdav (default is http)"
    echo "    -L <port>      listening port for the recorder (default is 8090)"
    echo "    -I <IP>        for the pgsql recorder (or parent proxy): server IP"
    echo "                      (default  is 127.0.0.1)"
    echo "    -P <port>      for  the  pgsql recorder (or parent proxy): server port"
    echo "                      (default is 5432)"
    echo "    -u             for the http recorder: use a parent proxy"
    echo "    -d <level>     set log level from 0 to 7 (default is 5)"
    echo "    -v             print version information and exit"
    echo "    -h             display this help and exit"
    exit
}

while getopts "hvf:p:l:d:r:i:P:L:I:u" Option
do
    case $Option in
        f) CONF_OPT_FILE=$OPTARG;;
        l) # must add absolute path
            echo "$OPTARG" | grep -q "^/"
            RES=$?
            if [ "$RES" == 0 ]; then
                LOG_OPT="log_file \"$OPTARG\" "
            else
                LOG_OPT="log_file \"$PWD/$OPTARG\" "
            fi
            ;;
        d) DEBUG_LEVEL=$OPTARG;;
        p) RECORDER_PLUGIN=$OPTARG;;
        I) PGSQL_SERVER_IP=$OPTARG;;
        u) USE_PARENT_PROXY=true;;
        P) PGSQL_SERVER_PORT=$OPTARG;;
        L) LISTEN_PORT=$OPTARG;;
        v) version;;
        h) usage;;
        *) usage ;;
    esac
done
shift $(($OPTIND - 1))

case $1 in
    start)
        PIDFILE="/tmp/tsung_recorder.pid"
        maindir
        logdir
        checkrunning
        start
        ;;

    record_tag)
        record_tag $*
        ;;
    stop)
        PIDFILE="/tmp/tsung_recorder.pid"
        stop
        ;;
    status)
        status
        ;;
    restart)
        stop
        start
        ;;
    *)
        usage $0
        ;;
esac
