LFS=/mnt/lfs
SOURCES=$(LFS)/sources
SettingUpSystemBootscripts : General-Network-Configuration Customizing-the-etc-hosts-File Creating-Custom-Symlinks-to-Devices LFS-Bootscripts-20130515 How-Do-These-Bootscripts-Work- Configuring-the-system-hostname Configuring-the-setclock-Script Configuring-the-Linux-Console The-Bash-Shell-Startup-Files Creating-the-etc-inputrc-File 
General-Network-Configuration:
	cd /etc/sysconfig/
	cat > ifconfig.eth0 << "EOF"
	ONBOOT=yes
	IFACE=eth0
	SERVICE=ipv4-static
	IP=192.168.136.13
	GATEWAY=192.168.136.2
	PREFIX=24
	BROADCAST=192.168.136.255
	EOF
	cat > /etc/resolv.conf << "EOF"
	# Begin /etc/resolv.conf
	domain ibm.com
	nameserver 	<IP address of your primary nameserver>
	nameserver 	<IP address of your secondary nameserver>
	# End /etc/resolv.conf
	EOF

Customizing-the-etc-hosts-File:
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

Creating-Custom-Symlinks-to-Devices:
	cd $(SOURCES)/creating-/ && sed -i -e 's/"write_cd_rules"/"write_cd_rules 	mode"/' \
	cat > /etc/udev/rules.d/83-duplicate_devs.rules << "EOF"
	# Persistent symlinks for webcam and tuner
	KERNEL=="video*", ATTRS{idProduct}=="1910", ATTRS{idVendor}=="0d81", \
	SYMLINK+="webcam"
	KERNEL=="video*", ATTRS{device}=="0x036f", ATTRS{vendor}=="0x109e", \
	SYMLINK+="tvtuner"
	EOF

LFS-Bootscripts-20130515:
	cd $(SOURCES) && rm -rf lfs-bootscripts-20130515
	cd $(SOURCES) && rm -rf lfs-bootscripts-build
	cd $(SOURCES) && mkdir -pv lfs-bootscripts-20130515
	cd $(SOURCES) && tar xvf lfs-bootscripts-20130515.tar.bz2 -C lfs-bootscripts-20130515  --strip-components 1
	cd $(SOURCES)/lfs-bootscripts-20130515/ && make install

How-Do-These-Bootscripts-Work-:
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

Configuring-the-system-hostname:
	echo "HOSTNAME=	<lfs>" > /etc/sysconfig/network

Configuring-the-setclock-Script:
	cat > /etc/sysconfig/clock << "EOF"
	# Begin /etc/sysconfig/clock
	UTC=1
	# Set this to any options you might need to give to hwclock,
	# such as machine hardware clock type for Alphas.
	CLOCKPARAMS=
	# End /etc/sysconfig/clock
	EOF

Configuring-the-Linux-Console:
	cat > /etc/sysconfig/console << "EOF"
	# Begin /etc/sysconfig/console
	KEYMAP="pl2"
	FONT="lat2a-16 -m 8859-2"
	# End /etc/sysconfig/console
	EOF
	cat > /etc/sysconfig/console << "EOF"
	# Begin /etc/sysconfig/console
	KEYMAP="us"
	
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
	KEYMAP="us"
	
	
	
	# End /etc/sysconfig/console
	EOF

The-Bash-Shell-Startup-Files:
	cat > /etc/profile << "EOF"
	# Begin /etc/profile
	export LANG=en_US.utf8
	# End /etc/profile
	EOF

Creating-the-etc-inputrc-File:
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
