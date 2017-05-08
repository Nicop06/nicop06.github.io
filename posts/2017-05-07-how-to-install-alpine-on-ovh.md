---
title:  "How to install Alpine Linux on OVH"
tags:   VPS, linux
---

I recently wanted to try Alpine Linux on my VPS. Up until now, I have only
used in in LXC containers and local VM. However, this is not possible on
OVH for their VPS offer as they only have a limited offer of images (it is
possible on their Cloud offer).

# About Alpine Linux

[Alpine Linux][] is a lightweight distribution using [musl libc][], a complete
rewrite of the glibc 4 times smaller and aimed at correctness. Among other
things, it uses [grsec][] kernel patches and [busybox][] instead of a complete
GNU core utilities. They also completely rewrote their own package manager with
a very simple format for creating packages similar to ArchLinux PKGBUILD.

This is not for everyone as this is very basic and a lot of thinks won't work
as expected. For instance, you won't be able to use man out of the box, and
lspci will give you unreadable output. But you will have a working Linux box
using under 50MB or RAM with OpensSSH and an NTP server and 300MB of disk space
for a base installation.

You can find more compelling arguments on [this reddit
thread][alpine_linux_why_no_one_is_using_it].

# Boot in recovery in OVH

You will first need to boot your VPS in recovery mode.

# Install the server

The VPS might be formatted in ext3. If that's the case, I would
recommend reformatting it in ext4 as it yields better performance. To do
that, you can use the following commands:

```
# umount /dev/sdb1
# mkfs.ext4 /dev/sdb1
# mount /dev/sdb1
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

# apk update
# setup-apkrepos
# setup-apkcache
# setup-hostname
# setup-interfaces
# setup-keymap
# setup-timezone

# setup-sshd
# setup-ntp
# rc-update add crond default

# apk add linux-grsec syslinux
# dd if=/usr/share/syslinux/mbr.bin of=/dev/sdb
# extlinux -i /boot

# vi /etc/update-extlinux.conf
# update-extlinux

# vi /etc/fstab

# passwd

# exit
# reboot
```

[install_in_a_chroot]: https://wiki.alpinelinux.org/wiki/Installing_Alpine_Linux_in_a_chroot
[install_to_disk]: https://wiki.alpinelinux.org/wiki/Install_to_disk
