#!/bin/bash
# Script to Import ldif into ldap.

# Declare some variables
LDAP_BIND="cn=admin,dc=rabbitmq,dc=dev"
LDAP_BIND_SECRET="secret"
LDAP_HOSTNAME="localhost"
LDAP_LDIF_DIR="/vagrant_data/ldap"

# Import users into ldap
ldapadd -x -D ${LDAP_BIND} -w ${LDAP_BIND_SECRET} -h ${LDAP_HOSTNAME} -f ${LDAP_LDIF_DIR}/ldap-data.ldif
