#!/bin/bash

# start[默认] 启动 , stop 停止
CMD=$1
if [ -z $CMD ]; then
    CMD=start
fi

# debug[默认] 前台启动, release 后台启动 
MODE=$2
if [ -z $MODE ]; then
    MODE=debug
fi

CONFIG=$3
if [ -z $CONFIG ]; then
    CONFIG=config.lua
fi

SKYNET_EXTEND=$4
if [ -z $SKYNET_EXTEND ]; then
    SKYNET_EXTEND=.
fi

TMP=$PATH
PATH=$TMP
ulimit -c unlimited

CUR_PATH=$PWD
PID_FILE=$CONFIG.pid
CONF_TEMP=$CONFIG.tmp
DEBUG_CONF=$CONFIG.debug

function make_conf(){
    echo "skynet_extend='$SKYNET_EXTEND/'" > $CONF_TEMP
    cat $SKYNET_EXTEND/config.lua >> $CONF_TEMP
    cat $CONFIG >> $CONF_TEMP

    echo "daemon='$PID_FILE'" >> $CONF_TEMP
    echo "logger='log/$(basename $CONFIG).log'" >> $CONF_TEMP
  }

function start(){
    case "$MODE" in
        release)
            make_conf
            $SKYNET_EXTEND/skynet/skynet $CONF_TEMP
            rm $CONF_TEMP
            ;;
        debug)
            make_conf
            sed -e 's/daemon/--daemon/' $CONF_TEMP > $DEBUG_CONF
            rm $CONF_TEMP
            $SKYNET_EXTEND/skynet/skynet $DEBUG_CONF
        ;;
        *)
    esac
}

function stop(){
  echo $PID_FILE
  if [ ! -f $PID_FILE ] ;then
    echo "not found pid file have no gameserver"
    exit 0
  fi

  pid=`cat $PID_FILE`
  exist_pid=`pgrep skynet | grep $pid`
  if [ -z "$exist_pid" ] ;then
    echo "have no $CONFIG server"
    exit 0
  else
    echo -n $"$pid $CONFIG server will killed"
    kill $pid
    echo
  fi
}

case "$CMD" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  *)
    exit 2
esac
