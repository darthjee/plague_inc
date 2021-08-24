#!/bin/bash

echo "----------------------------------"
echo "Initing SSHD"
exec /usr/sbin/sshd -D -e
echo "----------------------------------"
echo "Initing HTTPD"
httpd-foreground
