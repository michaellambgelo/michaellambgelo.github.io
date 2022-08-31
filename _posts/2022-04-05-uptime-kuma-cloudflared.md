---
layout: post
title: Uptime Kuma - cloudflared integration
category: cluster-computing
image : "/seo/2022-04-05.png"
---

Uptime Kuma, the project behind [status.michaellamb.dev](https://status.michaellamb.dev), recently merged a [pull request][pull-request] which adds an interesting ease-of-use feature: integration with Cloudflare's tunneling technology using `cloudflared`, a tunnel client which simplifies proxying requests from behind a firewall by leveraging the Cloudflare network.

[![pr 1427](/img/2022-04-05-pr-1427.png)][pull-request]

__Pros__:

- Free of charge
- Full GUI, zero-config files
- You can put your Uptime Kuma behind firewall
- No need to expose your real IP
- No need nginx, caddy, traefik etc
- Zero-config SSL
- Free SSL

__Cons__:

- (Not a con if you are already using Cloudflare) Your domain's nameserver have to move to Cloudflare
- add 30MB to the docker base image

Once installed, you can authenticate `cloudflared` into your Cloudflare account and begin creating Tunnels to serve traffic to your origins.

1. Create a Tunnel with [these instructions](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/create-tunnel)
2. Route traffic to that Tunnel:
    - Via [public DNS records in Cloudflare](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/routing-to-tunnel/dns)
    - Or via a [public hostname guided by a Cloudflare Load Balancer](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/routing-to-tunnel/lb)
    - Or from [WARP client private traffic](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/configuration/private-networks)

[pull-request]:https://github.com/louislam/uptime-kuma/pull/1427
