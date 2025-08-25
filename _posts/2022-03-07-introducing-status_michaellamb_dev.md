---
layout : post
title : Introducing status.michaellamb.dev
image : "/seo/2022-03-07.png"
category : infrastructure
tags:

- docker
- raspberry-pi	
- monitoring	

redirect_from:
- /cluster-computing/2022/03/07/introducing-status_michaellamb_dev.html

---

Using Docker, I wanted to create a new subdomain pointing to my Pi cluster to show the uptime for the cluster.

## What is Docker

Docker combines an application and its depdencies in a package which can be executed in an isolated container runtime.

## VM vs Container

A _container_ is an isolated runtime environment managed by an operating system. A _virtual machine_ (VM) is an abstraction of a physical machine which runs an isolated operating system. VMs are limited for application development compared to containers as multiple containers can run in parallel on a single node, networked together by Docker.

## Docker Projects

### Uptime Kuma

[![uptime kuma](/img/uptime-kuma.svg)](https://github.com/louislam/uptime-kuma)

I wanted to be able to host applications on my Pi cluster using Docker. I've got a deployment running [Uptime Kuma](https://github.com/louislam/uptime-kuma), a self-hosted monitoring dashboard.

If you visit [status.michaellamb.dev](https://status.michaellamb.dev) you can view this application. Of course, to set up the subdomain required me to make some DNS changes. Since I only use Google as the domain registrar and prefer the encrypted email service provided by ProtonMail for secure correspondence, I opted to use Cloudflare to provide DNS entries. Cloudflare is able to use my home network IP and serve michaellamb.dev websites and apps. All of this Cloudflare directed traffic is first sent through a proxy manager.

### Nginx Proxy Manager

[![nginx proxy manager](/img/nginx-proxy-manager.png)](https://github.com/NginxProxyManager/nginx-proxy-manager)

I am interested in hosting more applications and I wanted to leverage nginx as a proxy manager as I add more applications to my cluster. [Nginx Proxy Manager](https://github.com/NginxProxyManager/nginx-proxy-manager) fits the bill as it allows me to add proxy hosts and serve applications over SSL using Let's Encrypt. As traffic comes in from Cloudflare, the proxy manager directs it to the correct node in my cluster.

## Introducing status.michaellamb.dev

[![status.michaellamb.dev](/img/favicon.png)](https://status.michaellamb.dev)

[status.michaellamb.dev](https://status.michaellamb.dev) is where you can go to see the applications I'm running on my cluster. Since I consider the cluster to be an opportunity to pratice learning in public, I hope it is an interesting way for the people who happen to read this blog to stay connected. If you're in Jackson and want to talk tech, connect with me on my socials. Find them all at [link.michaellamb.dev](https://link.michaellamb.dev).

[uptime-kuma]: https://github.com/louislam/uptime-kuma
[proxy-manager]: https://github.com/NginxProxyManager/nginx-proxy-manager
