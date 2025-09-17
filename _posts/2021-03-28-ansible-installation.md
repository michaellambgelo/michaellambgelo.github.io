---
layout: post
title: Ansible Installation
category: infrastructure
tags:
- ansible
- raspberry-pi
- cluster
- tutorial
- automation
image : "/seo/2021-03-28.png"
redirect_from:
- /cluster-computing/2021/03/28/ansible-installation.html

---

## What is Ansible

Ansible is an IT automation tool provided by RedHat. It is designed to operate agentless, which means that nodes don't need separate agent applications to be used in an Ansible automation.

Ansible runs **playbooks** which execute a series of **tasks** on a given set of hosts. Tasks are performed in order. It is supposed to be easy to use and understand so that anyone in an IT organization can read a playbook and know what it is doing.

## Why do I want to learn Ansible

There's a number of reasons why, rooted generally in the use cases Ansible is known for:

- Configuration management
- App deployment
- Provisioning
- Continuous delivery
- Security & compliance
- Orhcestration

## Ansible Concepts

- **Control node** : any machine with Ansible installed
- **Managed nodes** : any network device / servers managed with Ansible
- **Inventory** : a list of managed nodes
- **Collections** : distribution format for Ansible assets (playbooks, roles, modules)
- **Modules** : the units of code Ansible executes
- **Tasks** : the units of action in Ansible
- **Playbooks** : ordered lists of tasks

## Getting Started with Ansible

### Installation

I refered to [the latest Ansible community installation guide](https://docs.ansible.com/ansible/latest/installation_guide/index.html) to figure out what I needed to do to get the tool working on my cluster.

Because Ansible is agentless, I only need a single **control node** to be able to run playbooks or ad-hoc tasks on **managed nodes**.

I installed Ansible on `node1` using the system package manager

```bash

sudo apt-get install ansible

```

### Creating an inventory

Ansible allows users to define lists of hosts as **inventory**.

On `node1` I opened `/etc/ansible/hosts` which is the file containing the hosts I want to run playbooks on and added my cluster. This file has examples of how to add inventory. Following one of those examples resulted in this straightforward definition of my cluster.

```bash

[cluster]
node[1:6]

```

### Let's run a task

At this point I am ready to see whether Ansible is set up and working properly.

```bash

ansible all -m ping

```

This runs the `ping` module against all hosts in inventory.

As depicted below, all the hosts were successfully `ping`ed!

![screenshot of console showing Ansible output](/img/ansible-setup-success.png)

### Conclusion

I've got a control node ready to execute playbooks on the cluster.

The only other cluster-related topic I want to delve into now is Kubernetes, so that is what I'll be working to set up this week.
