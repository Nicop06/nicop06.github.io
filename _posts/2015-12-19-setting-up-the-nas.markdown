---
layout: post
title:  "How to setup a NAS in 1 hour using Btrfs"
date:   2015-12-19
tags:   Linux Btrfs
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

## Start the installation

A small warning before you start. This is intended to target people with basic
knowledge of Linux installation. If you are a beginner and this is your first
time installing Linux, you should probably not follow this guide.

You can download the latest stable Debian netinstall ISO [here][Debian
netinst]. Once its boot, go to _Advanced Options_ and select _Expert install_.
Then, follow the instructions until you reach the _Load installer components
from CD_ part. You will need to select `cfdisk` or `gparted` to manually create
your disk layout.

![Debian load installer components](/assets/debian-load-installer-components.png)

Continue untill you reach the _Partition disks_ part. At this point, you will
need to stop the installation process and go to the second terminal by running
_CTRL+ALT+F2_. You will then need to perform the manual setup.

## Drives setup

The purpose of the server being providing massive and accessible storage for
the whole network, this is the most important part of the setup. In this setup,
I have two 1TB disks and one 2TB disk. This is not the most optimal setup, but
it should work.

Boot your favorite live ISO and fire up a root shell. You can use the
installation media or any other media. Make sure you have `btrfs-tools`
installed as we will use Btrfs file system.

### Partitioning

First, you need to chose a disk holding the swap partition. This is not
required if you have a massive amount of RAM, but can be useful if you plan of
hibernating your server. You could try to balance the swap over the drives,
like putting a 2GB partition on the 2TB disk and a 1GB partition on each 1TB
disk, but I considered losing 4GB of storage acceptable compared to the burden
of having the swap split over 3 disks.

Assuming `/dev/sda` is your 2TB disks, you can run the following commands. To
check that, running `dmesg | grep '2.00 TB'` should do the work. Be careful,
any mistake you do at this step will destroy all your data, so be certain that
you only have emptry hard drive and the installation CD / USB plugged into the
machine.

{% highlight shell %}
$ fdisk /dev/sda

Welcome to fdisk (util-linux 2.25.2).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.
{% endhighlight %}

Create the swap partition. I will use 1GB for this tutorial.

{% highlight shell %}
Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p):

Using default response p.
Partition number (1-4, default 1):
First sector (2048-16777215, default 2048):
Last sector, +sectors or +size{K,M,G,T,P} (2048-16777215, default 16777215): +1G

Created a new partition 1 of type 'Linux' and of size 1 GiB.
{% endhighlight %}

I left every options default except for the *last sector* option. Then, create
a single partition for the whole filesystem, we will then be able to separate
the root, var and home partitions using Btrfs subvolumes. You can optionally
create a separated boot partition depending on the bootloader you want to use.
I will come back to that later.

{% highlight shell %}
Command (m for help): n
Partition type
p   primary (1 primary, 0 extended, 3 free)
e   extended (container for logical partitions)
Select (default p):

Using default response p.
Partition number (2-4, default 2):
First sector (2099200-16777215, default 2099200):
Last sector, +sectors or +size{K,M,G,T,P} (2099200-16777215, default 16777215):

Created a new partition 2 of type 'Linux' and of size 7 GiB.

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
{% endhighlight %}

Here, I create the main Btrfs partition and write the result. In case you are
wandering why the size of the partition is only 7GB, this is because I am
copy pasting the commands from a VM install, but this should be exactly the
same as a regular install. I will not create any partition on the other disks
as Btrfs can use a whole disk. But you might want to do so in order to install
create MBR headers allowing the bootload on all disks.

Also, you could use GPT partitioning and UEFI, but if your motherboard allow
you to boot in legacy mode I strongly recommend doing so. This will save you
some troubles like the creation of a EFI partition or setting the bios flag.
The setup is complicated enough.

### Swap

You can then create the swap with the following command:

{% highlight shell %}
$ mkswap /dev/sda1
Setting up swapspace version 1, size = 1073737728 bytes
UUID=fc6d3f5d-8e2a-4ce3-8d3d-ba13c08a617e
{% endhighlight %}

### Btrfs setup

