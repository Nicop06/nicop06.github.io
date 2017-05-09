---
title:  "How to install Alpine Linux on OVH"
tags:   VPS, linux
---

I recently wanted to try Alpine Linux on my VPS. Up until now, I have only
used in in LXC containers and local VM. However, this is not possible on
OVH for their VPS offer as they only have a limited offer of images (it is
possible on their Cloud offer).

# About Alpine Linux

[Alpine Linux][] is a lightweight distribution using [musl libc][],
a lightweight alternative to [glibc][], and [openrc][] as an alternative
to [systemd][] maintained by Gentoo developers. It also uses [grsec][] kernel
patches and [busybox][] instead of a complete GNU core utilities. It has its
own package manager with a very simple format for creating packages similar to
ArchLinux PKGBUILD.

This distribution is not for everyone as this is very basic and a lot of
things won't work as expected. For instance, you won't be able to use man
out of the box, and lspci will give you a rather cryptic output. But you
will have a working Linux box with a very small memory and hard drive
footprint, so you can use more resources for your applications and less
for the system.

You can find more compelling arguments on [this reddit
thread][reddit_alpine_linux].

# Boot in recovery in OVH

You will first need to boot your VPS in recovery mode. On the admin page
of your VPS, click on reboot my VPS, and tick the *Reboot in rescue mode*
option.

![Reboot in rescue mode](/images/ovh-reboot-in-rescue-mode.png)

This step takes a while (about 5 minutes), so grab a cup of coffee or do
something else. Once it's finished, you will receive an email with the
parameters to connect to your server to it via ssh.

# Setup the disks

The VPS might be formatted in ext3. If that's the case, I would
recommend reformatting it in ext4 as it yields better performance. To do
that, you can use the following commands:

```
# umount /mnt/sdb1
# mkfs.ext4 /dev/sdb1
# mount /mnt/sdb1
```

