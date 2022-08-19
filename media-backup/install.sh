#!/bin/bash

if [ "$EUID" -ne 0 ]; then
	echo "Systemd service installs require administrive privileges."
	exit 1
else
	systemddir=/etc/systemd/system
	bindir=/usr/local/bin
	cp mediabackup.sh $bindir
	cp media-backupd.service media-backupd.timer $systemddir
	chown root:root $systemddir/media-backupd.timer $systemddir/media-backupd.service $binddir/mediabackup.sh
	chmod 644 $systemddir/media-backupd.service $systemddir/media-backupd.timer
	chmod 744 $binddir/mediabackup.sh
	systemctl start media-backupd.timer
fi
