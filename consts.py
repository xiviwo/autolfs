#!/usr/bin/env python
#1.0
from settings import *
import platform
arch=platform.machine()

if arch == 'i686':
	ABI=32
elif arch == 'x86_64':
	ABI=64
else:	
	print "Unknown platform error"
	raise 

lfsreplace = [

("IP=192.168.1.1",								"IP="+IP),
("GATEWAY=192.168.1.2",							"GATEWAY=" + GATEWAY),
("BROADCAST=192.168.1.255",						"BROADCAST=" + BROADCAST),
('KEYMAP="de-latin1"',							'KEYMAP="us"'),
('KEYMAP_CORRECTIONS="euro2"',					''),
('LEGACY_CHARSET="iso-8859-15"',				''),
('FONT="LatArCyrHeb-16 -m 8859-15"',			''),
("chown -v",										"chown -Rv"),
('DISTRIB_CODENAME="<your name here>"',			'DISTRIB_CODENAME="MAO"'),
("passwd lfs",									"echo 'lfs:ping' | chpasswd"),
("passwd root",									"echo 'root:ping' | chpasswd"),
("make test",									""),
("exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash",		"source /home/lfs/.bashrc"),
("set root=(hd0,2)",							"set root=(hd0,1)"),
("root=/dev/sda2 ro",							"root=/dev/" + guestdev1 + " ro"),
("./configure --prefix=/usr --enable-cxx",		"ABI=" + str(ABI) +" \n\t./configure --prefix=/usr --enable-cxx"),
("--with-libpam=no",							""),
("./configure --sysconfdir=/etc",				"./configure --sysconfdir=/etc --with-libpam=no --with-attr=no --with-selinux=no --with-audit=no --with-acl=no"),
("grub-install /dev/sda",						"grub-install /dev/" + guestdev ),
('groupadd lfs',									'	groupadd lfs || true'),
('useradd -s /bin/bash -g lfs -m -k /dev/null lfs',	'useradd -s /bin/bash -g lfs -m -k /dev/null lfs || true'),
('cat > ~/.bash_profile << "EOF"',				'cat > ' + LFSHOME + '/.bash_profile << "EOF"'),
('cat > ~/.bashrc << "EOF"',					'cat > ' + LFSHOME + '/.bashrc << "EOF"'),
('source ~/.bash_profile',						'source ' + LFSHOME + '/.bash_profile'),
('--enable-no-install-program=kill,uptime',		' --enable-no-install-program=kill,uptime   --disable-acl --without-selinux --disable-xattr'),
('--libexecdir=/usr/lib/glibc',					'--libexecdir=/usr/lib/glibc   --with-selinux=no --with-audit=no'),
("ln -sv ",										"ln -svf "),
]

blfsreplace = [
("<newuser>",						newuser + " || true"),
("<username>",						newuser),
("<password>",						passwd),
("ln -s ",							"ln -svf "),
("<new-password>",					passwd),
("ln -sv ",							"ln -svf "),	
		
]

lfsregx = [

(r"domain.*Domain.*",					"domain " + domain),
(r"nameserver.*primary.*",				"nameserver " + nameserver1),
(r"nameserver.*secondary.*",				"nameserver " + nameserver2),
(r'127\.0\.0\.1[^$]*HOSTNAME[^"\n]*',	"127.0.0.1 localhost\n" + IP + " " +  hostname),
(r'echo\s*"HOSTNAME.*',					'echo "HOSTNAME=' + hostname + '" > /etc/sysconfig/network'),
(r"/dev/\s*<xxx>\s*/\s*<fff>",			'/dev/' + guestdev1 + '     /            ' + guestfs + '    '),
(r"/dev/\s*<yyy>\s*swap\s*swap",		'/dev/' + guestdev2 + '    swap         swap'),
(r"export\s*LANG=.*",					"export LANG=en_US.utf8"),
(r"mkdir\s*-v",							"mkdir -pv"),
(r"mkdir\s*/",							"mkdir -pv /"),
(r"mount.*\$LFS",						'mount -v -t ext3 /dev/' + hostdev1 + ' $LFS'),
(r"/sbin/swapon\s*\-v\s*/dev/\s*<zzz>",	"/sbin/swapon -v /dev/" + hostdev2),
(r"make\s*LANG=.*menuconfig",			'make localmodconfig'),
(r"zoneinfo/\s*<xxx>",					"zoneinfo/Asia/Shanghai"),
(r"PAGE=\s*<paper_size>",				"PAGE=A4"),
(r"exec env -i.*/bin/bash",				"source /home/lfs/.bashrc"),

]


blfsregx = [

(r"mkdir\s*-v",							"mkdir -pv"),
(r"mkdir\s*/",							"mkdir -pv /"),
(r"mkdir\s*",							"mkdir -pv "),
(r"export\s*LANG=((?!\n).)*",			"export LANG=en_US.utf8"),
(r'"\s*<PREFIX>\s*"',					'"/opt"'),
(r"\s*</path/to/unzipped/files>\s*",	''),
(r'&&\n',								'\n'),
(r'^/sbin/mdadm((?!\n).)*',				''),
('exit\n',								''),
]



