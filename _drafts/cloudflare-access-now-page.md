---
layout: post
title: "Two Faces of Cloudflare Access: Gating a Worker and a Tunnel Route"
category: homelab
image: "/seo/default.png"
tags:
- cloudflare
- zero-trust
- homelab
- ktor
published: false
---

> Draft / notes. The "Recently updated by Michael" section on my [/now](/now.html)
> page is hand-curated — I publish short blurbs that expire on their own. This is
> the story of wiring it up, and my first use of Cloudflare Access (Zero Trust) in
> the homelab.

## The problem

My blog is a static GitHub Pages site. The `/now` page already shows three *live*
widgets — recently watched (Letterboxd), played (Steam), committed (GitHub) — each
fetched client-side from a little Ktor service on my Pi cluster, reached through a
Cloudflare Tunnel. Those are all auto-derived from public APIs.

I wanted a fourth section that's **hand-curated**: short "here's what I shipped"
blurbs I write myself. That needs two things the rest of the stack didn't have:

1. a **durable store** I can write to, and
2. an **authenticated write path** — only *I* can post — without standing up a
   full backend or, worse, shipping a secret to the browser.

The constraint that shaped everything: the read side is a static page with no
backend, and I didn't want to invent an auth system. Cloudflare was already in the
path (Tunnel + DNS), so I leaned on **Cloudflare Access** as the control plane.

## The shape

```text
/now page          /admin form (Ktor, behind Access email)
   | GET HTML          | GET form / POST entry
   v                   v
kotlin-tutorial.michaellamb.dev   (Ktor on the cluster, via cloudflared tunnel)
   |  /widgets/recently-updated   -> renders the widget (60s cache)
   |  /admin/*                    -> form + write proxy
   |
   |  server-side, presents CF-Access-Client-Id/Secret
   v
now-store.michaellamb.dev   (Cloudflare Worker, behind Access service token)
   |  GET/POST/DELETE /entries
   v
Workers KV   (one key per entry, per-key TTL)
```

The key idea: **both read and write flow through the Ktor service**, which holds
the only credential. The browser never sees a token. The widget renders in Ktor
exactly like the other three, so the static page just points a fourth
`data-src` div at the same trusted host.

## Two faces of Access

This is the part I want to remember. Cloudflare Access is one primitive —
"require identity before this hostname/path" — but I used it two completely
different ways in one feature:

### 1. Service token, in front of a Worker (machine-to-machine)

`now-store.michaellamb.dev` is a Worker that does **no auth of its own**. The
whole hostname sits behind an Access application with a **Service Auth** policy
bound to a service token (`now-store-ktor`). The only caller is the Ktor service,
which presents the token as two headers:

```text
CF-Access-Client-Id:     <token id>
CF-Access-Client-Secret: <token secret>
```

Unauthenticated requests are rejected **at the edge**, before they ever execute
the Worker. No `if (token !== env.SECRET)` inside my code — that check moved to
the platform. Contrast this with the bearer-token pattern I'd used before (a
`Authorization: Bearer $ADMIN_TOKEN` checked inside the app): same idea, but
edge-enforced instead of app-enforced, and the Worker stays blissfully unaware of
auth.

### 2. One-time-PIN email, path-scoped on a Tunnel route (human-to-machine)

The admin form is served by the **same Ktor service** at `/admin`. I put a second
Access application over `kotlin-tutorial.michaellamb.dev/admin` — *path-scoped*, so
`/`, `/widgets/*`, `/tour/*`, `/notes`, and `/swagger` stay public, but `/admin*`
requires login. No identity provider needed: Access's built-in **One-time PIN**
emails a code to my address. The policy is one line: `allow email == me`.

What I find elegant: this is Access layered onto a **cloudflared Tunnel hostname**.
I didn't add an ingress rule or open a port — the tunnel route already existed;
Access just attached to a path on it. Zero new infrastructure on the cluster.

So: a service-token policy on a Worker hostname for the *machine* surface, and an
email policy on a tunnel hostname path for the *human* surface. Same primitive,
two faces.

## KV as a TTL store

Entries should be ephemeral — a "what I shipped" note isn't interesting in a week.
Workers KV has per-key expiration built in, so there's no cron and no cleanup
job: each entry is one key (`entry:<uuid>`) written with an `expirationTtl`, and it
simply vanishes when it lapses. Listing the prefix returns only what's still alive.

The lifetime is chosen when I publish: **tonight** (default), **+1 day**, or
**+1 week**. "Tonight" means the next local midnight, which is the fiddly bit —
midnight where *I* am (America/Chicago), DST and all. The trick is to read the
current Central wall-clock via `Intl` rather than do timezone math:

```js
function secondsUntilNextChicagoMidnight(now = new Date()) {
  const parts = new Intl.DateTimeFormat('en-US', {
    timeZone: 'America/Chicago', hour12: false,
    hour: '2-digit', minute: '2-digit', second: '2-digit',
  }).formatToParts(now);
  const get = (t) => Number(parts.find((p) => p.type === t).value);
  const secondsIntoDay = (get('hour') % 24) * 3600 + get('minute') * 60 + get('second');
  return 86400 - secondsIntoDay;
}
```

`+1 day` / `+1 week` just add 86400 / 604800 to that. Two gotchas worth a footnote:
KV's minimum TTL is 60s (so a "tonight" entry created seconds before midnight gets
clamped up), and KV is **eventually consistent** — a write can take up to ~60s to
read back globally. That second one is a non-issue here because the widget already
caches for 60s, but it's the kind of thing that bites you if you expect read-
your-writes.

## What it cost in infra

Almost nothing, which is the point:

- **No new cluster service** — the read widget and admin form are routes on the
  Ktor service that already powers `/now`.
- **No new tunnel ingress rule** — Access attached to an existing hostname/path.
- **No volume / database on the Pi** — state lives in KV, not on the cluster.
- **No secret in the browser** — the credential lives in the Ktor container env.

The manual one-time bits are all in the Cloudflare dashboard: two Access apps and
one service token. Everything else is code.

## Pointers (for future me)

- Worker + KV: `~/Workspace/now-store/` (`worker.js`, `wrangler.toml`).
- Ktor widget + store client: `kotlin-tutorial` `widgets/RecentlyUpdatedWidget.kt`.
- Ktor admin form + write proxy: `kotlin-tutorial` `admin/AdminRoutes.kt`.
- Container env wiring: `cluster-ops` `group_vars/all/main.yml`.
- The fourth widget div: `now.html`.
