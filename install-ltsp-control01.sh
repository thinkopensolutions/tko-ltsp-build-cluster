#!/bin/bash

# LTSP Control

. ltsp-include.sh

apt-get -y install ltsp-cluster-control postgresql || fail "Installing ltsp-cluster-control postgresql"

sed -i "s/yourdomain.com/$DOMAIN/g" /etc/ltsp/ltsp-cluster-control.config.php || fail "SEDing ltsp-cluster-control.config.php"

if ! [ $(cat /etc/hosts | grep ${APPs[$LOADBALANCER]} | wc -l) -gt 0 ]; then
    echo "$NETWORK.$LOADBALANCER ${APPs[$LOADBALANCER]}.$DOMAIN ${APPs[$LOADBALANCER]}" >> /etc/hosts || fail "Adding loadbalancer to hosts"
fi

# BUILD DATABASE
sudo -u postgres createuser -SDRlP ltsp || fail "Creating postgres user"
sudo -u postgres createdb ltsp -O ltsp || fail "Creating ltsp database"
cd /usr/share/ltsp-cluster-control/DB/ || fail "Changing to directory /usr/share/ltsp-cluster-control/DB/"
cat schema.sql functions.sql | psql -h localhost ltsp ltsp || fail "Building database"
cd /root || fail "Changing to directory /root"

wget http://bazaar.launchpad.net/%7Eltsp-cluster-team/ltsp-cluster/ltsp-cluster-control/download/head%3A/controlcenter.py-20090118065910-j5inpmeqapsuuepd-3/control-center.py || fail "Getting control-center"
wget http://bazaar.launchpad.net/%7Eltsp-cluster-team/ltsp-cluster/ltsp-cluster-control/download/head%3A/rdpldm.config-20090430131602-g0xccqrcx91oxsl0-1/rdp%2Bldm.config || fail "Getting rdp+ldm config"

apt-get -y install python-pygresql || fail "Installing python-pygresql"

