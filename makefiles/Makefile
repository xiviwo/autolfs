LFS=/mnt/lfs
SHELL 	= /bin/bash
SOURCES = $(LFS)/sources
BOLD    = "\e[0;1m"
RED     = "\e[1;31m"
GREEN   = "\e[0;32m"
ORANGE  = "\e[0;33m"
BLUE    = "\e[1;34m"
WHITE   = "\e[00m"
YELLOW  = "\e[1;33m"

OFF     = "\e[0m"
REVERSE = "\e[7m"

tab_    = '	'
nl_     = ''

define echo_message
  @echo -e $(BOLD)--------------------------------------------------------------------------------
  @echo -e $(BOLD)$(1) target $(BLUE)$@$(BOLD)$(WHITE)
endef
all :   chapter4 chapter5 chapter6 chapter7 chapter8 chapter9
chapter4 : 400-about-lfs 401-creating-the-lfs-tools-directory 402-adding-the-lfs-user 403-setting-up-the-environment 404-about-sbus 
chapter5 : 502-general-compilation-instructions 503-binutils 504-gcc 505-linux 506-glibc 507-libstdc 508-binutils 509-gcc 510-tcl 511-expect 512-dejagnu 513-check 514-ncurses 515-bash 516-bzip2 517-coreutils 518-diffutils 519-file 520-findutils 521-gawk 522-gettext 523-grep 524-gzip 525-m4 526-make 527-patch 528-perl 529-sed 530-tar 531-texinfo 532-xz 533-stripping 534-changing-ownership 
chapter6 : 601-preparing-virtual-kernel-file-systems 602-package-management 603-entering-the-chroot-environment 604-creating-directories 605-creating-essential-files-and-symlinks 606-linux 607-man-pages 608-glibc 609-adjusting-the-toolchain 610-zlib 611-file 612-binutils 613-gmp 614-mpfr 615-mpc 616-gcc 617-sed 618-bzip2 619-pkg-config 620-ncurses 621-shadow 622-util-linux 623-psmisc 624-procps-ng 625-e2fsprogs 626-coreutils 627-iana-etc 628-m4 629-bison 630-grep 631-readline 632-bash 633-bc 634-libtool 635-gdbm 636-inetutils 637-perl 638-autoconf 639-automake 640-diffutils 641-gawk 642-findutils 643-flex 644-gettext 645-groff 646-xz 647-grub 648-less 649-gzip 650-iproute2 651-kbd 652-kmod 653-libpipeline 654-make 655-man-db 656-patch 657-sysklogd 658-sysvinit 659-tar 660-texinfo 661-udev 662-vim 664-stripping-again 665-cleaning-up 
chapter7 : 701-general-network-configuration 702-customizing-the-etc-hosts-file 704-creating-custom-symlinks-to-devices 705-lfs-bootscripts 706-how-do-these-bootscripts-work 707-configuring-the-system-hostname 708-configuring-the-setclock-script 709-configuring-the-linux-console 712-the-bash-shell-startup-files 713-creating-the-etc-inputrc-file 
chapter8 : 801-creating-the-etc-fstab-file 802-linux 803-using-grub-to-set-up-the-boot-process 
chapter9 : 900-the-end 902-rebooting-the-system 

400-about-lfs : 
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

401-creating-the-lfs-tools-directory : 400-about-lfs
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

402-adding-the-lfs-user : 401-creating-the-lfs-tools-directory
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

403-setting-up-the-environment : 402-adding-the-lfs-user
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

404-about-sbus : 403-setting-up-the-environment
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

502-general-compilation-instructions : 404-about-sbus
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

503-binutils : 502-general-compilation-instructions
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

504-gcc : 503-binutils
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

505-linux : 504-gcc
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

506-glibc : 505-linux
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

507-libstdc : 506-glibc
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

508-binutils : 507-libstdc
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

509-gcc : 508-binutils
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

510-tcl : 509-gcc
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

511-expect : 510-tcl
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

512-dejagnu : 511-expect
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

513-check : 512-dejagnu
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

514-ncurses : 513-check
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

515-bash : 514-ncurses
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

516-bzip2 : 515-bash
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

517-coreutils : 516-bzip2
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

518-diffutils : 517-coreutils
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

519-file : 518-diffutils
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

520-findutils : 519-file
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

521-gawk : 520-findutils
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

522-gettext : 521-gawk
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

