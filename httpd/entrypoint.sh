#!/bin/bash

echo "----------------------------------"
echo "Initing SSHD"
systemctl restart sshd
echo "----------------------------------"
echo "Initing HTTPD"
httpd-foreground
