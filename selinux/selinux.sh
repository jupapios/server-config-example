#!/bin/bash
# Juan Pinilla

# Postgres
chcon -R system_u:object_r:postgresql_db_t:s0 /db

# Apache
chcon -R system_u:object_r:httpd_sys_content_t:s0 /www
