---
layout: post
title:  "How to setup a NAS from scratch in 1 hour"
date:   2015-12-19
---

This post describes setup of the NAS built in [this post][]. The NAS would have
two purposes. The first one would be to provide a relaliable and easily
accessible storage to share media files and do backups. The second one would be
to serve as a media center, using [Kodi][] for instance.

## Choosing the OS

The first step of setup is to chose the best suited OS for the task. This
wasn't easy because of the video card requiring a very recent driver to work.
Also, I wanted to use a Copy-on-Write file system such as [Btrfs][] or [ZFS][]
to allow daily snapshots of the data and avoid any loss.

  * [FreeBSD][]: My previous NAS was on FreeBSD, so the migration would have
    been easy. However, the FreeBSD kernel did not support the video card,
    which made Kodi very slow.
  * [Debian][]: After trying FreeBSD, I decided to try one of the most famous
    Linux distribution. But at the time, the kernel distributed in the stable
    version was too old and did not contain the video card driver either.
  * [ArchLinux][]: Being a rolling release, Arch has the advantage to always
    deliver the latest softwware. The first advantage was that I could get the
    latest Kernel so that I would be certain that if the video driver were
    actually supported by Linux, they were present in this Kernel.
  * [Gentoo][]: Gentoo is currently my desktop distriution. It is also a rolling
    release and uses OpenRC instead of systemd. However, you need to compile any
    package that you installed, and I didn't want to spend hours updating my
    system, as I was already doing that on my desktop.
  * [Alpine][]: I am considering migrating my server to Alpine at some point.
    As Gentoo, it uses OpenRC. I will certainly make an article sometime about
    why this is important. Also, it is minimalist, secure by default and allow
    to easilly mix and update binary and source based packages.

Why not using one of the popular NAS distribution like FreeNAS or NAS4Free?  As
a power user, I like having full control over my server, so I prefer to use a
rather nude distribution on which I can build my system as I want and install
whatever I want.

Also, I did not mention CentOS, Ubuntu or any other distribution. First
of all, CentOS is using an even older Kernel so it would not have solved my
video driver issue. As for Ubuntu, that was my first distribution on which I
learned how to use Linux but I have come to hate it for several reason I will
explain in a later post. But my advice is, pick whichever distribution you are
comfortable with, keeping in mind that you need something reliable enough so
that you don't loose all your data.

The setup I will present is such that you can easily have several distribution
installed on the same server as long as they are Linux based and have a recent
Kernel, so I don't have to worry too much about the one I chose.

For the purpose of this article, I will show the setup using a Debian system as
this is one of the most used distribution for this purpose, but this could
easily be translated for another system. In a later post, I will show how to
easily add another OS to the setup in minutes.

## Drives setup

The purpose of the server being providing massive and accessible storage for
the whole network, this is the most important part of the setup. In this setup,
I have two 1TB disks and 1 2TB disk. This is not the most optimal setup, but it
should work.

Boot your favorite live ISO and fire up a root shell. You can use the
installation media or any other media. Make sure you have *btrfs-tools*
installed as we will use Btrfs file system. 

### Swap

First, you need to chose a disk holding the swap partition. This is not
required if you have a massive amount of RAM, but can be useful if you plan of
hibernating your server. You could try to balance the swap over the drives,
like putting a 2GB partition on the 2TB disk and a 1GB partition on each 1TB
disk, but I considered losing 4GB of storage acceptable compared to the burden
of having the swap split over 3 disks.

Assuming */dev/sda* is your 2TB disks, you can run the following commands. To
check that, running *dmesg | grep '2.00 TB'* should do the work.

    # fdisk /dev/sda


  [this post]:  {% post_url 2015-11-11-building-a-cheap-nas %}
  [Kodi]:       https://kodi.tv/
  [Btrfs]:      https://btrfs.wiki.kernel.org/index.php/Main_Page
  [ZFS]:        https://www.freebsd.org/doc/handbook/zfs.html
  [FreeBSD]:    https://www.freebsd.org/
  [Debian]:     https://www.debian.org/
  [ArchLinux]:  https://www.archlinux.org/
  [Gentoo]:     https://www.gentoo.org/
  [Alpine]:     https://www.alpine.org/
