#!/bin/sh

echo "config" >> /tml/ddns.log

if [ "`dbus get gdddns_enable`" == "1" ]; then
	echo "config open" >> /tmp/ddns.log
    dbus delay gdddns_timer `dbus get gdddns_interval` /koolshare/scripts/gdddns_update.sh
else
	echo "config off" >> /tmp/ddns.log
    dbus remove __delay__gdddns_timer
fi