/etc/init.d/apache2 stop || fail "Stopping apache2"
echo "CD_VOLUME => text
CONFIGURE_FSTAB => list:True,False
CONFIGURE_X => list:True,False
CONSOLE_KEYMAP => text
CRONTAB_01 => text
CRONTAB_02 => text
CRONTAB_03 => text
CRONTAB_04 => text
CRONTAB_05 => text
CRONTAB_06 => text
CRONTAB_07 => text
CRONTAB_08 => text
CRONTAB_09 => text
CRONTAB_10 => text
CUPS_SERVER => text
DNS_SERVER => text
FRONT_MIC_VOLUME => text
FRONT_VOLUME => text
FRONT_VOLUME => text
HEADPHONE_VOLUME => text
INVENTORY_NUMBER => text
LANG => text
LDM_ALLOW_USER => text
LDM_AUTOLOGIN => list:True,False
LDM_THEME => text
LDM_LIMIT_ONE_SESSION => list:True,False
LDM_LIMIT_ONE_SESSION_PROMPT => list:True,False
LDM_DEBUG => list:True,False
LDM_DIRECTX => list:True,False
LDM_LANGUAGE => text
LDM_LOGIN_TIMEOUT => text
LDM_NODMPS => list:True,False
LDM_PASSWORD => text
LDM_PRINTER_DEFAULT => text
LDM_PRINTER_LIST => multilist
LDM_SERVER => text
LDM_SESSION => text
LDM_SSHOPTIONS => text
LDM_SYSLOG => list:True,False
LDM_USERNAME => text
LDM_XSESSION => text
LOCALDEV => list:True,False
LOCALDEV_DENY => text
LOCALDEV_DENY_CD => list:True,False
LOCALDEV_DENY_FLOPPY => list:True,False
LOCALDEV_DENY_INTERNAL_DISKS => list:True,False
LOCALDEV_DENY_USB => list:True,False
LOCAL_APPS => list:True,False
LOCAL_APPS => list:True,False
LOCAL_APPS_EXTRAMOUNTS => text
LOCAL_APPS_MENU => list:True,False
LOCAL_APPS_MENU_ITEMS => multilist
LOCAL_APPS_WHITELIST => multilist
MIC_VOLUME => text
MODULE_01 => text
MODULE_02 => text
MODULE_03 => text
MODULE_04 => text
MODULE_05 => text
MODULE_06 => text
MODULE_07 => text
MODULE_08 => text
MODULE_09 => text
MODULE_10 => text
NBD_SWAP => list:True,False
NBD_SWAP_PORT => text
NBD_SWAP_SERVER => text
NETWORK_COMPRESSION => list:True,False
PCM_VOLUME => text
PRINTER_0_DATABITS => text
PRINTER_0_DEVICE => text
PRINTER_0_FLOWCTRL => text
PRINTER_0_OPTIONS => text
PRINTER_0_PARITY => list:True,False
PRINTER_0_PORT => text
PRINTER_0_SPEED => text
PRINTER_0_TYPE => text
PRINTER_0_WRITE_ONLY => list:True,False
PXE_CONFIG => text
RCFILE_01 => text
RCFILE_02 => text
RCFILE_03 => text
RCFILE_04 => text
RCFILE_05 => text
RCFILE_06 => text
RCFILE_07 => text
RCFILE_08 => text
RCFILE_09 => text
RCFILE_10 => text
RDP_OPTIONS => text
RDP_SERVER => text
RDP_SOUND => list:nopulse,pulse-oss
SCANNER => list:True,False
SCREEN_01 => list:rdesktop,xdmcp,shell,ldm,startx,telnet
SCREEN_02 => list:rdesktop,xdmcp,shell,ldm,startx,telnet
SCREEN_03 => list:rdesktop,xdmcp,shell,ldm,startx,telnet
SCREEN_04 => list:rdesktop,xdmcp,shell,ldm,startx,telnet
SCREEN_05 => list:rdesktop,xdmcp,shell,ldm,startx,telnet
SCREEN_06 => list:rdesktop,xdmcp,shell,ldm,startx,telnet
SCREEN_07 => list:rdesktop,xdmcp,shell,ldm,startx,telnet
SCREEN_08 => list:rdesktop,xdmcp,shell,ldm,startx,telnet
SCREEN_09 => list:rdesktop,xdmcp,shell,ldm,startx,telnet
SCREEN_10 => list:rdesktop,xdmcp,shell,ldm,startx,telnet
SCREEN_11 => list:rdesktop,xdmcp,shell,ldm,startx,telnet
SCREEN_12 => list:rdesktop,xdmcp,shell,ldm,startx,telnet
SEARCH_DOMAIN => text
SERVER => text
SHUTDOWN_TIME => text
SOUND => list:True,False
SOUND_DAEMON => text
SSH_FOLLOW_SYMLINKS => list:True,False
SSH_OVERRIDE_PORT => text
SYSLOG_HOST => text
TELNET_HOST => text
TIMESERVER => text
TIMEZONE => text
USE_LOCAL_SWAP => list:True,False
USE_TOUCH => text
USE_XFS => list:True,False
VOLUME => text
XDM_SERVER => text
XFS_SERVER => text
XKBLAYOUT => text
XKBMODEL => text
XKBOPTIONS => text
XKBRULES => text 
XKBVARIANT => text
XRANDR_AUTO_MULTIHEAD => list:True,False
XRANDR_DISABLE => list:True,False
XRANDR_DPI_01 => text
XRANDR_DPI_02 => text
XRANDR_DPI_03 => text
XRANDR_DPI_04 => text
XRANDR_DPI_05 => text
XRANDR_DPI_06 => text
XRANDR_DPI_07 => text
XRANDR_DPI_08 => text
XRANDR_DPI_09 => text
XRANDR_MODE_01 => text
XRANDR_MODE_02 => text
XRANDR_MODE_03 => text
XRANDR_MODE_04 => text
XRANDR_MODE_05 => text
XRANDR_MODE_06 => text
XRANDR_MODE_07 => text
XRANDR_MODE_08 => text
XRANDR_MODE_09 => text
XRANDR_NEWMODE_01 => text
XRANDR_NEWMODE_02 => text
XRANDR_NEWMODE_03 => text
XRANDR_NEWMODE_04 => text
XRANDR_NEWMODE_05 => text
XRANDR_NEWMODE_06 => text
XRANDR_NEWMODE_07 => text
XRANDR_NEWMODE_08 => text
XRANDR_NEWMODE_09 => text
XRANDR_ORIENTATION_01 => text
XRANDR_ORIENTATION_02 => text
XRANDR_ORIENTATION_03 => text
XRANDR_ORIENTATION_04 => text
XRANDR_ORIENTATION_05 => text
XRANDR_ORIENTATION_06 => text
XRANDR_ORIENTATION_07 => text
XRANDR_ORIENTATION_08 => text
XRANDR_ORIENTATION_09 => text
XRANDR_OUTPUT_01 => text
XRANDR_OUTPUT_02 => text
XRANDR_OUTPUT_03 => text
XRANDR_OUTPUT_04 => text
XRANDR_OUTPUT_05 => text
XRANDR_OUTPUT_06 => text
XRANDR_OUTPUT_07 => text
XRANDR_OUTPUT_08 => text
XRANDR_OUTPUT_09 => text
XRANDR_RATE_01 => text
XRANDR_RATE_02 => text
XRANDR_RATE_03 => text
XRANDR_RATE_04 => text
XRANDR_RATE_05 => text
XRANDR_RATE_06 => text
XRANDR_RATE_07 => text
XRANDR_RATE_08 => text
XRANDR_RATE_09 => text
XRANDR_REFLECT_01 => text
XRANDR_REFLECT_02 => text
XRANDR_REFLECT_03 => text
XRANDR_REFLECT_04 => text
XRANDR_REFLECT_05 => text
XRANDR_REFLECT_06 => text
XRANDR_REFLECT_07 => text
XRANDR_REFLECT_08 => text
XRANDR_REFLECT_09 => text
XRANDR_ROTATE_01 => text
XRANDR_ROTATE_02 => text
XRANDR_ROTATE_03 => text
XRANDR_ROTATE_04 => text
XRANDR_ROTATE_05 => text
XRANDR_ROTATE_06 => text
XRANDR_ROTATE_07 => text
XRANDR_ROTATE_08 => text
XRANDR_ROTATE_09 => text
XRANDR_SIZE_01 => text
XRANDR_SIZE_02 => text
XRANDR_SIZE_03 => text
XRANDR_SIZE_04 => text
XRANDR_SIZE_05 => text
XRANDR_SIZE_06 => text
XRANDR_SIZE_07 => text
XRANDR_SIZE_08 => text
XRANDR_SIZE_09 => text
XSERVER => list:ark,ati,atimisc,chips,cirrus_alpine cirrus,cirrus_laguna,cyrix,dummy,fbdev,fglrx,glint,i128,i740,i810,imstt,mga,neomagic,newport,nsc,nv,r128,radeon,rendition,riva128,s3,s3virge,savage,siliconmotion,sis,sisusb,tdfx,tga,trident,tseng,v4l,vesa,vga,via,vmware,voodoo
X_BLANKING => text
X_COLOR_DEPTH => list:2,4,8,16,24,32
X_CONF => text
X_HORZSYNC => text
X_MODE_0 => text
X_MODE_1 => text
X_MODE_2 => text
X_MONITOR_OPTION_01 => text
X_MONITOR_OPTION_02 => text
X_MONITOR_OPTION_03 => text
X_MONITOR_OPTION_04 => text
X_MONITOR_OPTION_05 => text
X_MONITOR_OPTION_06 => text
X_MONITOR_OPTION_07 => text
X_MONITOR_OPTION_08 => text
X_MONITOR_OPTION_09 => text
X_MONITOR_OPTION_10 => text
X_MOUSE_DEVICE => text
X_MOUSE_EMULATE3BTN => list:True,False
X_MOUSE_PROTOCOL => list:sunkbd,lkkbd,vsxxxaa,spaceorb,spaceball,magellan,warrior,stinger,mousesystems,sunmouse,microsoft,mshack,mouseman,intellimouse,mmwheel,iforce,h3600ts,stowawaykbd,ps2serkbd,twiddler,twiddlerjoy
X_OPTION_01 => text
X_OPTION_02 => text
X_OPTION_03 => text
X_OPTION_04 => text
X_OPTION_05 => text
X_OPTION_06 => text
X_OPTION_07 => text
X_OPTION_08 => text
X_OPTION_09 => text
X_OPTION_10 => text
X_OPTION_11 => text
X_OPTION_12 => text
X_RAMPERC => text
X_TOUCH_DEVICE => text
X_TOUCH_DRIVER => text
X_TOUCH_MAXX => text
X_TOUCH_MAXY => text
X_TOUCH_MINX => text
X_TOUCH_MINY => text
X_TOUCH_RTPDELAY => text
X_TOUCH_UNDELAY => text
X_VERTREFRESH => text
X_VIDEO_RAM => text
X_VIRTUAL => text" > rdp+ldm.config || fail "Creating rdp+ldm.config"
python control-center.py rdp+ldm.config || fail "Importing rdp-ldm.config to database"
/etc/init.d/apache2 start || fail "Starting apache2"

