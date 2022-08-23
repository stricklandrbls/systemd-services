#!/bin/bash

if [ "$EUID" -ne 0 ]; then
	echo "Systemd service installs require administrive privileges."
	exit 1
else

	systemddir=/etc/systemd/system
	bindir=/usr/local/bin
	
	confdir=/etc/mediabackupd
	if ! [ -e $confdir ]; then
		mkdir -p $confdir
	fi

	cp mediabackupd.conf.template $confdir/mediabackupd.conf
	cp mediabackup.sh $bindir/mediabackup
	cp media-backupd{.service,.timer} $systemddir
	chown root:root $systemddir/media-backupd{.service,.timer} $bindir/mediabackup
	chmod 644 $systemddir/media-backupd{.service,.timer} $confdir/mediabackupd.conf
	chmod 744 $bindir/mediabackup

	systemctl start media-backupd.timer

fi
