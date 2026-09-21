---
layout: post
title: "A Build Log of my custom Discord Embed Builder app"
image: "/seo/2026-09-21-discord-embed-builder.png"
category: software
tags:
- software
- discord
- vue
- cloudflare
- claude-code
---

## I borrowed an interface everybody already knows

If you have ever built a Discord embed on the web, you already know what my app looks like. Form on the left, live preview on the right, a color swatch somewhere in the middle. That layout is a settled convention, and [embed-builder.michaellamb.dev](https://embed-builder.michaellamb.dev) does not depart from it.

That was the point. I copied the pattern on purpose, because the interface is the part of this problem that is already solved. Every embed builder on the internet arrives at roughly the same split panel, and a person who has used one can use any of them without instruction.

What I wanted was the part none of them had: a builder that keeps working after I close the tab. Something that could watch an RSS feed and post new items into a channel on its own, in a custom embed. The editor was the template. The automation was the reason to build it.

The first commit landed on November 18, 2025. There have been 188 in total, all of them mine, almost all of them written with Claude sitting in the loop.

## Quasar decided the shape of the app

I picked Vue, and picking Vue got me Quasar, and Quasar quietly made the biggest architectural decision in the project before I had thought to make it myself.

Quasar ships a toolbar component and a dialog component that are both very good. Once you have those two things, a particular shape starts to suggest itself: every feature is an icon in the header, and every icon opens a dialog. I did not sit down and design an information architecture. I reached for the components that were in front of me, and the app arranged itself around them.

The result is that there is no router in this codebase, and no Pinia store either. It is one view. Shared state lives in module-level refs inside composables, which is the kind of thing that sounds like a shortcut until you notice it has never once been the reason something broke. Even the OAuth return is not a route — the app sniffs a query parameter on load and swaps the view. A row of icons across the top of the screen is the entire navigation model.

The framework had an opinion. I let it stand.

## The part you can use anonymously

Here is the thing I most want you to try, and you do not need an account for any of it.

Open the app and you get a live preview that renders your embed exactly the way Discord will, updating as you type. Bold, italic, underline, strikethrough, inline code and links all render in the preview, because the preview is not an approximation — it is a reimplementation of Discord's own rendering. There are 30 color presets pulled from Discord's role palette. You can add up to 25 fields, toggle any of them inline so they sit side by side, attach an author block, a thumbnail, a footer, a timestamp, and up to 25 link buttons arranged across five action rows.

![The Discord Embed Builder interface with the editor form on the left and a live Discord-styled preview on the right, showing a trivia night announcement with two inline fields, a footer and a link button](/img/2026-09-21-embed-builder-hero.png)

That screenshot is the whole app. Everything on the left is a form field; everything on the right is what Discord will actually show your server. The counter pinned to the bottom of the editor is tracking the embed against Discord's 6000-character total-size ceiling, which is a limit most people discover by having a message rejected.

Validation runs against Discord's real API constraints rather than a guess at them. If you exceed a field limit or leave a required value empty, a banner appears at the top and publishing is disabled until you fix it. You find out in the editor instead of finding out from a failed webhook.

![The Discord color presets expanded into a grid of thirty swatches below the color picker, with the currently selected Discord blurple swatch marked with a checkmark](/img/2026-09-21-embed-builder-presets.png)

The presets are a small thing that I use constantly. Discord's role colors are a fixed palette that everybody recognizes and nobody remembers the hex values for, so they are all one click away.

When the embed looks right, you have two exits. Export the JSON and paste it wherever you need it, or paste in a Discord webhook URL and send it to a channel directly. Both work logged out. That is a complete, useful tool, and it is where I started.

## Then it went quiet for three months

The project stopped dead in December 2025 and did not move again until March. The reason may surprise you: I had gotten busy with other work and deprioritized this personal project.

<picture>
  <source
    srcset="/img/2026-09-21-commits-per-month-light.png"
    media="(prefers-color-scheme: light)">
  <img
    src="/img/2026-09-21-commits-per-month.png"
    width="1200" height="512"
    alt="Column chart of commits per month showing 31 commits in November 2025, three empty months through February 2026, then a spike of 93 commits in April 2026 followed by smaller monthly totals through September">
</picture>

That chart is the honest shape of the work. Thirty-one commits to get the editor and the OAuth proxy standing up, then nothing at all for three months, then April — ninety-three commits, half the entire project, in a single month. RSS subscriptions, curated queueing, channel watchers and the presence sidecar all arrived in that one spike.

This is the part I find genuinely interesting about building with AI, and it is not the part people usually talk about. The gap did not cost me anything. I came back in March to a codebase I had not thought about for three months and I was productive the same day, because the project carries 18 capability specs and a directory of change proposals describing what was built and why. Every proposal in that directory was archived when its work shipped. None were abandoned.

The specs are not documentation I wrote for other people. They are the thing that let me hand a cold codebase back to Claude — and to myself — and have both of us know what was already true about it. A three-month silence used to mean a week of re-reading my own code. Now it means opening a folder.

Half the project in one month is what re-entry at full speed actually looks like.

## All the best features open up when you log in with Discord

Channel watchers and RSS subscriptions are why I wanted to build a custom embed app in the first place.

An **RSS sub** is a feed URL, a target webhook, and a cadence between five minutes and a day. From there it splits.

In auto-post mode, every new item goes straight to the channel. In curated mode, new items land in a review queue and wait for you to post, edit and post, or dismiss them — which is what I use for anything where a headline might need a human look first. Either mode can render items through one of your saved embeds as a template, substituting {% raw %}`{{item.title}}`, `{{item.link}}`{% endraw %} and friends, so an automated post arrives in your server's styling instead of a generic card. There is a test button that fetches the feed and shows you what it found before you commit to it. If a feed fails three times running, the subscription disables itself rather than quietly hammering a dead URL forever.

**Channel watchers** are the other half. A watcher polls the channels it can read in a server and reposts messages matching a query, and the query is a domain language rather than a substring match:

```text
query := orGroup ('OR' orGroup)*     // implicit AND between terms
term  := '-'? atom                   // a leading '-' negates
atom  := keyword | "exact phrase" | /regex/i | from: | in: | has:
```

So `deploy -staging has:link from:123456` is a valid thing to watch for, and `before:` or `after:` will tell you plainly that they are reserved rather than silently matching as bare words. It parses to flat disjunctive normal form — no parentheses, no nested groups. That ceiling is deliberate. It keeps the parser small enough to be obviously correct, and I have not yet wanted a query it could not express.

Scheduled messages round it out: pick a future timestamp in the publish dialog and the message goes out then. All three features are driven by one Cloudflare Worker cron that fires every minute and fans out to three independent processors, each swallowing its own errors so a bad feed cannot take down your scheduled messages.

These are the features that require logging in, and the reason is simpler than it looks. It is not about secrets — a subscription belongs to a Discord user and has to keep running on a schedule while your browser is closed, so something has to know whose subscription it is. Two honest prerequisites come with that: channel watchers need my bot invited to the server, and creating a webhook from inside the app needs Manage Webhooks on the channel.

## Some of it can't run on Cloudflare

The Worker is the right tool for almost everything here, and completely wrong for one thing.

A Discord bot shows as Online because it holds a WebSocket to Discord's gateway open and heartbeats down it. A Worker cannot do that; it wakes up, does work, and goes away. So there is a small Node service whose entire job is to hold that socket, and it runs on a Raspberry Pi in my homelab, deployed with the same Ansible config that runs everything else on the cluster. The operator dashboard I use to look at usage lives on a Pi too. Two sidecars, both existing purely because serverless has an edge and a persistent connection is over it.

The bot earns its keep beyond the green dot. There are slash commands — `/help`, `/link`, `/rss list`, `/channels list`, `/scheduled list` and `/scheduled cancel` — so you can check what your subscriptions are doing without leaving Discord. Every interaction is ed25519 signature-verified before it is trusted, because that is how Discord expects you to prove a request came from Discord.

## What "mature" actually means here

I have called this my most mature AI-generated codebase, and I would rather show the receipts than assert it.

There is a nine-tab user guide built into the app, covering everything from a sixty-second quick start to a plain-language account of what data is stored and how to delete it. It is deep-linkable — append `?help=open` and it opens on load, which is what the bot's `/help` command points at.

![The built-in nine-tab user guide open over the app, showing the Start here panel with a sixty-second quick start and a note that logging in is not required to build, export or publish](/img/2026-09-21-embed-builder-help-guide.png)

There is a feedback form in the last tab that works logged out, forwards to a Discord webhook I actually read, and has a honeypot field to keep the bots off it. There are 566 unit and integration tests across the app, the Worker and the dashboard, plus 22 end-to-end browser scenarios, with the app's own suite held to an 80 percent coverage gate.

And as of today there is real user monitoring. The app now reports Web Vitals, errors and 24 named product events — things like `publish_submitted` and `rss_feed_tested`, pushed deliberately from the handlers that know the outcome rather than scraped off clicks that do not. All of it routes through a telemetry proxy I run, so the app itself never holds an ingest token.

I am quite pleased with the scrubbing work I did with Claude. Before anything leaves your browser it passes a hook that reduces URLs to origin and path and redacts webhook tokens and OAuth codes outright. A Discord webhook's last path segment is a non-expiring credential — anyone holding it can post to that channel forever. It has no business in a telemetry backend, mine included. I wrote about [how cheap it is to keep data and how rarely anyone deletes it]({% post_url 2026-09-03-no-current-laws-limit-saving-data %}) a few weeks ago, and it would be a poor look to publish that and then quietly log your credentials, so I made sure the software I create respects user privacy.

The easiest data to protect is the data you never collect. RUM still tells me what breaks and where, and the only thing tying an event to a person is a truncated hash of a Discord ID — pseudonymous, not anonymous. It keeps the raw id out of Grafana. It would not hide you from someone who already knows your id and can run the same hash.

## Go build one

Head to **[embed-builder.michaellamb.dev](https://embed-builder.michaellamb.dev)** and make an embed. You do not need an account, you do not need to install anything, and if all you ever do is paste a webhook URL and send one good-looking announcement to your server, the tool has done its job.

If you want the feeds and the watchers, log in with Discord and they are there.

And if you want to talk about any of it — the app, the automations, or what building this way actually feels like — come find me on my Discord server: <https://discord.gg/5tYHVRresd>.
