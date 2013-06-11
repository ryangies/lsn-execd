#!/bin/bash
source "install/functions"
exit_unless_root_user

# TODO: Install dependencies
echo "#"
echo "# Install these dependencies first:"
echo "#"
echo "#   perl -MCPAN -e 'install Net::Server'"
echo "#   perl -MCPAN -e 'install Net::CIDR'"
echo "#   perl -MCPAN -e 'install Perl::Module'"
echo "#   perl -MCPAN -e 'install Data::Hub'"
echo "#"
echo "# or"
echo "#"
echo "#   cpanm Net::Server Net::CIDR lsn-data-hub"
echo "#"

if (! $(ask_yn "Continue?")); then
  exit 1
fi

# Install files
mkdir /etc/execd
if [ ! -d /etc/execd/conf ]; then
  cp -R conf /etc/execd/conf
fi
cp -R scripts /etc/execd/scripts
cp -R lib/perl /etc/execd/lib

# Set permissions
chown -R root:root /etc/execd
chmod -R u=rwX,g=rX,o=rX /etc/execd
chmod 600 /etc/execd/conf/*
chmod 700 /etc/execd/scripts/*

# Add the init script and enable the service at boot time
if [ ! -e /etc/init.d/execd ]; then
  ln -s /etc/execd/scripts/execd-rc /etc/init.d/execd
  chkconfig --add execd
fi

# Start (or restart) the service
/etc/init.d/execd status
case "$?" in
  3) /etc/init.d/execd start ;;
  0) /etc/init.d/execd restart ;;
  *) echo "status=$?"
esac

# Test to ensure all is working
if [ $? -eq 0 ]; then
  /etc/execd/scripts/execd-client-test
else
  echo "Service is not running."
  exit 1
fi