echo "# Visit
# http://$NETWORK.$CONTROL/ltsp-cluster-control/Admin/
#
# And set:
# 	LANG = $LTSP_LANG
# 	LDM_DIRECTX = True
# 	LDM_SERVER = %LOADBALANCER%
# 	LOCAL_APPS_MENU = True
# 	SCREEN_07 = ldm
# 	TIMESERVER = ntp.ubuntu.com
# 	XKBLAYOUT = $LANG_CODE
"

# HOWTO CREATE ABOVE MANUALLY
# Now on to the configuration of the root server.
# We need to access the web interface phppgadmin to add items that you need to appear in the lts.conf file for ltsp client customization.
# There are a few options in the database, but if you need to add a few more open a browser and go to http:///phppgadmin/
# 	Click the PostgreSQL link on the left and type your credentials.
# Username should be ltsp and the password is what you set above for the database.
# Once logged in, click the link labeled \"Tables\". In the right window, you will see a list of table names and buttons next to each name.
# 	Click the button labeled \"Browse\" next to the name \"attributesdef\".
# If everything went fine, the table contents are displayed, think of this as a spreadsheet.
# The column names should read, Actions, id, name, attributeclass, attributetype, mask, editable.
# Scroll your page to the end, you should be able to see 4 links: Back, Expand, Insert and Refresh.
# 	Click Insert and for \"name\" add LDM_XSESSION and leave everything else as is. 
#		Click \"Insert and Repeat\". For name add LDM_THEME and for attributetype put the number 1. 
#		Click \"Insert and Repeat\". Name is LDM_LIMIT_ONE_SESSION and attributetype is 1.
#		Click \"Insert and Repeat\". Name is LDM_LIMIT_ONE_SESSION_PROMPT and attributetype is 1.
#		Click \"Insert\". 
#	Get the id for LDM_THEME, LDM_LIMIT_ONE_SESSION, LDM_LIMIT_ONE_SESSION_PROMPT
#		Click tables again from the left.251 3
#		Click the browse button for table \"attributesdefdict\"
#		Click Insert. In the attributesdef_id field, add the id of LDM_THEME from the step above and the value add edubuntu
#		Click Insert and Repeat. Add id of LDM_THEME again and value ubuntu.
# Insert and Repeat. Add id of LDM_LIMIT_ONE_SESSION and the value True
# Insert and Repeat. Add id of LDM_LIMIT_ONE_SESSION and the value False
# Insert and Repeat. Add id of LDM_LIMIT_ONE_SESSION_PROMPT and the value True
# Insert and Repeat. Add id of LDM_LIMIT_ONE_SESSION_PROMPT and the value False
#		Click Insert.
# Done with editing the database. Now go to http:///ltsp-cluster-control/Admin/

echo "OK ENTER FOR REBOOT"; read x; reboot

