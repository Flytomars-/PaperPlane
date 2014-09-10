#!/bin/sh

systemd=$(pidof systemd)

if [ -z "$systemd" ]; then
	echo "Systemd not detected"
	echo "Assuming upstart"
	startCmd="start paperplane"
	stopCmd="stop paperplane"
else
	echo "Systemd detected"
	startCmd="systemctl start PaperPlane"
	stopCmd="systemctl stop PaperPlane"
fi

if [ -d "/var/local/paperplane" ]; then
	echo "Updating existing install"
	eval "$stopCmd"
	cp -R . /var/local/paperplane
	chown -R paperplane:paperplane /var/local/paperplane
	eval "$startCmd"
fi

if [ ! -d "/var/local/paperplane" ]; then
	# Add user
	adduser --system --group --gecos 'User for PaperPlane webapp' --disabled-password --home /home/paperplane paperplane
	
	if [ -z "$systemd" ]; then
		# Copy upstart config
		cp upstart.conf /etc/init/paperplane.conf
	else
		# Copy systemd config
		cp systemd.service /usr/lib/systemd/system/PaperPlane.service
		# Enable systemd service
		systemctl enable PaperPlane
	fi
	
	# Copy application folder and create log file
	cp -R . /var/local/paperplane
	touch /var/log/paperplane.log
	chown paperplane:paperplane /var/log/paperplane.log
	
	# Install node deps
	cd /var/local/paperplane; npm link
	chown -R paperplane:paperplane /var/local/paperplane
	
	eval "$startCmd"
fi
