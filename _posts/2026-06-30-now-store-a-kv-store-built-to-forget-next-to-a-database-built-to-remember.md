---
layout: post
title: "now-store: A KV Store Built to Forget, Next to a Database Built to Remember"
date: 2026-06-30
category: software
image: "/seo/2026-06-30-now-store-a-kv-store-built-to-forget-next-to-a-database-built-to-remember.png"
tags:
- kotlin
- ktor
- cloudflare
- sqlite
- homelab
published: true
---

In [the last now-page post]({% post_url 2026-06-01-adapting-the-now-convention %}) I said there was one piece I hadn't built yet: a way to drop a one-line status that publishes in seconds and clears itself at midnight. I've built it since. It's called `now-store`, and for a few weeks now it's been the thing rendering the "Recently updated" section of [`/now`]({{ site.url }}/now.html).

It's also not the first thing on `kotlin-tutorial` that calls itself a notes store. There's already [a `/notes` CRUD API]({% post_url 2026-06-05-persisting-an-in-memory-kotlin-crud-api-to-sqlite-with-exposed %}) on that same service, backed by SQLite, that anyone can write to. `now-store` is a second one, deliberately built to disagree with the first on almost every axis it occupies: a different platform, a different storage primitive, a different audience, a different relationship with time. I didn't build it that way by accident. Two notes APIs that disagree about everything teach more side by side than either one does alone.

## Same job, two different answers

| | `/notes` | `now-store` |
|---|---|---|
| Platform | Ktor on `node5`, the Pi cluster | Cloudflare Worker, the edge |
| Storage | SQLite on disk, via Exposed | Workers KV |
| Lifetime | Durable — survives every restart | Ephemeral — expires on its own |
| Who can write | Anyone who can `POST` to the API | Only me, through an authenticated path |
| Why it exists | Teaches Ktor request/response idioms | Powers the curated layer of `/now` |

Both are "publish a short note, see it on the website." Past that sentence they share nothing. That's the lesson.

## Why `/notes` remembers

I've [written before]({% post_url 2026-06-05-persisting-an-in-memory-kotlin-crud-api-to-sqlite-with-exposed %}) about giving `/notes` a real backing store — SQLite on disk via Exposed, mounted on a named volume so it survives every deploy. The short version: `/notes` is a teaching artifact for Ktor itself, and the most honest way to teach "how do you persist what a handler writes down" is to actually persist it. That post ends with an open invitation — *"add your own note at `/notes`. It'll outlive my next deploy right alongside mine."* — and I meant it literally. There's no auth on any of those routes:

```kotlin
post {
    val req = call.receive<CreateNoteRequest>()
    if (req.title.isBlank()) {
        return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "title required"))
    }
    val created = repo.create(req)
    call.respond(HttpStatusCode.Created, created)
}
```

No header check, no token, no allowlist. `PUT` and `DELETE` are the same. `/notes` is a public sandbox by design — a shared CRUD surface anyone can poke at to see Ktor's request/response idioms in action, durable specifically so a stranger's note isn't erased by my next `git push`.

## Why `now-store` forgets, on purpose

`now-store` is the opposite bet. Every entry is one Workers KV key (`entry:<uuid>`), written with a per-key `expirationTtl`. There's no scheduled job that sweeps old rows — the platform just stops returning a key once its TTL lapses:

```javascript
/**
 * Each entry is one KV key (`entry:<uuid>`) with a per-key expiration, so
 * entries vanish on their own — no cron, no cleanup. Expiry is chosen at
 * create time: "today" (next midnight America/Chicago, the default), "day"
 * (+1 day), or "week" (+1 day extended to +1 week).
 */
```

That comment is also the answer to the question I asked myself before writing a line of Worker code: Cloudflare's own SQL database, D1, was sitting right there, and I'd just spent a whole post wiring SQLite behind `/notes`. Why not D1 for this too? Because D1 doesn't expire rows on its own — I'd have needed a Cron Trigger to sweep stale entries on a schedule, which is exactly the kind of infrastructure I built `now-store` to avoid owning. KV's per-key TTL turns "delete this later" into a property of the write itself, not a job I have to remember to run.

"Today" means *the next local midnight*, and the fiddly part is that "local" means Central time regardless of where the request happens to land at Cloudflare's edge. The trick is reading the wall clock through `Intl` rather than doing timezone arithmetic by hand:

