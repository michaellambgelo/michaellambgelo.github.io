---
layout : post
title : Introducing status.michaellamb.dev
image : "/seo/2020-03-07.png"
category : cluster computing
---

## What is Docker

Docker combines an application and its depdencies in a package which can be executed in a isolated container runtime.

## VM vs Container

A _container_ is an isolated runtime environment managed by an operating system. A _virtual machine_ (VM) is an abstraction of a physical machine which runs an isolated operating system. VMs are limited for application development compared to containers as multiple containers can run in parallel on a single node, networked together by Docker.

## Docker Projects

### Uptime Kuma

[![uptime kuma](/img/uptime-kuma.svg)]((https://github.com/louislam/uptime-kuma))

I wanted to be able to host applications on my Pi cluster using Docker. I've got a deployment running [Uptime Kuma](https://github.com/louislam/uptime-kuma), a self-hosted monitoring dashboard.

### Nginx Proxy Manager

[![nginx proxy manager](/img/nginx-proxy-manager.png)]((https://github.com/NginxProxyManager/nginx-proxy-manager))

I am interested in hosting more applications and I wanted to leverage nginx as a proxy manager as I add more applications to my cluster. [Nginx Proxy Manager](https://github.com/NginxProxyManager/nginx-proxy-manager) fits the bill as it allows me to add proxy hosts and serve applications over SSL using Let's Encrypt.

## Introducing status.michaellamb.dev

[![status.michaellamb.dev](/img/favicon.png)](https://status.michaellamb.dev)

[status.michaellamb.dev](https://status.michaellamb.dev) is the combination of the two Docker projects I've deployed. You can see the status of my blog, my cluster, and other services I'm interested in monitoring.