You are now ready to perform the Btrfs setup. Please note the name of the
different partitions you want to use to create the Btrfs volume. In my case,
this would be `/dev/sda`, `/dev/sdb` and `/dev/sdc`. It might be something else
depending on your setup. You can then run the following command.

{% highlight shell %}
$ modprobe btrfs
$ mkfs.btrfs -L nas -m raid1 -d raid1 /dev/sda2 /dev/sdb /dev/sdc
Btrfs v3.17
See http://btrfs.wiki.kernel.org for more information.

Turning ON incompat feature 'extref': increased hardlink limit per file to 65536
adding device /dev/sdb id 2
adding device /dev/sdc id 3
fs created label nas on /dev/sda2
        nodesize 16384 leafsize 16384 sectorsize 4096 size 15.00GiB
{% endhighlight %}

The `-L nas` create a label on the filesystem so that you can mount it using
the label instead of the UUID. The `-m raid1` and `-d raid1` allow to write
respectively the metadata and the data on 2 different disks. Btrfs will
automatically handle the poll of heterogeneous disks. Even if it's not
recommended, it works.

Then, you need to mount the newly created Btrfs volume.

{% highlight shell %}
$ mount /dev/sda2 /mnt
{% endhighlight %}

Then, check that everything is in RAID1 by running:

{% highlight shell %}
$ btrfs filesystem df /mnt/
Data, RAID1: total=1.00GiB, used=512.00KiB
Data, single: total=8.00MiB, used=0.00B
System, RAID1: total=8.00MiB, used=16.00KiB
System, single: total=4.00MiB, used=0.00B
Metadata, RAID1: total=1.00GiB, used=112.00KiB
Metadata, single: total=8.00MiB, used=0.00B
GlobalReserve, single: total=16.00MiB, used=0.00B
{% endhighlight %}

If you see *single* like on my output, just run the following command.

{% highlight shell %}
$ btrfs balance /mnt/
Done, had to relocate 6 out of 6 chunks
{% endhighlight %}

Now, let's create the subvolumes. I use a subvolume for the root partition.
This has several advantages, like being able to easily install a new OS on the
same volume or to snapshot the partition for backup or other purpose. I'll show
you my backup setup in another article.

{% highlight shell %}
$ btrfs subvolume create /mnt/debian/
Create subvolume '/mnt/debian'
$ btrfs subvolume create /mnt/debian/root/
Create subvolume '/mnt/debian/root'
$ btrfs subvolume create /mnt/debian/var
Create subvolume '/mnt/debian/var'
$ btrfs subvolume create /mnt/debian/home
Create subvolume '/mnt/debian/home'
{% endhighlight %}

Finally, mount the different subvolumes such that debian can install the base
system. You may want to have a look to [Btrfs mount options][] in case for
instance your use SSD or you want to enable compression.

{% highlight shell %}
$ mkdir /target
$ mount -o subvol=debian/root /dev/sda2 /target
$ mkdir /target/var
$ mount -o subvol=debian/var /dev/sda2 /target/var
$ mkdir /target/home
$ mount -o subvol=debian/home /dev/sda2 /target/home
{% endhighlight %}

Now, go back to the installation media by typing *CTRL+ALT+F1*, skip the
partitioning step and run directly the *install the base system* step.


  [this post]:        {% post_url 2015-11-11-building-a-cheap-nas %}
  [Kodi]:             https://kodi.tv/
  [Btrfs]:            https://btrfs.wiki.kernel.org/index.php/Main_Page
  [ZFS]:              https://www.freebsd.org/doc/handbook/zfs.html
  [FreeBSD]:          https://www.freebsd.org/
  [Debian]:           https://www.debian.org/
  [ArchLinux]:        https://www.archlinux.org/
  [Gentoo]:           https://www.gentoo.org/
  [Alpine]:           https://www.alpine.org/
  [Debian netinst]:   https://www.debian.org/CD/netinst/
  [Btrfs mount options]: https://btrfs.wiki.kernel.org/index.php/Mount_options
  [Btrfs multiple devices]: https://btrfs.wiki.kernel.org/index.php/Using_Btrfs_with_Multiple_Devices
  [Btrfs multiple use cases]: https://btrfs.wiki.kernel.org/index.php/UseCases