```javascript
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

`+1 day` and `+1 week` just add 86400 or 604800 seconds on top of that. One footnote worth keeping: KV's minimum TTL is 60 seconds, so an entry posted moments before midnight gets clamped up rather than expiring (or failing) immediately.

## A shape borrowed from outside SQL

If you've reached for Redis's `EXPIRE`, or relied on a queue's message-visibility timeout, this should all feel familiar — it's the same primitive. Key-value stores with built-in expiration are a different category of infrastructure from a relational database, optimized for a different promise. A database promises *this will still be exactly correct whenever you ask*. A TTL'd KV store promises *this will be gone when it's supposed to be gone, and I'm not going to make you write the code that enforces that*. `/notes` needs the first promise — a stranger's note shouldn't quietly vanish. `now-store` needs the second — a status update that's still there next month isn't a feature, it's a bug.

## Cinderella's clock

The expiry isn't just a backend detail — it's deliberately visible on the page. Every entry on `/now` carries its own countdown, rendered server-side by the Ktor widget that reads `now-store`:

```kotlin
private fun expiresIn(epochSeconds: Long): String {
    val secs = epochSeconds - Instant.now().epochSecond
    return when {
        secs <= 0 -> "expiring"
        secs < 3600 -> "expires in ${secs / 60}m"
        secs < 86400 -> "expires in ${secs / 3600}h"
        else -> "expires in ${secs / 86400}d"
    }
}
```

I want anyone reading `/now` to know they're looking at something with a clock on it — Cinderella's dress, not a permanent fixture. Not every entry expires at the same stroke of midnight, either: the admin form lets me extend a note's lifetime to `+1 day` or `+1 week` at publish time, so the countdown next to one entry might read `expires in 6h` while the one above it reads `expires in 4d`. The expiry isn't hidden bookkeeping — it's the entire point being shown back to you.

## Only one of us can write here

This is the difference that actually matters most between the two stores, more than SQLite versus KV. `/notes` is open to the world. `now-store` is open to exactly one caller: the Ktor service itself, and through it, me.

The Worker does no authentication of its own — the whole `now-store.michaellamb.dev` hostname sits behind a Cloudflare Access application with a service-token policy, so an unauthenticated request never even reaches the Worker's code. The Ktor service presents the token as two headers on every call:

```kotlin
private fun HttpRequestBuilder.accessHeaders() {
    if (clientId != null && clientSecret != null) {
        header("CF-Access-Client-Id", clientId)
        header("CF-Access-Client-Secret", clientSecret)
    }
}
```

And the only way to *reach* that code path is through `/admin` on `kotlin-tutorial`, which is gated by a second, completely different Access policy — a one-time PIN emailed to one address, mine. No JavaScript, no JSON, just a plain HTML form:

```html
<textarea name="body" required maxlength="600" placeholder="What did you ship or update?"></textarea>
<input type="url" name="url" placeholder="https://… (optional link)">
<select name="expiry">
  <option value="today" selected>Tonight (midnight Central)</option>
  <option value="day">+1 day</option>
  <option value="week">+1 week</option>
</select>
```

So the same physical service hosts two notes APIs with opposite authorship models: one I built to be a shared, durable scratchpad for anyone who finds it, and one I built to be a signature only I can apply. `/notes` teaches Ktor idioms to whoever's reading. `now-store` teaches me, specifically, what's currently true about my own week.

## Headroom I haven't needed

A couple of honest footnotes. The `/entries` list caps at 10, newest first — I've never actually published more than three at once, so that ceiling is headroom, not a constraint I've bumped into. And because the widget endpoint always returns `200` even when it's quietly degrading, a plain uptime check can't tell "working" from "broken," and the whole hostname sits behind Access besides — so a naive monitor would just see `403`. The fix was a public, KV-aware `/health` endpoint, carved out of Access with a path-scoped Bypass policy, that does a one-key `KV.list({ limit: 1 })` and returns `503` if that throws. Uptime Kuma watches for a plain `200` — no credential required, no false alarm from a healthy degrade.

## What the pair is actually teaching

`/notes` and `now-store` aren't two implementations converging on the same idea. They're two answers to "what does this data need to do," pointed in opposite directions on purpose. One had to be durable and open, because it's a public sandbox and a stranger's work shouldn't disappear. One had to be ephemeral and locked down, because a status update that doesn't decay stops being honest, and a signature anyone could forge stops being mine.

The lesson I'd take elsewhere isn't "use KV" or "use SQLite." It's to ask what a given write is actually promising before picking what stores it — and to notice when a feature needs *opposite* promises from one you've already built, instead of bending the one you have to also cover the new case. Go look at [`/now`]({{ site.url }}/now.html) and watch one of the countdowns. By the time you read this, at least one of them will already be gone — which is the entire point.
