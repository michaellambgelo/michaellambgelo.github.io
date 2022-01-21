---
layout : post
title : k3s Installation
image : "/seo/2022-01-20.png"
category : cluster computing
---

## k8s -> k3s

In March 2021 I first posted about setting up a Pi cluster. Initially, I had tried (and subsequently failed) to set up a full-fledged Kubernetes (k8s) cluster. Then, I discovered k3s, a lightweight distribution of Kubernetes designed for edge environments (which also works on ARM devices). It ships with an embedded sqlite3 database when setting up a server node as default storage but it is trivial to use etcd3/MySQL/PostgreSQL if desired. I was very pleased with how simple the k3s launcher is and it made the entire installation experience straightforward.

## Architecture

![k3s architecture](/img/2022-01-20-k3s-architecture.png)

I based my installation on [the single-server setup with an embedded database](https://rancher.com/docs/k3s/latest/en/architecture/) documented by Rancher. In my configuration, `node1` is running k3s in `server` mode and `node[2:6]` is running it in `agent` mode. Here's a breakdown of what I had to do to install k3s.

## Installation

__Note__ During the installation process I encountered this error:

```bash
[INFO]  Failed to find memory cgroup, you may need to add "cgroup_memory=1 cgroup_enable=memory" to your linux cmdline (/boot/cmdline.txt on a Raspberry Pi)
```

To resolve the issue, I added the recommended flags to the linux cmdline as the error message suggests on each node before installing k3s.

On `node1` I installed k3s.

```bash
curl -sfL https://get.k3s.io | sh -
```

Then, I started k3s in `server` mode:

```bash
k3s server
```

The other nodes were even easier. When it's installed and run, k3s will check for `K3S_URL` and `K3S_TOKEN` environment variables. If they are set, then k3s assumes this is a worker node and starts up in `agent` mode. As `root`, I copied the token value from `node1:/var/lib/rancher/k3s/server/node-token` and used the following command to install k3s and automatically register the node with the server running on `node1` (full token values omitted):

```bash
curl -sfL https://get.k3s.io | K3S_URL=https://node1:6443 K3S_TOKEN=K109...f2bb::server:bc1...2e9 sh -
```

## Result

I checked out the results of my installation on `node1` using `k3s kubectl get nodes`.

![k3s server and nodes listed using `kubectl get nodes` command](/img/2022-01-20-k3s-get-nodes.png)
