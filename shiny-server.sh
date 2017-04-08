#!/bin/sh

# Make sure the directory for individual app logs exists
mkdir -p /var/log/shiny-server
chown shiny.shiny /var/log/shiny-server

# make this file owned by root in container so that certs can be added
chown root.root /etc/ca-certificates.conf

exec shiny-server 2>&1
