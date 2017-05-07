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

You will first need to boot in recovery mode.
