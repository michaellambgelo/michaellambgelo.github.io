---
layout: post
title: Pi Cluster Update
category: cluster computing
image : "/seo/default.png"
---
# Pis on a Rack

![photo of bare metal pi cluster](/img/pi-cluster-bare-metal.png)

The cluster is built and looking good! With a bare metal set up, the next step is to get the operating system provisioned and loaded onto the SD cards. After that, it's time to power up the Pis and get them established on my local network.

## Installing the Operating System

For this installation, I've gone with the latest available Raspberry Pi OS from the RPi Foundation. It's the default, and if anything is true it's that the default mode is the easiest to set up and what's easy is likely what's going to keep happening. My goal here is to set up a cluster that enables the deployment of containers. Choosing the right OS for the job is simple in this case because Raspberry Pi OS is built for these machines.

Using the [Raspberry Pi Imager](https://www.raspberrypi.org/blog/raspberry-pi-imager-imaging-utility/) it was easy to get the SD cards flashed and ready to go.

The only additional step I took here was enabling SSH on each Pi by mounting the SD card and executing the following command (from Mac OS)

```bash
touch /Volumes/boot/ssh
```

If you don't already know what SSH is, there are [plenty of YouTube videos](https://www.youtube.com/watch?v=ORcvSkgdA58&ab_channel=Computerphile) to help you out. It's a common tool used to connect to computers, and the above command simply creates a file called `ssh` that the OS will look for to automatically enable SSH when the Pi nodes boot for the first time.

## Networking the Cluster

![photo of networked pi cluster](/img/pi-cluster-networked.png)
I used `nmap` to figure out the IP addresses of the individual nodes.

```bash
nmap -sT -p 22 192.168.1.0/24
```

The arguments here specify TCP connections using port 22 within the given IP range.

From the report nmap provided I determined each node's dynamically-assigned IP address. I then assigned each node a static IP address so that they will always be accessible from predictable and known locations. I'm not very creative; my naming scheme was simply `node*` so my hostnames inventory looks like this:

```
node1
node2
node3
node4
node5
node6
```

## Security Side

I can sometimes take it for granted that installing a fresh OS with SSH enabled means it's an unsecured Linux box running on my network and that it's on me to change the default password, so I'll note here for posterity that setting up a cluster with unsecured nodes is NOT good. The first thing you should do is change the default credentials.

The default user and password for Raspberry Pi OS is `pi` and `raspberry`.

## What's next

- Ansible
  - Installation
  - Configuration
  - Hello, world
