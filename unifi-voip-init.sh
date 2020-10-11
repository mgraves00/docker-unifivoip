#!/bin/bash
#
# /etc/init.d/UniFiVoip -- startup script for Ubiquiti UniFi Voip
#
#
### BEGIN INIT INFO
# Provides:          unifi-voip
# Required-Start:    $local_fs $remote_fs $network
# Required-Stop:     $local_fs $remote_fs $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Ubiquiti UniFi
# Description:       Ubiquiti UniFi Controller
### END INIT INFO

set_java_home () {
        arch=`dpkg --print-architecture 2>/dev/null`
        support_java_ver='6 7 8'
        java_list=''
        for v in ${support_java_ver}; do
                java_list=`echo ${java_list} java-$v-openjdk-${arch}`
                java_list=`echo ${java_list} java-$v-openjdk`
        done

        cur_java=`update-alternatives --query java | awk '/^Value: /{print $2}'`
        cur_real_java=`readlink -f ${cur_java} 2>/dev/null`
        for jvm in ${java_list}; do
                jvm_real_java=`readlink -f /usr/lib/jvm/${jvm}/bin/java 2>/dev/null`
                [ "${jvm_real_java}" != "" ] || continue
                if [ "${jvm_real_java}" == "${cur_real_java}" ]; then
                        JAVA_HOME="/usr/lib/jvm/${jvm}"
                        return
                fi
        done

        alts_java=`update-alternatives --query java | awk '/^Alternative: /{print $2}'`
        for cur_java in ${alts_java}; do
                cur_real_java=`readlink -f ${cur_java} 2>/dev/null`
                for jvm in ${java_list}; do
                        jvm_real_java=`readlink -f /usr/lib/jvm/${jvm}/bin/java 2>/dev/null`
                        [ "${jvm_real_java}" != "" ] || continue
                        if [ "${jvm_real_java}" == "${cur_real_java}" ]; then
                                JAVA_HOME="/usr/lib/jvm/${jvm}"
                                return
                        fi
                done
        done

        JAVA_HOME=/usr/lib/jvm/java-6-openjdk
}


dir_symlink_fix() {
    DSTDIR=$1
    SYMLINK=$2

    [ -d ${DSTDIR} ] || mkdir -p ${DSTDIR}
    [ -d ${SYMLINK} -a ! -L ${SYMLINK} ] && mv ${SYMLINK} `mktemp -u ${SYMLINK}.XXXXXXXX`
    [ "$(readlink ${SYMLINK})" = "${DSTDIR}" ] || (rm -f ${SYMLINK} && ln -sf ${DSTDIR} ${SYMLINK})
}

file_symlink_fix() {
    DSTFILE=$1
    SYMLINK=$2

    if [ -f ${DSTFILE} ]; then
        [ -f ${SYMLINK} -a ! -L ${SYMLINK} ] && mv ${SYMLINK} `mktemp -u ${SYMLINK}.XXXXXXXX`
        [ "$(readlink ${SYMLINK})" = "${DSTFILE}" ] || (rm -f ${SYMLINK} && ln -sf ${DSTFILE} ${SYMLINK})
    fi
}

NAME="unifi-voip"
DESC="Ubiquiti UniFi Controller"

BASEDIR="/usr/lib/unifi-voip"
MAINCLASS="com.ubnt.ace.Launcher"

PIDFILE="/var/run/${NAME}/${NAME}.pid"
PATH=/bin:/usr/bin:/sbin:/usr/sbin

[ -f /etc/default/rcS ] && . /etc/default/rcS
. /lib/lsb/init-functions

MONGOPORT=29117

CODEPATH=${BASEDIR}
DATALINK=${BASEDIR}/data
LOGLINK=${BASEDIR}/logs
RUNLINK=${BASEDIR}/run

DATADIR=/data/var/${NAME}
LOGDIR=/data/log/${NAME}
RUNDIR=/data/run/${NAME}

ENABLE_UNIFI=yes
JVM_EXTRA_OPTS=
JSVC_EXTRA_OPTS=
[ -f /etc/default/${NAME} ] && . /etc/default/${NAME}

[ "x${ENABLE_UNIFI}" != "xyes" ] && exit 0

[ -z "${UNIFI_DATA_DIR}" ] || DATADIR=${UNIFI_DATA_DIR}
[ -z "${UNIFI_LOG_DIR}" ] || LOGDIR=${UNIFI_LOG_DIR}
[ -z "${UNIFI_RUN_DIR}" ] || RUNDIR=${UNIFI_RUN_DIR}

