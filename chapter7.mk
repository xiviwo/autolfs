
General_Network_Configuration:
	
cat /etc/udev/rules.d/70-persistent-net.rules	
cd /etc/sysconfig/
cat > ifconfig.eth0 << "EOF"
ONBOOT=yes
IFACE=eth0
SERVICE=ipv4-static
IP=192.168.1.1
GATEWAY=192.168.1.2
PREFIX=24
BROADCAST=192.168.1.255
EOF
	
cat > /etc/resolv.conf << "EOF"
	# Begin /etc/resolv.conf

domain <Your Domain Name>
nameserver 	<IP address of your primary nameserver>
nameserver 	<IP address of your secondary nameserver>

# End /etc/resolv.conf
EOF


Customizing_the_etc_hosts_File:
	
cat > /etc/hosts << "EOF"
	# Begin /etc/hosts (network card version)

127.0.0.1 localhost
<192.168.1.1> 	<HOSTNAME.example.org> 	[alias1] [alias2 ...]

# End /etc/hosts (network card version)
EOF
	
cat > /etc/hosts << "EOF"
	# Begin /etc/hosts (no network card version)

127.0.0.1 <HOSTNAME.example.org> 	<HOSTNAME> localhost

# End /etc/hosts (no network card version)
EOF


Creating_Custom_Symlinks_to_Devices:
	
udevadm test /sys/block/hdd	
sed -i -e 's/"write_cd_rules"/"write_cd_rules 	mode"/' \
    /etc/udev/rules.d/83-cdrom-symlinks.rules
	
udevadm info -a -p /sys/class/video4linux/video0	
cat > /etc/udev/rules.d/83-duplicate_devs.rules << "EOF"

# Persistent symlinks for webcam and tuner
KERNEL=="video*", ATTRS{idProduct}=="1910", ATTRS{idVendor}=="0d81", \
    SYMLINK+="webcam"
KERNEL=="video*", ATTRS{device}=="0x036f", ATTRS{vendor}=="0x109e", \
    SYMLINK+="tvtuner"

EOF


LFS_Bootscripts_20130515:
	
make install

How_Do_These_Bootscripts_Work_:
	
cat > /etc/inittab << "EOF"
# Begin /etc/inittab

id:3:initdefault:

si::sysinit:/etc/rc.d/init.d/rc S

l0:0:wait:/etc/rc.d/init.d/rc 0
l1:S1:wait:/etc/rc.d/init.d/rc 1
l2:2:wait:/etc/rc.d/init.d/rc 2
l3:3:wait:/etc/rc.d/init.d/rc 3
l4:4:wait:/etc/rc.d/init.d/rc 4
l5:5:wait:/etc/rc.d/init.d/rc 5
l6:6:wait:/etc/rc.d/init.d/rc 6

ca:12345:ctrlaltdel:/sbin/shutdown -t1 -a -r now

su:S016:once:/sbin/sulogin

1:2345:respawn:/sbin/agetty --noclear tty1 9600
2:2345:respawn:/sbin/agetty tty2 9600
3:2345:respawn:/sbin/agetty tty3 9600
4:2345:respawn:/sbin/agetty tty4 9600
5:2345:respawn:/sbin/agetty tty5 9600
6:2345:respawn:/sbin/agetty tty6 9600

# End /etc/inittab
EOF


Configuring_the_system_hostname:
	
echo "HOSTNAME=	<lfs>" > /etc/sysconfig/network


Configuring_the_setclock_Script:
	
cat > /etc/sysconfig/clock << "EOF"
# Begin /etc/sysconfig/clock

UTC=1

# Set this to any options you might need to give to hwclock,
# such as machine hardware clock type for Alphas.
CLOCKPARAMS=

# End /etc/sysconfig/clock
EOF


Configuring_the_Linux_Console:
	
cat > /etc/sysconfig/console << "EOF"
# Begin /etc/sysconfig/console

KEYMAP="pl2"
FONT="lat2a-16 -m 8859-2"

# End /etc/sysconfig/console
EOF
	
cat > /etc/sysconfig/console << "EOF"
# Begin /etc/sysconfig/console

KEYMAP="de-latin1"
KEYMAP_CORRECTIONS="euro2"
FONT="lat0-16 -m 8859-15"

# End /etc/sysconfig/console
EOF
	
cat > /etc/sysconfig/console << "EOF"
# Begin /etc/sysconfig/console

UNICODE="1"
KEYMAP="bg_bds-utf8"
FONT="LatArCyrHeb-16"

# End /etc/sysconfig/console
EOF
	
cat > /etc/sysconfig/console << "EOF"
# Begin /etc/sysconfig/console

UNICODE="1"
KEYMAP="bg_bds-utf8"
FONT="cyr-sun16"

# End /etc/sysconfig/console
EOF
	
cat > /etc/sysconfig/console << "EOF"
# Begin /etc/sysconfig/console

UNICODE="1"
KEYMAP="de-latin1"
KEYMAP_CORRECTIONS="euro2"
LEGACY_CHARSET="iso-8859-15"
FONT="LatArCyrHeb-16 -m 8859-15"

# End /etc/sysconfig/console
EOF


The_Bash_Shell_Startup_Files:
	
locale -a	
LC_ALL=	<locale name> locale charmap
	
LC_ALL=<locale name> locale language
LC_ALL=<locale name> locale charmap
LC_ALL=<locale name> locale int_curr_symbol
LC_ALL=<locale name> locale int_prefix	
cat > /etc/profile << "EOF"
	# Begin /etc/profile

export LANG=<ll>_<CC>.<charmap><@modifiers>

# End /etc/profile
EOF


Creating_the_etc_inputrc_File:
	
cat > /etc/inputrc << "EOF"
# Begin /etc/inputrc
# Modified by Chris Lynn <roryo@roryo.dynup.net>

# Allow the command prompt to wrap to the next line
set horizontal-scroll-mode Off

# Enable 8bit input
set meta-flag On
set input-meta On

# Turns off 8th bit stripping
set convert-meta Off

# Keep the 8th bit for display
set output-meta On

# none, visible or audible
set bell-style none

# All of the following map the escape sequence of the value
# contained in the 1st argument to the readline specific functions
"\eOd": backward-word
"\eOc": forward-word

# for linux console
"\e[1~": beginning-of-line
"\e[4~": end-of-line
"\e[5~": beginning-of-history
"\e[6~": end-of-history
"\e[3~": delete-char
"\e[2~": quoted-insert

# for xterm
"\eOH": beginning-of-line
"\eOF": end-of-line

# for Konsole
"\e[H": beginning-of-line
"\e[F": end-of-line

# End /etc/inputrc
EOF

SettingUpSystemBootscripts : General_Network_Configuration Customizing_the_etc_hosts_File Creating_Custom_Symlinks_to_Devices LFS_Bootscripts_20130515 How_Do_These_Bootscripts_Work_ Configuring_the_system_hostname Configuring_the_setclock_Script Configuring_the_Linux_Console The_Bash_Shell_Startup_Files Creating_the_etc_inputrc_File 