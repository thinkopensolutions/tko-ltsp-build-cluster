#!/bin/bash

###############################################################################
#
# Copyright (C) 2012 Thinkopen Solutions, Lda. All Rights Reserved
# http://www.thinkopensolutions.com.
#
# Carlos Miguel Sousa Almeida
# cma@thinkopensolutions.com
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
###############################################################################

# LTSP Load Balancer
. $(dirname $0)/ltsp-include.sh
if ! [ "$(basename $0)" == "$HOSTNAME.sh" ]; then fail $HOSTNAME "$WRONG_HOSTNAME_MSG"; fi

# Get ubuntu distribution
. /etc/lsb-release

configure_lang
update_applications

if ! [ -e /tmp/ltsp-loadbalancer01.install ]; then
    apt-get -y install ltsp-cluster-lbserver  || fail "Installing ltsp-cluster-lbserver"
    apt-get -y autoremove && apt-get -y autoclean || fail "Cleaning"
    touch /tmp/ltsp-loadbalancer01.install
fi

install_ldap_client || fail "Installing LDAP client"
install_nfs_client || fail "Installing NFS client"

# Insert all applications servers to configuration file
ip=$APPSERV_START_IP
for (( appserv=1; appserv<=$APPSERV_NUM; appserv++ ))
do
    num=$(printf "%02d" $appserv)
	add2file /etc/hosts "$NETWORK.$ip $APPSERV_NAME$num.$DOMAIN $APPSERV_NAME$num"
	let ip+=1
	if [[ $ip -gt 1 ]]; then
	    if ! [ $(grep $APPSERV_NAME$num "/etc/ltsp/lbsconfig.xml" | wc -l) -gt 0 ]; then
    	    sed_file /etc/ltsp/lbsconfig.xml "</group>" "    <node address=\"http://$APPSERV_NAME$num.$DOMAIN:8000\" name=\"$APPSERV_NAME$num\"/>\n        </group>"
        fi
	fi
done

# Configure lbs
sed_file /etc/ltsp/lbsconfig.xml "yourdomain.com" "$DOMAIN"
sed_file /etc/ltsp/lbsconfig.xml "max-threads=\"2\"" "max-threads=\"1\""
sed_file /etc/ltsp/lbsconfig.xml "<group default=\"true\" name=\"default\">" "<group default=\"true\" name=\"$DISTRIB_CODENAME\">"

if ! [ -e /root/ltsp-loadbalancer01.reboot ]; then
    touch /root/ltsp-loadbalancer01.reboot
    warning "REBOOTING..."
    reboot &
fi

