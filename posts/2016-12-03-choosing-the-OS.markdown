---
title:  "Which OS to run a NAS"
tags:   linux NAS
---

Before setting up the NAS, I had to decide which OS I would use to run it. This
wasn't easy because the video card required a very recent kernel to work. Also,
I wanted to use a Copy-on-Write file system such as [Btrfs][] or [ZFS][] to
allow daily snapshots and ease of maintenance.

## [FreeBSD][]

My previous NAS was running FreeBSD, so the migration would have been easy.
However, the FreeBSD kernel did not support the video card, which made Kodi
very slow.

## [Debian][]

After trying FreeBSD, I decided to try one of the oldest Linux distribution.
But at the time, the kernel distributed in the stable release was too old and
did not contain the video card driver either.

## [ArchLinux][]

Being a rolling release, Arch has the advantage to always deliver the
latest software. The first advantage was that I could get the latest
Kernel, which contained a working driver for my video card.

## [Gentoo][]

Gentoo is currently my desktop distribution. It uses [OpenRC][] instead of
[systemd][], which respect a lot more the [Unix philosophy][Unix]: *Do One
Thing and Do It Well*. However, you need to compile any package that you
install, which makes it a lot more difficult to maintain.

## [Alpine][]

I am considering migrating my server to Alpine at some point. As Gentoo, it
uses OpenRC. Also, it is minimalist, secure by default and allows to easilly
mix and update binary and source based packages.

## Why not use one of the popular NAS distribution like FreeNAS or NAS4Free?

As a power user, I like having full control over my server, so I prefer to use
a minimalist distribution on which I can build my system as I want and install
whatever I want.

## What about other popular Linux distributions?

I did not mention CentOS, Ubuntu or many other distributions. Actually, the
choice of the distribution is not critical and any Unix system would be
perfectly suitable. My advice is to pick whichever distribution you are
comfortable with, keeping in mind that you need something reliable enough so
that you don't lose your data.

## Final thoughts

The setup shown in [this post][next_post] will allow you to easily install
several distributions alongside, so the choice of the OS is not
definitive. I actually installed 3 of the OS discussed in this article before
settling for ArchLinux. Also, I plan on migrating to Alpine, mainly because it
[doesn't use systemd][wo-systemd].

[next_post]:   2016-12-10-setting-up-the-nas.markdown
[Btrfs]:       https://btrfs.wiki.kernel.org/index.php/Main_Page
[OpenRC]:      https://wiki.gentoo.org/wiki/OpenRC
[systemd]:     https://www.freedesktop.org/wiki/Software/systemd/
[wo-systemd]:  http://without-systemd.org/wiki/index.php/Main_Page
[Unix]:        https://en.wikipedia.org/wiki/Unix_philosophy#Do_One_Thing_and_Do_It_Well
[ZFS]:         https://www.freebsd.org/doc/handbook/zfs.html
[FreeBSD]:     https://www.freebsd.org/
[Debian]:      https://www.debian.org/
[ArchLinux]:   https://www.archlinux.org/
[Gentoo]:      https://www.gentoo.org/
[Alpine]:      https://www.alpine.org/
