#!/bin/sh

rm /koolshare/icon-phddns.png
rm /koolshare/webs/Module_gdddns.asp
rm /koolshare/scripts/gdddns_config.sh
rm /koolshare/scripts/gdddns_update.sh
rm /koolshare/scripts/install_gdddns.sh
rm /koolshare/scripts/uninstall_gdddns.sh


dbus remove softcenter_module_gdddns_install
dbus remove softcenter_module_gdddns_version
dbus remove softcenter_module_gdddns_description