MONGOLOCK="${DATAPATH}/db/mongod.lock"
JVM_EXTRA_OPTS="${JVM_EXTRA_OPTS} -Dunifi-voip.datadir=${DATADIR} -Dunifi-voip.logdir=${LOGDIR} -Dunifi-voip.rundir=${RUNDIR}"

JVM_OPTS="${JVM_EXTRA_OPTS} -Djava.awt.headless=true -Dfile.encoding=UTF-8 -Xmx1024M"

[ "x${JAVA_HOME}" != "x" ] || set_java_home

# JSVC - for running java apps as services
JSVC=$(command -v jsvc)
if [ -z ${JSVC} -o ! -x ${JSVC} ]; then
        log_failure_msg "${DESC}: jsvc is missing!"
        exit 1
fi

# fix path for ace
dir_symlink_fix ${DATADIR} ${DATALINK}
dir_symlink_fix ${LOGDIR} ${LOGLINK}
dir_symlink_fix ${RUNDIR} ${RUNLINK}
[ -z "${UNIFI_SSL_KEYSTORE}" ] || file_symlink_fix ${UNIFI_SSL_KEYSTORE} ${DATALINK}/keystore

#JSVC_OPTS="-debug"

# check whether jsvc requires -cwd option
#${JSVC} -java-home ${JAVA_HOME} -cwd / -help >/dev/null 2>&1
#if [ $? -eq 0 ] ; then
#       JSVC_OPTS="${JSVC_OPTS} -cwd ${BASEDIR}"
#fi

JSVC_OPTS="${JSVC_OPTS}\
 -home ${JAVA_HOME} \
 -cp /usr/share/java/commons-daemon.jar:${BASEDIR}/lib/ace.jar \
 -pidfile ${PIDFILE} \
 -procname ${NAME} \
 -outfile SYSLOG \
 -errfile SYSLOG \
 ${JSVC_EXTRA_OPTS} \
 ${JVM_OPTS}"

[ -f /etc/default/rcS ] && . /etc/default/rcS
. /lib/lsb/init-functions

[ -d /var/run/${NAME} ] || mkdir -p /var/run/${NAME}
cd ${BASEDIR}

is_not_running() {
        start-stop-daemon --test --start --pidfile "${PIDFILE}" \
                --startas "${JAVA_HOME}/bin/java" >/dev/null
        RC=$?
        return ${RC}
}

case "$1" in
        start)
                log_daemon_msg "Starting ${DESC}" "${NAME}"
                if is_not_running; then
                        ${JSVC} ${JSVC_OPTS} ${MAINCLASS} start
                        sleep 1
                        if is_not_running; then
                                log_end_msg 1
                        else
                                log_end_msg 0
                        fi
                else
                        log_progress_msg "(already running)"
                        log_end_msg 1
                fi
        ;;
        stop)
                log_daemon_msg "Stopping ${DESC}" "${NAME}"
                if is_not_running; then
                        log_progress_msg "(not running)"
                else
                        ${JSVC} ${JSVC_OPTS} -stop ${MAINCLASS} stop
                        for i in `seq 1 10` ; do
                                [ -z "$(pgrep -f ${BASEDIR}/lib/ace.jar)" ] && break
                                # graceful shutdown
                                [ $i -gt 1 ] && [ -d ${RUNPATH}] && touch ${RUNPATH}/server.stop || true
                                # savage shutdown
                                [ $i -gt 7 ] && pkill -f ${BASEDIR}/lib/ace.jar || true
                                sleep 1
                        done
                        # shutdown mongod
                        if [ -f ${MONGOLOCK} ]; then
                                mongo localhost:${MONGOPORT} --eval "db.getSiblingDB('admin').shutdownServer()" >/dev/null 2>&1
                        fi
                fi
                log_end_msg 0
        ;;
        status)
                status_of_proc -p ${PIDFILE} unifi-voip unifi-voip && exit 0 || exit $?
        ;;
        restart|reload|force-reload)
                if ! is_not_running ; then
                        if which invoke-rc.d >/dev/null 2>&1; then
                                invoke-rc.d ${NAME} stop
                        else
                                /etc/init.d/${NAME} stop
                        fi
                fi
                if which invoke-rc.d >/dev/null 2>&1; then
                        invoke-rc.d ${NAME} start
                else
                        /etc/init.d/${NAME} start
                fi
        ;;
        *)
                log_success_msg "Usage: $0 {start|stop|restart|reload|force-reload}"
                exit 1
        ;;
esac

exit 0

