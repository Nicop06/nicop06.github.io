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

# Install the system

The VPS might be formatted in ext3. If that's the case, I would
recommend reformatting it in ext4 as it yields better performance. To do
that, you can use the following commands:

```
# umount /mnt/sdb1
# mkfs.ext4 /dev/sdb1
# mount /dev/sdb1 /mnt/sdb1
```

```
# wget ${mirror}/latest-stable/main/x86_64/apk-tools-static-${version}.apk
# tar -xzf apk-tools-static-*.apk
# ./sbin/apk.static -X ${mirror}/latest-stable/main -U --allow-untrusted --root ${chroot_dir} --initdb add alpine-base

# cp /etc/resolv.conf ${chroot_dir}/etc/
# mkdir -p ${chroot_dir}/root

# mkdir -p ${chroot_dir}/etc/apk
# echo "${mirror}/${branch}/main" > ${chroot_dir}/etc/apk/repositories

# mount -t proc none ${chroot_dir}/proc
# mount -o bind /sys ${chroot_dir}/sys
# mount -o bind /dev ${chroot_dir}/dev

# chroot ${chroot_dir} /bin/sh -l

# apk update
# setup-apkrepos
# setup-apkcache
# setup-hostname
# setup-interfaces
# setup-keymap
# setup-timezone

# setup-sshd
# setup-ntp

# passwd
```

# Make the ssytem bootable

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

rc-update add networking boot
rc-update add urandom boot

rc-update add acpid default
rc-update add hwdrivers sysinit
# rc-update add crond default

# apk add linux-grsec syslinux
# dd if=/usr/share/syslinux/mbr.bin of=/dev/sdb
# extlinux -i /boot

# vi /etc/update-extlinux.conf
# update-extlinux

# vi /etc/fstab

# exit
# reboot
```

[Alpine Linux]:        https://alpinelinux.org/
[glibc]:               https://www.gnu.org/software/libc/
[openrc]:              https://wiki.gentoo.org/wiki/Project:OpenRC
[systemd]:             https://www.freedesktop.org/wiki/Software/systemd/
[musl libc]:           https://www.musl-libc.org/
[grsec]:               https://grsecurity.net/
[busybox]:             https://busybox.net/about.html
[reddit_alpine_linux]: https://www.reddit.com/r/linux/comments/3mqqtx/alpine_linux_why_no_one_is_using_it/
[install_in_a_chroot]: https://wiki.alpinelinux.org/wiki/Installing_Alpine_Linux_in_a_chroot
[install_to_disk]:     https://wiki.alpinelinux.org/wiki/Install_to_disk
