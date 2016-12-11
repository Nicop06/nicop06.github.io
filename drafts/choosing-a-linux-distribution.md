## Choosing the OS

The first step of setup is to choose the most suited OS for the task. This
wasn't easy because the video card required a very recent kernel to work.
Also, I wanted to use a Copy-on-Write file system such as [Btrfs][] or [ZFS][]
to allow daily snapshots and ease of maintenance.

  * [FreeBSD][]: My previous NAS was running FreeBSD, so the migration would
  have been easy. However, the FreeBSD kernel did not support the video card,
  which made Kodi very slow.

  * [Debian][]: After trying FreeBSD, I decided to try one of the oldest Linux
  distribution. But at the time, the kernel distributed in the stable release
  was too old and did not contain the video card driver either.

  * [ArchLinux][]: Being a rolling release, Arch has the advantage to always
  deliver the latest softwware. The first advantage was that I could get the
  latest Kernel so that I would be certain that if the video driver were
  actually supported by Linux, they were present in this Kernel.

  * [Gentoo][]: Gentoo is currently my desktop distribution. It uses [OpenRC][]
  instead of [systemd][], which respect a lot more the [Unix philosophy][Unix]:
  *Do One Thing and Do It Well*.  However, you need to compile any package that
  you install, which makes make it a lot more difficult to maintain.

  * [Alpine][]: I am considering migrating my server to Alpine at some point.
  As Gentoo, it uses OpenRC. Also, it is minimalist, secure by default and
  allows to easilly mix and update binary and source based packages.

Why not use one of the popular NAS distribution like FreeNAS or NAS4Free?  As
a power user, I like having full control over my server, so I prefer to use a
minimalist distribution on which I can build my system as I want and install
whatever I want.

Also, I did not mention CentOS, Ubuntu or many other distributions. Actually,
the choice of the distribution is not critical and any Unix system would be
perfectly suitable. My advice is to pick whichever distribution you are
comfortable with, keeping in mind that you need something reliable enough so
that you don't lose your data.

This setup will allow you to easily installs several distributions alongside,
so the choice of the OS is not definitive. I actually installed 3 of the
presented OS before settling for ArchLinux.

For the purpose of this article, I will show the setup using Debian :as this is
one of the most used distribution for this purpose, and therefore has an ample
documentation and community to help you solve any problem you might encounter.
But this could easily be translated for another system.

[Btrfs]:       https://btrfs.wiki.kernel.org/index.php/Main_Page
[OpenRC]:      https://wiki.gentoo.org/wiki/OpenRC
[systemd]:     https://www.freedesktop.org/wiki/Software/systemd/
[Unix]:        https://en.wikipedia.org/wiki/Unix_philosophy#Do_One_Thing_and_Do_It_Well
[ZFS]:         https://www.freebsd.org/doc/handbook/zfs.html
[FreeBSD]:     https://www.freebsd.org/
[Debian]:      https://www.debian.org/
[ArchLinux]:   https://www.archlinux.org/
[Gentoo]:      https://www.gentoo.org/
[Alpine]:      https://www.alpine.org/
