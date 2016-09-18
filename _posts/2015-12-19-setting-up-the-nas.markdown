---
layout: post
title:  "How to setup a NAS in 1 hour using Btrfs"
date:   2015-12-19
tags:   Linux Btrfs
---

This post describes setup of the NAS built in [the previous post][]. The NAS
would have two purposes. The first one would be to provide a relaliable and
easily accessible storage to share media files and do backups. The second one
would be to serve as a media center, using [Kodi][] for instance.

## Choosing the OS

The first step of setup is to chose the best suited OS for the task. This
wasn't easy because the video card requried a very recent kernel to work.
Also, I wanted to use a Copy-on-Write file system such as [Btrfs][] or [ZFS][]
to allow daily snapshots of the data and avoid any loss.

  * [FreeBSD][]: My previous NAS was running FreeBSD, so the migration would
    have been easy. However, the FreeBSD kernel did not support the video card,
    which made Kodi very slow.
  * [Debian][]: After trying FreeBSD, I decided to try one of the most famous
    Linux distribution. But at the time, the kernel distributed in the stable
    release was too old and did not contain the video card driver either.
  * [ArchLinux][]: Being a rolling release, Arch has the advantage to always
    deliver the latest softwware. The first advantage was that I could get the
    latest Kernel so that I would be certain that if the video driver were
    actually supported by Linux, they were present in this Kernel.
  * [Gentoo][]: Gentoo is currently my desktop distribution. It is also a
    rolling release and uses OpenRC instead of systemd, preventing a single
    point of failure on my system. However, it requires you to compile any
    package that you install, and I didn't want to spend hours updating my
    system, as I was already doing that on my desktop.
  * [Alpine][]: I am considering migrating my server to Alpine at some point.
    As Gentoo, it uses OpenRC. Also, it is minimalist, secure by default and
    allow to easilly mix and update binary and source based packages.

Why not using one of the popular NAS distribution like FreeNAS or NAS4Free?  As
a power user, I like having full control over my server, so I prefer to use a
rather minimalist distribution on which I can build my system as I want and
install whatever I want.

Also, I did not mention CentOS, Ubuntu or many other distributions. Actually,
the choice of the distribution is not critical and any Unix system would be
perfectly suitable. My advice is t to pick whichever distribution you are
comfortable with, keeping in mind that you need something reliable enough so
that you don't loose your data.

The setup I will present is such that you can easily have several distributions
installed on the same server as long as they are Linux based and have a recent
Kernel, so I don't have to worry too much about the one I chose.

For the purpose of this article, I will show the setup using a Debian system as
this is one of the most used distribution for this purpose, and therefore has
an ample documentation and community to help you solve any problem you might
encounter. But this could easily be translated for another system. In a later
post, I will show how to easily add another OS to the setup in minutes.

## Start the installation

A small warning before you start. This is intended to target people with some
basic knowledge of Linux installation. If you are a beginner and this is your
first time installing Linux, you should probably not follow this guide. There are a lot of simpler ways to build a NAS, at the cost of some flexibility.

You can download the latest stable Debian netinstall ISO [here][Debian
netinst]. Once it boots, go to _Advanced Options_ and select _Expert install_.
Then, follow the instructions until you reach the _Load installer components
from CD_ part. You might want to select `cfdisk` or `gparted` to manually create
your disk layout if you are used to them. In this post, we will directly use
`fdisk`.

![Debian load installer components](/assets/debian-load-installer-components.png)

Continue until you reach the _Partition disks_ part. At this point, you will
need to stop the installation process and go to the second terminal by entering
_CTRL+ALT+F2_. You will then need to perform some manual setup.

## Drives setup

The purpose of the server is to provide accessible and reliable storage for the
whole network, so this is the most important part of the setup. In this setup,
I have two 1TB disks and one 2TB disk. Even if it is recommended to have disks
of the same size, it is better to use 

### Partitioning

First, you need to chose a disk holding the swap partition. This is not
required if you have a massive amount of RAM, but can be useful if you plan on
hibernating your server. You could try to balance the swap over the drives,
like putting a 2GB partition on the 2TB disk and a 1GB partition on each 1TB
disk, but I considered losing 4GB of storage acceptable.

We will assume that `/dev/sda` is the 2TB disks. To check that, you can run
`dmesg | grep '2.00 TB'`. Be careful, as any mistake you do at this step can
destroy all your data. In my case, I only had empty disks and the installation
media so I didn't have to worry too much.

