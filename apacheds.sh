#!/bin/sh
### BEGIN INIT INFO
# Provides:          apacheds
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start daemon at boot time
# Description:       Enable service provided by daemon.
### END INIT INFO

PATH=/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=/usr/share/apacheds/bin/apacheds.sh
NAME=apacheds
DESC="Apache Directory Server"
PIDFILE=/var/run/$NAME.pid
LOGFILE=/var/log/$NAME.log

. /lib/lsb/init-functions

case "$1" in
    start)
        log_daemon_msg "Starting $DESC"
        if [ ! -f $PIDFILE ]; then
            $DAEMON start >> $LOGFILE 2>&1
            sleep 1
            pidof java > $PIDFILE  # crude example, better to parse correctly
            log_end_msg 0
        else
            log_progress_msg "$DESC already running"
            log_end_msg 1
        fi
        ;;
    stop)
        log_daemon_msg "Stopping $DESC"
        if [ -f $PIDFILE ]; then
            kill $(cat $PIDFILE)
            rm -f $PIDFILE
            log_end_msg 0
        else
            log_progress_msg "$DESC not running"
            log_end_msg 1
        fi
        ;;
    restart)
        $0 stop
        sleep 1
        $0 start
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
esac

exit 0
