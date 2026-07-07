---
layout: post
title: "Anatomy of a trivia deck, part 1: a presentation app with no backend"
date: 2026-07-07 09:00:00 -0500
category: development
subtitle: "First in a five-part series on the architecture of the pub-trivia scaffold."
image: "/seo/2026-07-07-anatomy-of-a-trivia-deck-part-1-no-backend.png"
tags:
- react
- javascript
- architecture
- trivia
---

## Adding a screen to trivia was my first priority

I organize Taproom Trivia at [Fertile Ground Beer Co](https://www.fertilegroundbeer.com/) here in Jackson. I've written about the [leaderboard side of trivia night]({% post_url 2026-06-24-five-deploys-before-last-call-a-build-log-for-taproom-trivias-leaderboard %}) — the React + Cloudflare app that tallies scores. This series is about the other screen: the presentation deck itself, the thing that shows the room every question, every recap, and the animated intermission telling everyone to refill their beer.

That deck is a project I call the **pub-trivia scaffold**. It's a React + Vite app with a deliberately unusual constraint: it has no backend at all. No server, no database, no API, no accounts. Everything — questions, tiebreakers, the picture round's actual images, the title-slide copy — lives in the browser and travels between machines as a single JSON file.

This blog series walks through how it works, one subsystem per post:

1. **This post** — why browser-only, and the overall shape.
2. **The `<deck-stage>` element** — a vanilla web component that hosts React slides.
3. **Two windows, one channel** — the display/control split over `BroadcastChannel`.
4. **The data layer** — localStorage patterns, storage quota lessons, and the deck bundle.
5. **Theming as an architectural dimension** — how one codebase becomes many decks.

I write this for anyone who wants to better understand how I work with AI to generate code and design systems, automated test suites, and more.

## Why no backend?

A trivia deck has a hostile deployment environment: a bar. Attendees might attempt to grab the answer key if secrets are accessible, the "server" is whatever laptop I brought, and the failure mode of a network dependency is forty people watching a spinner instead of question six.

So the constraint became the design: if the app is a static bundle and all state is local, nothing can go down mid-round. The deck deploys to GitLab Pages like any static site, but on trivia night it's effectively an offline app — after the first page load, the network is optional.

There's a second reason, which is that the problem genuinely doesn't need a server. A trivia deck is allowed one screen during our games — there's no multi-user coordination, no auth, no data anyone else needs to read. Reaching for a database here would have been architecture as reflex. Instead, I took a lesson from progressive web app design: treat the browser as the whole platform. localStorage is the database, `BroadcastChannel` is the message bus, and the network's only job is delivering the bundle.

> Every dependency you don't have is a failure mode you don't carry into the room. Design with minimal network connectivity required.

## The shape of the platform

The whole app is about a dozen source files, and they split into three layers that the rest of this series covers in detail:

```text
src/
├── deck-stage.js       the stage: a vanilla web component (scaling, nav, print)
├── App.jsx             display window: composes ~70 slides from data
├── ControlApp.jsx      control window: presenter view + editor + picture round
├── broadcast.js        26 lines of BroadcastChannel glue between the two
├── rounds.js           questions + tiebreakers + import/export
├── meta.js             title/end/next-event copy, slide toggles, timer settings
├── pictures.js         picture-round paste buffer + image ingest
├── handout.js          canvas renderer for the printable picture-round sheet
└── slides.jsx          every slide component + the design system
```

The entry point reads the URL hash and boots one of two roots: `/` renders the **display** (the thing the TV shows) and `/#/control` renders the **control window** (the thing on my laptop). They're the same origin, so they talk over `BroadcastChannel` — a browser API that most people have never needed and that turns out to be the perfect transport for this: no server, no setup, instantaneous.

The display window is intentionally dumb. It loads data from localStorage, composes a flat array of slide components, and hands them to `<deck-stage>` — a custom element that handles scaling to whatever screen it's on, keyboard navigation, and printing. All the interesting editing lives in the control window, and edits arrive as broadcast messages.

## A deck that is also a scaffold

One more thing shapes the architecture, and it's intentional: this repo is both a runnable Taproom Trivia deck *and* the source-of-truth template that themed decks are cloned from. When I need a Star Wars night or a Pokémon night, a Claude Code skill copies the repo and re-skins every theme-leak point — palette, copy, fonts, questions — while the engine underneath stays byte-identical.

That dual role is a discipline. Every hardcoded string is either engine (never touched) or theme content (documented as a replaceable anchor), and the boundary between them is written down. Part 5 digs into how that contract works, because it changed how I write even the CSS.

**Next up**: the `<deck-stage>` element, and why the most React-heavy app I run at the brewery has a vanilla web component at the center of it.
