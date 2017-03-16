#!/bin/sh

cp -r /tmp/gdddns/* /koolshare/
chmod a+x /koolshare/scripts/gdddns_*

# add icon into softerware center
dbus set softcenter_module_gdddns_install=1
dbus set softcenter_module_gdddns_version=0.1
dbus set softcenter_module_gdddns_description="Godaddy 解析自动更新IP"