{% highlight shell %}
/# fdisk /dev/sda

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

I left every options as default except for the *last sector* option. Then,
create a single partition for the whole filesystem. We will separate the root,
var and home partitions later using Btrfs subvolumes. You can optionally create
a separated boot partition depending on the bootloader you want to use. I will
come back on that later.

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
wandering why the size of the partition is only 7GB, this is because I am using
a VM for this page, but this should be exactly the same as a regular install. I
will not create any partition on the other disks as Btrfs can use a
partitionless disk. However, this is discouraged in case you want to install a
bootloader on those disks.

### Swap

You can then create the swap with the following command:

{% highlight shell %}
/# mkswap /dev/sda1
Setting up swapspace version 1, size = 1073737728 bytes
UUID=fc6d3f5d-8e2a-4ce3-8d3d-ba13c08a617e
{% endhighlight %}

### Btrfs setup

You are now ready to perform the Btrfs setup. Please note the name of the
different partitions you want to use to create the Btrfs volume. In my case,
this would be `/dev/sda`, `/dev/sdb` and `/dev/sdc`. It might be something else
depending on your setup. You can then run the following commands.

{% highlight shell %}
/# modprobe btrfs
/# mkfs.btrfs -L nas -m raid1 -d raid1 /dev/sda2 /dev/sdb /dev/sdc
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
both the metadata and the data on 2 different disks. Btrfs will automatically
handle the poll of heterogeneous disks.

Then, you need to mount the newly created Btrfs volume.

{% highlight shell %}
/# mount /dev/sda2 /mnt
{% endhighlight %}

Check that every data are mirrored by running:

{% highlight shell %}
/# btrfs filesystem df /mnt/
Data, RAID1: total=1.00GiB, used=512.00KiB
Data, single: total=8.00MiB, used=0.00B
System, RAID1: total=8.00MiB, used=16.00KiB
System, single: total=4.00MiB, used=0.00B
Metadata, RAID1: total=1.00GiB, used=112.00KiB
Metadata, single: total=8.00MiB, used=0.00B
GlobalReserve, single: total=16.00MiB, used=0.00B
{% endhighlight %}

You need all the blocks to use the [RAID1]() allocation level, ensuring that
the data are written to at least 2 different disks in order to tolerate the
loss of 1 disk. If you see *single* like on my output, just run the following
command. 

{% highlight shell %}
/# btrfs balance /mnt/
Done, had to relocate 6 out of 6 chunks
{% endhighlight %}

Now, let's create the subvolumes. For the root partition, I use a different
root than the Btrfs tree root. This has several advantages, like being able to
easily install a new OS on the same volume or to snapshot the partition for
backup or other purpose. I will dedicate another article to by backup setup.

{% highlight shell %}
/# btrfs subvolume create /mnt/debian/
Create subvolume '/mnt/debian'
/# btrfs subvolume create /mnt/debian/root/
Create subvolume '/mnt/debian/root'
/# btrfs subvolume create /mnt/debian/var
Create subvolume '/mnt/debian/var'
/# btrfs subvolume create /mnt/debian/home
Create subvolume '/mnt/debian/home'
{% endhighlight %}

Finally, mount the different subvolumes such that debian can install the base
system. You may want to have a look at the [Btrfs mount options][] in case for
instance your use SSD or you want to enable compression.

{% highlight shell %}
/# mkdir /target
/# mount -o subvol=debian/root /dev/sda2 /target
/# mkdir /target/var
/# mount -o subvol=debian/var /dev/sda2 /target/var
/# mkdir /target/home
/# mount -o subvol=debian/home /dev/sda2 /target/home
{% endhighlight %}

You also need to manually create the fstab file in */target/etc/fstab/*. Here
is a sample file:

{% highlight config %}
LABEL=nas /       btrfs rw,relatime,subvol=debian/root 0 0
LABEL=nas /var    btrfs rw,relatime,subvol=debian/var  0 0
LABEL=nas /home   btrfs rw,relatime,subvol=debian/home 0 0

/dev/sda1 swap swap defaults 0 0
{% endhighlight %}

You may also want to use the UUID of the disks instad of the labels and disk
name.

## Resuming the installation

Now, go back to the installation media by typing *CTRL+ALT+F1*, skip the
partitioning step and run directly the *install the base system* step. You will
certainly get the following message: ignore it by selecting `<Go Back>`. You
might need to do that more than once.

![Debian error partitioning](/assets/debian-error-partitioning.png)

The installation step may take a while depending on the disks you are using or
your network speed. While this is installing, you can go to */mnt/debian/root*
and */mnt/debian/var* and observe the different files being copied. These are
the same files than in */target* and in */target/var*.

