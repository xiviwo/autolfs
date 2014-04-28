Ginger Linux
=======

Hello!
This is Ginger linux!

1.This is a linux distribution based on LFS(linux from scratch), so LFS experience is expected before further readering.
2.It's not a linux distribution for newbie. Please don't complain.


Installation
=======
Glossary:
Host: the system you are working on.
Guest: the system you are going to install.

Assumption:
1.Host have development tool installed, like GCC, Binutils, automake, autoconf,etc.
2.Host have fine internet connection
3.Guest drive(/dev/sdb or /dev/vdb) is partitioned properly and formated in ext2/3/4.
4.Guest dirve is mounted on /mnt/lfs(Must)
5.Python is ready, and must below python3(Python 3 is not yet test).
6.python-lxml on host is installed,(or yum install python-lxml)

Install steps:
1.clone git
2.python bootstrap.py
3.cd /mnt/lfs/bootstrap
4.sudo make
5.After a long long time of build, it will end.
6.You should chroot to /mnt/lfs and cd /sources and reconfigure Linux kernel according to your hardware/vm
7.Reboot and try to boot into the newly-built linux !
8.Issue command: ginger xfce/gnome/kde to install the xwindow out of your favor!
9.Ask, trouble-shoot, enjoy and contribute!

