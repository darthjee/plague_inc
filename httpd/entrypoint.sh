#!/bin/bash

function init_sshd() {
  echo "----------------------------------"
  echo "Initing SSHD"
  exec /usr/sbin/sshd -D -e
}

function init_httpd() {
  echo "----------------------------------"
  echo "Initing HTTPD"
  httpd-foreground
}

init_sshd & init_httpd
