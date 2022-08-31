---
layout: post
title: Workspace Configuration
category: cluster-computing
image : "/seo/2021-03-27.png"
---
## Managing Remote Access

Yesterday's post included a reminder that when setting up a new Pi it is important to change the default password of the `pi` user. In most distributed computing environments is it also best practice to create individual user accounts to manage access to the various nodes on the network.

My preference is to have a user that can access each node without needing to type a password. This is accomplished with our favorite remote access tool SSH.

## Passwordless SSH access

I followed the steps outlined below with reference to [this guideline](https://www.raspberrypi.org/documentation/remote-access/ssh/passwordless.md) from the RPi Foundation.

### 1. Create a new user on each node and switch to it

As the `pi` user I can set up a new user for myself.

```bash
sudo adduser michael
```

```bash
sudo usermod -a -G adm,dialout,cdrom,sudo,audio,video,plugdev,games,users,input,netdev,gpio,i2c,spi michael
```

`michael` then has permission to act as a sudoer, so I finished the rest of my work on the node logged in as this user using `su` (swtich user).

```bash
sudo su - michael
```

### 2. Finish `raspi-config` as new user

```bash
sudo raspi-config
```

`raspi-config` brings up an interactive menu. Here I set the hostname and timezone.

### 3. Copy the workspace SSH public key to the node

From my main computer I use `ssh-copy-id` which will install my public key onto the node.

```bash
ssh-copy-id michael@node1
```

The resulting output:

```bash
Number of key(s) added:        1
```

### Result

Following this process on each node makes it easy to use my main computer as a workspace and perform tasks. Now that I can connect to each node individually, my next goal is to install Ansible and dive into what sort of automations I can tinker with.

Additionally, because I know Ansible only needs to be installed on one node and its agentless operation requires SSH access, I have also generated an SSH key on `node1` and copied the ID to all the other nodes so that Ansible will be able to perform actions as `michael`.
