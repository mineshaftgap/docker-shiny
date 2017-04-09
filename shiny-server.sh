#!/bin/sh

# self signed certs need this owned by root
chown root.root /etc/ca-certificates.conf

/bin/su -l shiny -s /bin/sh -c /usr/bin/shiny-server 2>&1

# exec shiny-server 2>&1
