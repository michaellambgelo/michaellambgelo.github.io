---
layout: post
title: "Re-introducing status.michaellamb.dev"
date: 2026-04-30
category: infrastructure
image: "/seo/2026-04-30-re-introducing-status-michaellamb-dev.png"
tags:
- cloudflare
- raspberry-pi
- observability
- cluster
published: true
---

Four years ago I [introduced status.michaellamb.dev]({{ site.url }}/2022/03/introducing-status_michaellamb_dev.html). It was a small win in the way homelab projects often are: a self-hosted uptime page on the Raspberry Pi cluster, fronted by Nginx Proxy Manager, with Cloudflare DNS pointed at my home IP. Most of the satisfaction came from having built it end-to-end, not from anyone visiting it.

A few weeks later I [moved it onto a Cloudflare Tunnel]({{ site.url }}/2022/04/uptime-kuma-cloudflared.html), which obviated half of that stack. That post called out, with what now feels like prescient enthusiasm, "no need for nginx, caddy, traefik" — and four years on, none of those are running on the cluster.

Sometime in 2023 or 2024, two of my six Pis (`node5` and `node6`) quietly drifted off the LAN. I noticed in the way you notice a flickering light bulb — there, then gone, annoying to notice but never quite important enough to prioritize. A Kuma bot had been deployed to `node6` and would auto-start on reboot from a 2021-era instance. It still had outbound internet, so when monitors flapped it kept hitting Discord webhooks, remembering all the old web assets I was tracking. The page itself returned a tunnel error to anyone who clicked the link, but I rarely opened it or told people about it. 

Today I restarted the whole thing. Not as a recovery — nothing was actually destroyed — but as a fresher view of the landscape around `michaellamb.dev`.

## What's running now

The ecosystem has matured a lot since 2022, and so has the way I want to use uptime-kuma. The new setup is smaller and more deliberate:

- **uptime-kuma on `node3`** — single Docker container, persisted to a named volume, exposed only over the loopback and to the LAN.
- **cloudflared on `node6`** with one public-hostname route: `status.michaellamb.dev` → `http://node3:3001`. TLS terminates at the edge; the tunnel hop to `node3` is plain HTTP over the LAN. No NPM, no DNS-to-home-IP, no Let's Encrypt cron.
- **Nightly backups** of the kuma volume — container stopped briefly, tarball streamed out, container restarted, retained 31 days locally, and rsynced off-host to `node4` for a second copy. (Building this turned out to be its own adventure with snap-confined Docker — the obvious recipe from a [2023 post]({{ site.url }}/2023/12/container-relocation.html) doesn't work under Ubuntu's default Docker package, and the workaround is worth its own post.)
- **A push monitor** for `discord-embed-builder-presence` — the Discord bot in the cluster

## Why a reset rather than a rescue

I could have chased the network drift on `node5`/`node6`, brought the old kuma container back to life, and inherited five years of cobwebs. The kuma database from 2021 had a monitor list that reflected what I cared about *then* — services I no longer run, hosts that no longer exist, a homelab shaped like a different homelab.

The reset turned out to be more interesting. The questions I want a status page to answer in 2026 are different than they were on day one. The cluster has different shapes now — a Discord bot here, a Cloudflare Worker for telemetry over there, GitHub Pages apps elsewhere — and the monitors should match.

There's also a small physical-world consequence of this rebuild, thanks to Claude Code: my Pis were unlabeled in the rack, and I've since lost the 3x5 notecard I used to diagram which node hostname happened to map to which physical device. Each one now blinks its green ACT LED its own hostname digit, perpetually, courtesy of a tiny `systemd` LED-ID service. Before today I literally couldn't tell `node5` from `node6`. Now I can identify either in five seconds from across the room.

## A short timeline

- **2021-03**: [cluster built and brought up]({{ site.url }}/2021/03/cluster-computing.html), Ansible installed on `node1`.
- **2022-03**: [status.michaellamb.dev introduced]({{ site.url }}/2022/03/introducing-status_michaellamb_dev.html) on uptime-kuma + Nginx Proxy Manager + Cloudflare DNS.
- **2022-04**: [moved to cloudflared]({{ site.url }}/2022/04/uptime-kuma-cloudflared.html), shedding the proxy-manager layer.
- **2023–2024**: `node5` and `node6` quietly went unreachable; uptime-kuma kept doing its job from one of them; I rarely opened the page.
- **2026-04-30**: full reset, with the surrounding cluster work to make this version more durable.

## Where to find it

[status.michaellamb.dev](https://status.michaellamb.dev) is live again. The monitor list is now a reflection of the michaellamb.dev apps of today. Notifications go to Discord. If you click through and something looks broken, you mnight see it before I do.

If you'd like more of these little homelab posts, the [newsletter](https://subscribe.michaellamb.dev) is the easiest way to catch them. The cluster is back to the kind of state where there's something worth saying about it again.
