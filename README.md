Ginger Linux
=======

Hello!
This is Ginger linux!

- This is a linux distribution based on LFS(linux from scratch), so LFS experience is expected before further readering.
- It's not a linux distribution for newbie. Please don't complain.


Installation
=======
Glossary:
Host: the system you are working on.

Guest: the system you are going to install.

Assumption:
- Host have development tool installed, like GCC, Binutils, automake, autoconf,etc.
- Host have fine internet connection
- Guest drive(/dev/sdb or /dev/vdb) is partitioned properly and formated in ext2/3/4.
- Guest dirve is mounted on /mnt/lfs(Must)
- Python is ready, and must below python3(Python 3 is not yet test).
- python-lxml on host is installed,(or yum install python-lxml)

Install from Sources:
- clone git
- `python bootstrap.py`
- `cd /mnt/lfs/bootstrap`
- `sudo make`
- After a long long time of build, it will end.
- You should chroot to /mnt/lfs and cd /sources and reconfigure Linux kernel according to your hardware/vm
- Reboot and try to boot into the newly-built linux !
- Issue command: `ginger xfce/gnome/kde` to install the xwindow out of your favor!
- Ask, trouble-shoot, enjoy and contribute!

Build Rpm and install from RPM:
- clone git
- `python gen_rpm.py lfs` to generate specs file for lfs, similarly, `python gen_rpm.py blfs` to generate for blfs.
- `rpmbuild -ba *.spec` to build rpm packages
- `rpm -ivh --replacepkgs  --replacefiles --nodeps --root /mnt/lfs *.rpm` to bootstrap the new system.
- 
Disclaimer
=======
- This distribution is closely connected to LFS, as LFS is not strictly linear, so the script/instruction is not guaranteed to work.
- That is why I can this distribution ginger, and it's your responsbility to ask, or figure out why something doesn't work out. But, all throught the hassle and frustration, you will grow quickly, learn a lot and enjoy finally. That is why this distribution comes into exists.
- No warranty and guaranteed is assumed.
