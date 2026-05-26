---
layout: post
title: "Hermes Agent isn't free under your Claude subscription — correcting last week's post"
date: 2026-05-26
category: machine-intelligence
image: "/seo/2026-05-26-hermes-agent-cost-correction.png"
tags:
- ai
- agents
- hermes
- billing
- correction
published: true
---

Five days ago I [wrote about setting up Hermes Agent]({% post_url 2026-05-21-hermes-agent %}) and announced it on LinkedIn. The LinkedIn post is now gone. I took it down after my extra-usage balance on Claude.ai went from sixty dollars to zero in a handful of hours. The blog post itself stays up — it's a learning log, and what I learned includes being wrong about this — but it needs a correction, and that's what this is.

## What I implied, and what's actually true

The original post closed on this line:

> The Hermes I set up was running *Claude* the whole time, wearing a "Claude Code" nametag. The model was the same brain; the body around it was different.

That part is technically true. Hermes does import the Claude Code OAuth token (`source: claude_code`) into its credential pool at `~/.hermes/auth.json`, and by default it talks to Anthropic with that token. Same Claude, same login, same account — so a reader can be forgiven for inferring the obvious next sentence: same billing bucket as Claude Code. Same subscription claim. Free to run.

That inference is the part that's wrong, and I want to be specific about why, because the surface story sounds airtight.

## Two budgets, not one

Anthropic's unified rate limiter doesn't track one number per account. It tracks at least two:

- **Plan windows** — the 5-hour and 7-day claims that come with a Pro or Max subscription. This is what claude.ai/settings/usage shows you as a percentage. When you use the official Claude apps and the official Claude Code CLI, this is the budget you're drawing down.
- **Overage wallet** — a separate balance of pre-paid "extra-usage" credits you top up by hand at claude.ai/settings/usage. This is real money, billed against your card, not subscription headroom.

The limiter routes individual requests onto one path or the other based on the *shape* of the request — model, context size, tool count, `max_tokens`, retry behavior. A small chat message with a short system prompt stays inside the plan-window claim. A request from a maximally-equipped coding agent — Opus, a system prompt that includes every loaded skill, a tool list dozens deep, a high `max_tokens` ceiling, three automatic retries on transient failures — gets routed onto the overage path.

Hermes's defaults are, almost by design, the second kind of request. The TUI banner in the original post listed twenty-nine toolsets and eighty-nine skills loaded into context. The default model is `claude-opus-4-7`. The retry behavior is built in. Every Hermes turn looks, from Anthropic's perspective, like exactly the kind of bursty heavy request the overage path is for.

## How I found out

I noticed Hermes returning a 400 error that wouldn't clear. My first guess was the stuck "exhausted" flag that Hermes caches on its credential pool entry when a request is rejected — there's a `last_status: "exhausted"` field in `~/.hermes/auth.json`, and the recovery is to null it out. I did. The 400 came right back.

The actual diagnosis was in the response headers, which you can only see if you bypass the SDK's parsing:

```python
from agent.anthropic_adapter import build_anthropic_client
client = build_anthropic_client(token)
raw = client.messages.with_raw_response.create(model="claude-opus-4-7", ...)
print(dict(raw.headers))
```

The interesting lines were:

```http
anthropic-ratelimit-unified-5h-utilization: 0.24
anthropic-ratelimit-unified-7d-utilization: 0.31
anthropic-ratelimit-unified-overage-status: rejected
anthropic-ratelimit-unified-overage-disabled-reason: out_of_credits
```

The plan windows were a quarter full. The overage wallet was empty. claude.ai showed me a green dashboard the whole time — because by *its* definition I was nowhere near my limit. Hermes was failing because the route the limiter had quietly assigned it had run out of money, not because the subscription had.

By the time I understood that, sixty dollars in extra-usage credits were gone. I never bought them on purpose; I'd turned on auto-top-up at some point and forgotten, and Hermes had spent days happily drawing them down while I thought it was running for free.

## What this means if you're considering Hermes

The mental model from the original post — Claude's mind, Hermes's body — is still correct as a description of the stack. The error was treating it as a description of the *bill*. So:

- **Treat Hermes as a paid API client, not a subscription perk.** Sharing an OAuth token doesn't mean sharing the budget. The limiter decides where each request lands.
- **The cleanest isolation is a separate API key.** Provision a fresh key at console.anthropic.com, drop it in `~/.hermes/auth.json` as a second pool credential, and the Hermes burn shows up as its own line item instead of mingling with your subscription.
- **If you stay on the subscription token, downshift the request shape.** Lower `max_tokens` in `~/.hermes/config.yaml`, prune skills you don't actually need loaded, and consider Sonnet for routine work. One trap to know: Hermes's model catalog auto-routes `claude-sonnet-4-6` to the Nous provider, not Anthropic. If your Nous wallet is empty (mine was) that's a separate failure mode. Force the Anthropic route with `hermes --provider anthropic` or `/model` in-session.
- **Watch the headers, not the dashboard.** `anthropic-ratelimit-unified-overage-status` and `…overage-disabled-reason` are the truth. claude.ai's "you're fine" can coexist with Hermes burning real money.

The original post is still up, with a banner at the top pointing here. The technical description of what a harness is hasn't changed — Hermes is still an interesting tool and Claude is still its brain. The only thing I'd retract is the implied price tag, and that's what this post is for.

I publish what I'm learning. Sometimes what I'm learning is that I was wrong five days ago.