523-grep : 522-gettext
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

524-gzip : 523-grep
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

525-m4 : 524-gzip
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

526-make : 525-m4
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

527-patch : 526-make
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

528-perl : 527-patch
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

529-sed : 528-perl
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

530-tar : 529-sed
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

531-texinfo : 530-tar
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

532-xz : 531-texinfo
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

533-stripping : 532-xz
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

534-changing-ownership : 533-stripping
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

601-preparing-virtual-kernel-file-systems : 534-changing-ownership
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

602-package-management : 601-preparing-virtual-kernel-file-systems
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

603-entering-the-chroot-environment : 602-package-management
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

604-creating-directories : 603-entering-the-chroot-environment
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

605-creating-essential-files-and-symlinks : 604-creating-directories
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

606-linux : 605-creating-essential-files-and-symlinks
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

607-man-pages : 606-linux
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

608-glibc : 607-man-pages
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

609-adjusting-the-toolchain : 608-glibc
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

610-zlib : 609-adjusting-the-toolchain
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

611-file : 610-zlib
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

612-binutils : 611-file
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

613-gmp : 612-binutils
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

614-mpfr : 613-gmp
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

615-mpc : 614-mpfr
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

616-gcc : 615-mpc
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

617-sed : 616-gcc
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

618-bzip2 : 617-sed
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

619-pkg-config : 618-bzip2
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

620-ncurses : 619-pkg-config
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

621-shadow : 620-ncurses
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

622-util-linux : 621-shadow
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

623-psmisc : 622-util-linux
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

624-procps-ng : 623-psmisc
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

625-e2fsprogs : 624-procps-ng
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

626-coreutils : 625-e2fsprogs
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

627-iana-etc : 626-coreutils
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

628-m4 : 627-iana-etc
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

629-bison : 628-m4
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

630-grep : 629-bison
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

631-readline : 630-grep
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

632-bash : 631-readline
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

633-bc : 632-bash
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

634-libtool : 633-bc
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

635-gdbm : 634-libtool
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

636-inetutils : 635-gdbm
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

637-perl : 636-inetutils
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

638-autoconf : 637-perl
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

639-automake : 638-autoconf
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

640-diffutils : 639-automake
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

641-gawk : 640-diffutils
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

642-findutils : 641-gawk
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

643-flex : 642-findutils
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

644-gettext : 643-flex
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

645-groff : 644-gettext
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

646-xz : 645-groff
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

647-grub : 646-xz
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

648-less : 647-grub
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

649-gzip : 648-less
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

650-iproute2 : 649-gzip
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

651-kbd : 650-iproute2
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

652-kmod : 651-kbd
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

653-libpipeline : 652-kmod
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

654-make : 653-libpipeline
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

655-man-db : 654-make
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

656-patch : 655-man-db
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

657-sysklogd : 656-patch
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

658-sysvinit : 657-sysklogd
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

659-tar : 658-sysvinit
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

660-texinfo : 659-tar
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

661-udev : 660-texinfo
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

662-vim : 661-udev
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

664-stripping-again : 662-vim
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

665-cleaning-up : 664-stripping-again
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

701-general-network-configuration : 665-cleaning-up
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

702-customizing-the-etc-hosts-file : 701-general-network-configuration
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

704-creating-custom-symlinks-to-devices : 702-customizing-the-etc-hosts-file
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

705-lfs-bootscripts : 704-creating-custom-symlinks-to-devices
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

706-how-do-these-bootscripts-work : 705-lfs-bootscripts
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

707-configuring-the-system-hostname : 706-how-do-these-bootscripts-work
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

708-configuring-the-setclock-script : 707-configuring-the-system-hostname
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

709-configuring-the-linux-console : 708-configuring-the-setclock-script
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

712-the-bash-shell-startup-files : 709-configuring-the-linux-console
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

713-creating-the-etc-inputrc-file : 712-the-bash-shell-startup-files
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

801-creating-the-etc-fstab-file : 713-creating-the-etc-inputrc-file
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

802-linux : 801-creating-the-etc-fstab-file
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

803-using-grub-to-set-up-the-boot-process : 802-linux
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

900-the-end : 803-using-grub-to-set-up-the-boot-process
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@

902-rebooting-the-system : 900-the-end
	@$(call echo_message, Building)
	@$(SHELL) scripts/$@.sh > logs/$@.log 2>&1 
	@touch $@
