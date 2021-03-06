#!/bin/bash

# Note: you'll probably want to install the "conntrack" package to troubleshoot
#       interaction between media-relay and the kernel.

ACTION=$1
shift

if [ "x$ACTION" == "x" ]; then
  cat - <<'EOT'

$0 (dispatcher|relay|both)

Creates configuration files for MediaProxy.
(You probably want to use the "both" option only.)

This script will also adjust your /etc/sysctl.conf file to allow
forwarding of IPv4 and IPv6.

IMPORTANT

If you are using IPv6, routing will break at this point, because enabling
IPv6 forwarding will disable autoconfiguration.

Make sure you statically set both your IPv6 address and your default IPv6 route
before running the installation for a MediaProxy relay, otherwise you WILL LOSE
ACCESS TO THIS MACHINE.

This can be done for example by adding the following lines under your eth0 entry
in /etc/network/interfaces:

   # Replace my IPv6 addresses with yours!
   up   ip -6 addr  add 2001:1900:201e:6:216:3eff:fe39:ce6f/64 dev eth0
   up   ip -6 route add default via 2001:1900:201e:6::1
   down ip -6 addr  del 2001:1900:201e:6:216:3eff:fe39:ce6f/64 dev eth0
   down ip -6 route del default via 2001:1900:201e:6::1

You should also manually run the "ip -6 route add default via .... " command
before running this script.


Again,

    Running this script to configure a relay
    will cause trouble with IPv6 access
    if you do not first update your settings.

EOT
fi


function do_sysctl {
  sed -i -e 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
  egrep -q '^net.ipv4.ip_forward=1$' /etc/sysctl.conf || exit

  sed -i -e 's/#net.ipv6.conf.all.forwarding=1/net.ipv6.conf.all.forwarding=1/' /etc/sysctl.conf
  egrep -q '^net.ipv6.conf.all.forwarding=1$' /etc/sysctl.conf || exit
  # Maybe
  #  net.ipv6.conf.default.forwarding=1
  # also?

  sysctl -p /etc/sysctl.conf
}

if [ "x$ACTION" == "xdispatcher" ]; then

  cp ./dispatcher.ini   /etc/mediaproxy/config.ini

  /etc/init.d/mediaproxy-dispatcher restart

fi

if [ "x$ACTION" == "xrelay" ]; then

  cp ./relay.ini        /etc/mediaproxy/config.ini

  do_sysctl
  /etc/init.d/mediaproxy-relay restart

fi

if [ "x$ACTION" == "xboth" ]; then

  cat ./*.ini > /etc/mediaproxy/config.ini

  do_sysctl
  /etc/init.d/mediaproxy-dispatcher restart
  /etc/init.d/mediaproxy-relay restart

fi