lfsignorelist = [
'dummy',
'libfoo',
'make check',
'localedef',
'tzselect',
'spawn ls',
'ulimit',
':options',
'logout',
'\nexit',
'shutdown -r',
'grub-img.iso',
'hdparm -I /dev/sda | grep NCQ',
'video4linux/',
'make -k check',
'make -k test',
'make test',
'udevadm test',
'test_summary',
'83-cdrom-symlinks.rules',
'cat /etc/udev/rules.d/70-persistent-net.rules',
'locale -a',
'locale name',
'glibc-check-log',
'su - lfs',
'grep FATAL check.log',
'tests passed',
'readelf',
'ABI=32 ./configure ...',
'make NON_ROOT_USERNAME=nobody check-root',
'su nobody -s /bin/bash ',
 '-c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check"',
'gmp-check-log',
'mkdir -v $LFS/usr',
'mount -v -t ext3 /dev/<yyy> $LFS/usr',
'make RUN_EXPENSIVE_TESTS=yes check',
'cd /tmp &&',
'exec /tools/bin/bash --login +h',
'sed -i \'s/if ignore_if; then continue; fi/#&/\' udev-lfs-197-2/init-net-rules.sh',
' /etc/udev/rules.d/70-persistent-net.rules',
'chown -Rv nobody .',
'exec /bin/bash --login +h',
'/tools/bin/bash --login',
'unset pathremove pathprepend pathappend',
'mkdir -pv /etc/pam.d/',
'patch -Np1 -i ../Python-2.7.3-bsddb_fix-1.patch &&',
'tar xvf krb5-1.11.2.tar.gz',
'cd krb5-1.11.2',
"ABI=" + str(ABI),
'install-catalog --add /etc/sgml/sgml-docbook-dtd-3.1.cat \\',
'    /etc/sgml/sgml-docbook.cat',
'sshfs THINGY:~ ~/MOUNTPATH',
'fusermount -u ~/MOUNTPATH',
'tripwire --init',
"egrep '^flags.*(vmx|svm)' /proc/cpuinfo",
'export LIBRARY_PATH=/opt/xorg/lib',
"export MAKEFLAGS='-j 2'",
"make -j2",
'bash tests/run.sh',
'pushd testsuite',
"sed -i -e 's|exec which sleep|exec echo /tools/bin/sleep|' \\",
'.exp',
'popd',
"write_cd_rules",
'mount -vt devpts devpts $LFS/dev/pts -o gid=5,mode=620',
'mount -vt proc proc $LFS/proc',
'mount -vt sysfs sysfs $LFS/sys',
'mount -vt tmpfs tmpfs $LFS/run',
'mount -v --bind /dev $LFS/dev',
'make -j4 check'
]

PostrunRegex = [
'^\s*pwconv.*',
'^\s*grpconv.*',
"^\s*echo 'root:.*",
'^\s*grub-install .*',
'^\s*build/udevadm hwdb --update.*',
'^\s*chgrp.*',
'^\s*chmod.*',
'^\s*chown.*',
'^\s*gtk-update-icon-cache.*',
'^\s*update-desktop-database.*',
'^\s*usermod.*',
'^\s*useradd.*',
'^\s*groupadd.*',
'^\s*ssh-keygen.*',
'^\s*unset public_key.*',
#'^\s*rndc-confgen.*',
'^\s*mknod.*',
'^\s*/etc/rc.d/init.d/.*',
'^exim -v -bi',
'^/usr/sbin/.*',
'.*install.*-o.*-g.*',
'.*~/.*',
'.*>>.*',
'^mysql.*',
'^create-cracklib-dict.*',
'(^kbd.*|^kadmin.*|^kinit.*|^klist.*|^ktutil.*)',
'(^twadmin.*|^tripwire.*)',
'^sysctl.*',
'^urxvtd .*',

]
blfsignorelist = [
'exit\n',
'/samsung-9/d',
r'make[^/\n]*check((?!\n).)*',
r'make[^/\n]*test((?!\n).)*',
'bash -e',
'<report-name.twr>',
'convmv((?!\n).)*',
'</path/to/unzipped/files>',
'lp -o number-up=2 <filename>',
'gpg --verify ((?!\n).)*',
'gpg gpg --keyserver pgp.mit.edu((?!\n).)*',
'glxinfo',
'mkinitramfs \[((?!\n).)*',
'gpg --keyserver pgp.mit.edu((?!\n).)*',
'ssh REMOTE_HOSTNAME((?!\n).)*',
'rsync -avzcP((?!\n).)*',
'vim -c ((?!\n).)*',
'qemu-img create -f qcow2 vdisk.img 10G',
'qemu -enable-kvm',
'((?!\n).)*~/MOUNTPATH',
'(^kbd((?!\n).)*|^kadmin((?!\n).)*|^kinit((?!\n).)*|^klist((?!\n).)*|^ktutil((?!\n).)*)',
'menuentry.*}|cat > /etc/X11/xorg.conf.d/.*EOF',
'install -v -d -m755 /usr/share/fonts/dejavu.*/usr/share/fonts/dejavu',
]

SpecsSkipList = [
'preparing-virtual',
'adjusting',
'cleaning-up',
'entering',
'package-management',
'rebooting',
'stripping',
'conventions-used-in-this-book',
'notes-on-building-software',
'about-devices',
'about-raid'

]
perl_pack_lists= "perl_pack_lists"
mfile = "/port/mirrorfile"
baselink="http://mirrors-usa.go-parts.com/blfs/"

