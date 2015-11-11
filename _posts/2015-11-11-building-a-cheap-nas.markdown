---
layout: post
title:  "Building a Cheap NAS and Media Center"
date:   2015-11-11
categories: hardware
---

This post will intends to tell the story of how I built a new NAS and media center from scratch, including hardware an software part.

## The previous setup

![Optilex GX270](http://ecx.images-amazon.com/images/I/41CK1kOQBbL.jpg)

It all started a few weeks ago when one of the disks on my NAS started making weird noises. Since 2013, I was running an old [Optilex GX270](http://www.amazon.co.uk/Dell-Optiplex-GX270-Professional-pre-installed/dp/B001UU3UMO) equiped with two brand new [WD Blue 1TB](http://www.amazon.com/Blue-Desktop-Hard-Disk-Drive/dp/B0088PUEPK/ref=sr_1_1?ie=UTF8&qid=1447200731&sr=8-1&keywords=western+digital+blue) in ZFS raid 1 and running [FreeBSD](https://www.freebsd.org). The motherbroad offers wake on lan from complete shutdown, which was great as I didn't need it to be constantly running. I was quite happy with this setup, but I was waiting for something to go wrong to upgrade to more recent hardware.

## The new setup

It was time for me to invest in new hardware. I also needed small enough and powerful enough so that it could serve as a media center under my TV. I was thus looking for a budget configuration with a small enough case to be put on my TV stand and that could host at least 2 and ideally 4 3.5'' disks. 

### The case

![Cooler Master Elite 110](http://assets.coolermaster.com/global/uploadfile/fileproduct_list/P1310080001d512/PRDPIC/290_10_df8f1c7669ef8521288b5bbeeb58be77_1381951732.jpg)

The first piece I chose was the case. I chose the [Cooler Master Elite 110](http://www.coolermaster.com/case/mini-itx-elite-series/elite110/) which could host 3 3.5'' HDDs or 2 3.5'' + 2 2.5'' HDDs. It is a cubic of around 20-25 cm, the perfect size for where I planned on storin it. As for the price, it was just under 50€. The drawback is that everything is packed and the hard drives are screwed to the case, so not easily replaced. But at this price, I didn't expect nice drawers for hot pluggable hard drives.

### The Motherboard and CPU

![ASRock Q1900-ITX](http://resources.mini-box.com/online/MBD-ASRock-Q1900-ITX/moreimages/MBD-ASRock-Q1900-ITX-b1.jpg)

I didn't need huge amount of power, so I chose a motherboard with an integrated CPU and a graphical circuit. ASRock ITX motherboard exactly fit my need, and cost only 80€ with the integrated CPU. This is the subsidiary brand of Asus, created to sell their low cost products without impacting their reputation. I preferred an Intel CPU for their great Linux support, although the AMD APU are usually good choice for such use, combining the CPU and GPU in one chip. I therefore chose the [ASRock Q1900-ITX](http://www.asrock.com/mb/Intel/Q1900-ITX/), with the following specifications:

  * An [Intel Quad-Core J1900](http://ark.intel.com/products/78867/Intel-Celeron-Processor-J1900-2M-Cache-up-to-2_42-GHz), with 2.4GHz and 2M Cache, a low power but powerful processor with a decent integrated GPU. The processor cooling system is fan less, so it is perfect for a silent configuration. Also, I could barely reach the 50°C with maximum load after 10 minutes, and the compilation of a Linux Kernel took less than twice as much time as my [Intel i7-2630QM](http://ark.intel.com/products/52219/Intel-Core-i7-2630QM-Processor-6M-Cache-up-to-2_90-GHz), which reached the 90°C.
  * Two RAM slots (8GB each), more than enough for future upgrade.
  * Up to 4 SATA ports (2 SATA2 and 2 SATA3), exactly the number required to fill the case.
  * Realtek Gigabit Ethernet controller for high speed file sharing. Although my router is limited 100Mb bandwidth, I plan on investing in a Gigabit router soon.
  * DVI, VGA and HDMI ports are all available so you are sure to find a way to connect your device to any screen
  * 7.1 HD Audio, USB 3.0, PCIe port, COM port, Printer Header

Nothing exceptional, but everything you except to find is there and you won't have any surprise. I was also surprised to see two SATA cables furnished with the motherboard, as it wasn't specified on the package contents while it was on some other ASRock motherboard.

### The power supply

![FSP 350W](http://www.fsp-group.com.tw/upload/2013/06/11/1370945109.jpg)

As for the power supply, I bought an [FSP 350W 80PLUS](http://www.fsp-group.com.tw/index.php?do=proinfo&id=144). It is a bit too powerful for my usage, but it is cheap (around 40€), from a safe brand and with high power efficiency. I also has all the connectors you need for a small configuration like the one I use. There are only 3 SATA connectors but they can be extended using the two Molex connectors and a [proper adapter](http://www.amazon.com/StarTech-com-12-Inch-Power-Cable-Adapter/dp/B0002GRUV4/ref=sr_1_4?ie=UTF8&qid=1447262448&sr=8-4&keywords=molex+to+sata).

### Storage

![WD Green 2TB](http://www.wdc.com/global/images/products/models/img5/300/wdfDesktop_Green_SATA64_6GBS.jpg)

I only bought one [WD Green 2TB](http://www.amazon.com/Green-2TB-Desktop-Hard-Drive/dp/B008YAHW6I/ref=sr_1_1?ie=UTF8&qid=1447262513&sr=8-1&keywords=wd+green+2tb) as I already had my two other 1TB disks from the previous configuration. This enabled me to have up to 2TB of data with redundancy. I also didn't see the point of buying expensive WD Red, which are supposed to be better for NAS, as my server would only be up a few hours per week.

### RAM

I had 2 2GB SODIMM RAM sticks in stock as I upgraded the memory on my laptop so I recycled them for the server. 4GB was enough for me, but considering the price of the RAM these days I would recommend to buy 8GB of RAM.

## Assembling the NAS

![NAS Inside](/assets/nas_inside.jpg)

The next step was to assemble everything. This was pretty straightforward, and the case provided enough screws for all the 3 HDDs, the motherboard and the power supply. The only problem I had was the SATA cables. In fact, the case is designed such that the drives are facing the outside of the case. This made it impossible to use the right-angled SATA cable on the disks provided with the motherboard. I also wanted to use them on the motherboard, but the ports are such that the cable is covering the other port. In my case, I was lucky to have 2 straight SATA cables that I used for the SATA3 ports, and I plugged my right-angled cable on the SATA2 port, covering the last SATA2 which I don't need.

![NAS Inside](/assets/nas_with_power_supply.jpg)

Then, I added the power supply.

![NAS Inside](/assets/nas_with_HDD.jpg)

And finally, I added the 3 disks. The last one is on the opposite side of the picture.

### Setting up the UEFI

The last step was to setup the UEFI to be able to wake from LAN and USB, as the motherboard is capable of both. I also needed to disable Windows 8 fast boot and activate legacy MBR boot. The interface is minimalistic but it is easy to find the information. And now, we are ready to setup the system.
