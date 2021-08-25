#!/bin/bash

function create_user() {
  echo "----------------------------------"
  echo "Creating user"
  useradd -u 1000 user_name --password the_password
  chown user_name.user_name /usr/local/apache2/htdocs
}

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

create_user
init_sshd & init_httpd