If you go to */mnt/debian*, you can rename any subvolume and everything will
still work. This is as if they where regular folders, but they can be mounted
as a regular volume. This has some nice applications. For instance, you can
replace the root partition and reboot to the new one without breaking the system
or requiring any more partition or media.

When you get to the *select software* part, you may want to deselect the
desktop environment. We will use Kodi as a standalone environment.

## The bootloader

Finally, you will need to install the grub bootloader, as any other boot loader
might not be able to boot a Btrfs filesystem. Syslinux may work but doesn't
support compression or encryption according to the [Syslinux wiki][]. If you
still want to use an incompatible setup, you will to create a dedicated boot
partition formatted in FAT32 or EXT 2/3/4 for instance.

Unfortunately, because of the manual partitioning, you will have to manually
install some programs. First, you need to *chroot* into the new system. You can
do that with the following command:

{% highlight shell %}
/# chroot /target /bin/bash
{% endhighlight %}

Then, you can install the Btrfs tools, mainly containing the `btrfs` program.
This will also regenerate the *initramfs* to integrate the Btrfs tools in order
to mount the root partition during boot as it is present in a subvolume. If you
forget this step, your system will be unbootable. This is the main
inconvenience of having the root of the system separated for the root of the
Btrfs partition.

{% highlight shell %}
root@debian:/# apt-get install btrfs-tools
{% endhighlight %}

Finally, you can install and configure grub:

{% highlight shell %}
root@debian:/# apt-get install grub2
{% endhighlight %}

When you are asked to select the disk where to install grub, be careful not to
select partionless disk. If you created partitions in all your disks, I
recommend you to install grub on all the disks, as you will still be able to
boot even if you loose one disk.

Once you are done, you can directly go to the *Finish the installation* step.
This will reboot your system, and you can now start using it.

## Auto shutdown script

I wanted to share a script I wrote to automatically shut down your server when
it isn't used. You can access this script directly on my [GitHub repository][].

It can run in a crontab or as a daemon, regularly running different tests to
check if the server is in use.  After some amount of time without any activity,
it will shut down the system. You can create a configuration files to override
some settings. Among the tests, it will check for connected users and
established network connections. I encourage you to read the code and modify
the script, and don't hesitate to send me feedbacks.

## Final thoughts

This setup might seem complicated, but it has a lot of advantages as we will
see in another articles. Among them, you can easily install another Linux
distribution while the current system is running without using an installation
drive. You can also import the system on your desktop machine, test some
changes and send them back to your server. Then, when you are ready, you can
easily switch to the new system. Finally, you can have an unlimited number of
online snapshots without worrying about space or performance issue. I will
dedicate another articles to all the benefits of Btrfs.


  [the previous post]: {% post_url 2015-11-11-building-a-cheap-nas %}
  [Kodi]:              https://kodi.tv/
  [Btrfs]:             https://btrfs.wiki.kernel.org/index.php/Main_Page
  [ZFS]:               https://www.freebsd.org/doc/handbook/zfs.html
  [RAID]:              https://en.wikipedia.org/wiki/Standard_RAID_levels#RAID_1
  [FreeBSD]:           https://www.freebsd.org/
  [Debian]:            https://www.debian.org/
  [ArchLinux]:         https://www.archlinux.org/
  [Gentoo]:            https://www.gentoo.org/
  [Alpine]:            https://www.alpine.org/
  [Debian netinst]:    https://www.debian.org/CD/netinst/
  [Btrfs mount options]: https://btrfs.wiki.kernel.org/index.php/Mount_options
  [Btrfs multiple use cases]: https://btrfs.wiki.kernel.org/index.php/UseCases
  [Syslinux wiki]: http://www.syslinux.org/wiki/index.php?title=Filesystem#Btrfs
  [GitHub repository]: https://github.com/Nicop06/dotfiles/blob/master/bin/auto-shutdown.sh

