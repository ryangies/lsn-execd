#!/bin/bash
source "install/functions"
exit_unless_root_user
/etc/init.d/execd stop
chkconfig --del execd
unlink /etc/init.d/execd
rm -rf /etc/execd