If the [64bit feature of the ext4 filesystem][64bit_ext4] is enabled, you will
need to disable it as [syslinux doesn't support it][syslinux_ext4]. This should
be the case for OVH VPS, but just in case here are the commands to check and
disable this feature.

```
# dumpe2fs /dev/sdb1 | grep 64bit
Filesystem features:      (...) 64bit (...)
# resize2fs -s /dev/sdb1
```

# Install the system

This procedure is mostly inspired from this page from the Alpine Linux wiki for
[chroot installation][]. I added some steps that are required for a fully
functional system.

First, you need to choose a mirror from [this page][alpine_mirrors]. If like
mine your VPS is hosted in France, the mirror from Jussieu university is pretty
good.

```
# export mirror=http://distrib-coffee.ipsl.jussieu.fr/pub/linux/alpine/alpine/
# export chroot_dir=/mnt/sdb1
```

Then, you need to download `apk` binary, Alpine's package manager. The version
variable can be found on [this page][apk_tools_version]. For instance, when I
wrote this post, it was 2.6.8-r2 for Alpine v3.5 (the latest stable).

```
# export version=2.6.8-r2
# wget ${mirror}/latest-stable/main/x86_64/apk-tools-static-${version}.apk
# tar -xzf apk-tools-static-*.apk
# ./sbin/apk.static -X ${mirror}/latest-stable/main -U --allow-untrusted --root ${chroot_dir} --initdb add alpine-base
```

Then, you will need to do create and copy some files on the newly created
system before chroot. You should replace the branch by the latest version of
Alpine.

```
# export branch=v3.5
# cp /etc/resolv.conf ${chroot_dir}/etc/
# echo "${mirror}/${branch}/main" > ${chroot_dir}/etc/apk/repositories
```

You will also need to mount some pseudo-filesystems.

```
# mount -t proc none ${chroot_dir}/proc
# mount -o bind /sys ${chroot_dir}/sys
# mount -o bind /dev ${chroot_dir}/dev
```

You are now ready to chroot into your VPS and perform the system setup.

```
# chroot ${chroot_dir} /bin/sh -l
```

Now, you can do some setup. This step is pretty straightforward, you just have
to follow the instructions. You will setup the repositories, hostname, keymap
and timezone.

```
# apk update
# setup-apkrepos
# setup-apkcache
# setup-hostname
# setup-keymap
# setup-timezone
```

The interface setup is a bit more tricky. You will need to perform a fully
manual setup as the automatic one will not fill the right information. Here how
your set should look like assuming your IP address, as seen in the is
information is present on the VPS admin panel, is 12.34.56.78:

```
# cat /etc/network/interfaces 
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
  address 12.34.56.78
  netmask 255.255.255.255
  broadcast 12.34.56.78
  post-up route add 12.34.56.1 dev eth0
  post-up route add default gw 12.34.56.1
  post-down route del default gw 12.34.56.1
  post-down route del 12.34.56.1 dev eth0
```

The `post-up` and `post-down` options are used to setup the gateway. Please
note that the `gateway` keyword is supported by Alpine but does not work on
OVH, so a manual gateway setup is necessary. You should also check the actual
value for the gateway with the following command: 

```
# ip route
```

Finally, you should install an ssh and ntp server. The suggested one works
well, you you should not change it.

```
# setup-sshd
# setup-ntp
```

You will also need to choose a root password. You can also create some users
now. Please note that ssh is disabled by default for root user, so you need
another user or to enable root ssh access.

```
# passwd
```

# Enable some services for openrc

By default, no service is enabled in openrc, making the system unbootable. You
should enable these services as suggested in the wiki.

```
rc-update add devfs sysinit
rc-update add dmesg sysinit
rc-update add mdev sysinit
rc-update add hwclock boot
rc-update add modules boot
rc-update add sysctl boot
rc-update add hostname boot
rc-update add bootmisc boot
rc-update add syslog boot
rc-update add mount-ro shutdown
rc-update add killprocs shutdown
rc-update add savecache shutdown
```

You will also need those services, which are not mentioned in the Alpine wiki
but are installed by the Alpine installation iso.

```
rc-update add networking boot
rc-update add urandom boot
rc-update add acpid default
rc-update add hwdrivers sysinit
rc-update add crond default
```

# Make the system bootable

Now, you will need a kernel and a bootloader. These steps are described in
[this wiki page][install_to_disk].

```
# apk add linux-grsec syslinux
```

Now, you can install the bootloader (syslinux) on your hard drive.

```
# dd bs=440 count=1 if=/usr/share/syslinux/mbr.bin of=/dev/sdb
# extlinux -i /boot
```

You should also modify the syslinux configuration, especially the `root`
filesystem and the `modules` variable (to add ext4):

```
# blkid /dev/sdb1
/dev/sdb1: UUID="730e779d-8738-4405-97a2-8fa6bc005747" TYPE="ext4"
# export root=UUID=730e779d-8738-4405-97a2-8fa6bc005747
# sed -i -e "s:^root=.*:root=$root:" /etc/update-extlinux.conf
# sed -i -e "s:^modules=.*:modules=sd-mod,usb-storage,ext4:" /etc/update-extlinux.conf
# update-extlinux
```

Finally, you should add your root device to the fstab file. It might be
necessary to regenerate the initramfs.

```
# echo "$root / ext4 rw,relatime,data=ordered 0 0" > /etc/fstab
# mkinitfs $(ls /lib/modules)
```

Finally, you can reboot and enjoy your new lightweight and fully functional
Alpine Linux VPS. You can now reboot in normal mode using OVH interface. The
first boot might take a while as your ssh key is being created.

# Final thoughts

This procedure might work in any Cloud provider provided that you have some
sort of rescue mode available. While installing a server this way is a bit
tedious and not recommended for large scale deployment, it is always
interesting to install from scratch as it teaches you of what is necessary for
your system to run. Alpine Linux is a very simple distribution, so having a
fully functional system almost identical to what the installation ISO provides
you is quite simple.

Here are some resources to get your started with Alpine:

* [Using APK](https://wiki.alpinelinux.org/wiki/Alpine_Linux_package_management)
* [Search packages](https://pkgs.alpinelinux.org/packages)
* [Some advances installation and post-install guides](https://wiki.alpinelinux.org/wiki/Installation)

[Alpine Linux]:        https://alpinelinux.org/
[glibc]:               https://www.gnu.org/software/libc/
[openrc]:              https://wiki.gentoo.org/wiki/Project:OpenRC
[systemd]:             https://www.freedesktop.org/wiki/Software/systemd/
[musl libc]:           https://www.musl-libc.org/
[grsec]:               https://grsecurity.net/
[busybox]:             https://busybox.net/about.html
[64bit_ext4]:          https://ext4.wiki.kernel.org/index.php/Ext4_Disk_Layout#Blocks
[syslinux_ext4]:       http://www.syslinux.org/wiki/index.php?title=Filesystem#ext
[reddit_alpine_linux]: https://www.reddit.com/r/linux/comments/3mqqtx/alpine_linux_why_no_one_is_using_it/
[chroot installation]: https://wiki.alpinelinux.org/wiki/Installing_Alpine_Linux_in_a_chroot
[alpine_mirrors]:      http://nl.alpinelinux.org/alpine/MIRRORS.txt
[apk_tools_version]:   https://pkgs.alpinelinux.org/packages?name=apk-tools-static&branch=&repo=&arch=&maintainer=
[install_to_disk]:     https://wiki.alpinelinux.org/wiki/Install_to_disk
