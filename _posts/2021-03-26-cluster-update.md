---
layout: post
title: Pi Cluster Update
category: cluster computing
---

# Pis on a Rack
![photo of bare metal pi cluster](/img/pi-cluster-bare-metal.png)

The cluster is physically together! The next step is to get the operating system provisioned and loaded onto the SD cards.

# Installing the Operating System
For this installation, I'm going with the latest available Raspberry Pi OS from the RPi Foundation. It's the default, and if I've learned anything it's that the default mode is the easiest to set up and what's easy is likely what's going to keep happening.

Using the [Raspberry Pi Imager](https://www.raspberrypi.org/blog/raspberry-pi-imager-imaging-utility/) it's easy to get the SD cards flashed and ready to go.

The only additional step I took here was enabling SSH on each Pi by mounting the SD card and executing the following command (from Mac OS)

```bash
touch /Volumes/boot/ssh
```

If you don't already know what SSH is, there are [plenty of YouTube videos](https://www.youtube.com/watch?v=ORcvSkgdA58&ab_channel=Computerphile) to help you out. It's a common tool used to connect to computers, and the above command simply creates a file called `ssh` that the OS will look for to automatically enable SSH when the Pi nodes boot for the first time.

# Networking the Cluster
![photo of networked pi cluster](/img/pi-cluster-networked.png)
I used `nmap` to figure out the IP addresses of the individual nodes.

```bash
nmap -sT -p 22 192.168.1.0/24
```

From there, I assigned each node a static IP address so that they will always be accessible from predictable and known locations. I'm not very creative, so my naming scheme was simply `node*` so my hostnames inventory looks like this:

```
node1
node2
node3
node4
node5
node6
```

# What's next
Ansible