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

case "$1" in
    start)
        echo "Starting $DESC..."
        # Ensure the PID file does not exist before starting
        if [ ! -f $PIDFILE ]; then
            $DAEMON start > $LOGFILE 2>&1 &
            echo $! > $PIDFILE
        else
            echo "$DESC is already running."
        fi
        ;;
    stop)
        echo "Stopping $DESC..."
        if [ -f $PIDFILE ]; then
            kill $(cat $PIDFILE)
            rm $PIDFILE
        else
            echo "$DESC is not running."
        fi
        ;;
    restart)
        echo "Restarting $DESC..."
        $0 stop
        sleep 1
        $0 start
        ;;
    *)
        echo "Usage: /etc/init.d/$NAME {start|stop|restart}"
        exit 1
esac

exit 0

