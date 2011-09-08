#!/bin/bash
# Juan Pinilla

service iptables restart

IPTABLES=$(which iptables)
SERVER_IP="192.168.1.34"

# Flush
$IPTABLES -F
$IPTABLES -X
$IPTABLES -Z
$IPTABLES -t nat -F
 
# Politicas por defecto
$IPTABLES -P INPUT DROP
$IPTABLES -P FORWARD ACCEPT
$IPTABLES -P OUTPUT ACCEPT

# Localhost
$IPTABLES -A INPUT -i lo -j ACCEPT

# JUM
$IPTABLES -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
# DNS
$IPTABLES -A INPUT -p udp -s 0/0 --sport 1024:65535 -d $SERVER_IP --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPTABLES -A OUTPUT -p udp -s $SERVER_IP --sport 53 -d 0/0 --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
$IPTABLES -A INPUT -p tcp -s 0/0 --sport 53 -d $SERVER_IP --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPTABLES -A OUTPUT -p tcp -s $SERVER_IP --sport 53 -d 0/0 --dport 53 -m state --state ESTABLISHED -j ACCEPT

# Apache
$IPTABLES -I INPUT -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPTABLES -I OUTPUT -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT

# SSH LAN
$IPTABLES -A INPUT -s 0/0 -p tcp --dport 22 -j ACCEPT
$IPTABLES -A OUTPUT -s 0/0 -p tcp --dport 22 -j ACCEPT

# Ping
$IPTABLES -A INPUT -p icmp --icmp-type 8 -s 0/0 -d $SERVER_IP -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
$IPTABLES -A OUTPUT -p icmp --icmp-type 0 -s $SERVER_IP -d 0/0 -m state --state ESTABLISHED,RELATED -j ACCEPT 

$IPTABLES -A OUTPUT -p icmp --icmp-type 8 -s $SERVER_IP -d 0/0 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
$IPTABLES -A INPUT -p icmp --icmp-type 0 -s 0/0 -d $SERVER_IP -m state --state ESTABLISHED,RELATED -j ACCEPT
