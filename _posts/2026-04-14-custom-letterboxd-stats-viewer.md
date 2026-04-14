---
layout: post
title: "Custom Letterboxd Stats Viewer"
image: "/seo/2026-04-14-custom-letterboxd-stats-viewer.png"
category: software
tags:
- letterboxd
- data-pipeline
- github-actions
- static-site
---

## From gallery template to stats dashboard

[letterboxd-viewer](https://github.com/michaellambgelo/letterboxd-viewer) started life in February 2025 as a fork of HTML5 UP's [Multiverse](https://html5up.net/multiverse) template — a jQuery + Poptrox lightbox gallery meant for showing off portfolio screenshots. The first commit was the template dropped in verbatim: `index.html` wired to Poptrox, a Font Awesome icon strip, and a grid of Unsplash placeholder images.

The original ambition was a shareable "Last Four Watched" card backed by a Cloudflare Worker that would scrape any Letterboxd profile on demand. That direction got abandoned after it became clear the card-rendering problem and the stats-dashboard problem were different products. The card idea now lives in [boxd-card](https://github.com/michaellambgelo/boxd-card) as a Chrome extension. Everything else collapsed into a single static page: my personal Letterboxd history, pre-aggregated and rendered client-side.

Today the repo keeps only the aesthetic DNA of Multiverse. jQuery and Poptrox are gone, replaced by vanilla JS and Chart.js. The gallery grid is replaced by a GitHub-contributions-style heatmap, a rating histogram, a decade breakdown, and a rewatch leaderboard.

## Why this is harder than it looks

Letterboxd has no public API. The only programmatic surface is a per-user RSS feed, and it caps at **50 most recent items**. For a moderately active watcher that's about three weeks of history. A dashboard built on that alone would forget my 2024 binge of A24 films every time the feed rolled over.

The workaround is a two-source merge:

1. A one-time **Letterboxd export archive** (the ZIP of CSVs you can download from your account settings) seeds the full historical baseline.
2. A **GitHub Actions cron** polls the RSS feed every six hours and commits the snapshot to the repo.

The clever part is step 2. Because every RSS fetch is a commit to `data/rss.xml`, the complete rolling record of what the feed has ever returned is preserved in git history itself. The extract step walks `git log --reverse -- data/rss.xml` and dedupes across every snapshot the repo has ever seen. The 50-item window becomes a moving sampler, and git becomes the append-only log.

## Pipeline

```text
 ┌────────────────────────┐     ┌─────────────────────────┐
 │ Letterboxd export ZIP  │     │  Letterboxd RSS feed    │
 │ (historical baseline)  │     │  (50 most recent items) │
 └───────────┬────────────┘     └────────────┬────────────┘
             │                               │
             │                   ┌───────────▼───────────┐
             │                   │  download_rss.py      │
             │                   │  • fetch RSS          │
             │                   │  • strip HTML noise   │
             │                   │  • commit rss.xml     │
             │                   └───────────┬───────────┘
             │                               │
             │                   ┌───────────▼───────────┐
             │                   │       git log         │
             │                   │  every rss.xml commit │
             │                   └───────────┬───────────┘
             │                               │
             └──────────────┬────────────────┘
                            │
                ┌───────────▼────────────┐
                │  extract_history.py    │
                │  • merge archive + RSS │
                │  • dedupe (title,year, │
                │    watchedDate)        │
                └───────────┬────────────┘
                            │
                ┌───────────▼────────────┐
                │  viewing_history.json  │   (intermediate, ~1.1 MB)
                └───────────┬────────────┘
                            │
                ┌───────────▼────────────┐
                │   compute_stats.py     │
                │  • totals, averages    │
                │  • rating histogram    │
                │  • decade buckets      │
                │  • 52-week heatmap     │
                │  • rewatched, lists    │
                │  • per-year slices     │
                └───────────┬────────────┘
                            │
                ┌───────────▼────────────┐
                │      stats.json        │   (pre-computed, ~300 KB)
                └───────────┬────────────┘
                            │
                ┌───────────▼────────────┐
                │      deploy.yml        │
                │  • inject webhook URL  │
                │  • push to gh-pages    │
                └────────────────────────┘
```

Three Python scripts do all the work, each idempotent and runnable locally:

- `scripts/download_rss.py` — fetches the RSS feed, removes poster `<img>` tags and other non-renderable HTML so the committed XML stays clean and diffable.
- `scripts/extract_history.py` — the merge step. Reads the archive CSVs as the baseline, then replays every historical `rss.xml` commit and layers deltas on top, deduping by the composite key `(filmTitle, filmYear, watchedDate)`.
- `scripts/compute_stats.py` — reads `viewing_history.json` and writes the ~15 aggregate fields the frontend needs.

The cron workflow (`download-data-and-assets.yml`) runs on `0 */6 * * *`, requires `fetch-depth: 0` so the git-history walk can reach every prior commit, and on change commits the updated `data/` directory and triggers `deploy.yml` via `workflow_dispatch`.

## Rendering

The frontend is deliberately boring. No framework, no build step, no bundler. `index.html` holds the markup, `assets/js/dashboard.js` fetches `data/stats.json` on load, and Chart.js 4 (loaded from a CDN) draws the bar charts. The heatmap is hand-rolled DOM — a 7-row × 52-column grid with cell opacity mapped to watch count.

```text
 Browser loads index.html
         │
         ▼
 fetch('data/stats.json')            ◄──── pre-computed, static
         │
         ▼
 ┌────────────────────────────────────────────────────────┐
 │  dashboard.js                                          │
 │                                                        │
 │  ┌────────────┐  ┌────────────┐  ┌─────────────────┐   │
 │  │ stat cards │  │  heatmap   │  │    Chart.js     │   │
 │  │ (DOM text) │  │ (DOM grid) │  │ (bar: ratings,  │   │
 │  │            │  │ 7×52 cells │  │  decades)       │   │
 │  └────────────┘  └────────────┘  └─────────────────┘   │
 │                                                        │
 │  ┌──────────────────────┐  ┌───────────────────────┐   │
 │  │ recent activity list │  │ year selector swaps   │   │
 │  │ (DOM table)          │  │ byYear[n] and rerenders│  │
 │  └──────────────────────┘  └───────────────────────┘   │
 └────────────────────────────────────────────────────────┘
```

The **year selector** is the only stateful piece. `stats.json` includes a `byYear` object where each key is a calendar year and the value is a full stats payload scoped to that year's diary entries. Clicking a year swaps the active slice and re-renders all visualizations against it. Because every year's aggregate is pre-computed, the interaction is free — no client-side aggregation, no recomputation, just a property lookup.

## What makes this architecture work

A few things I'd call out for anyone building something similar:

- **Git as an append-only log.** Using commit history to back-fill a capped-size data source is a pattern that generalizes well beyond Letterboxd. Any public feed with a small rolling window (Twitter-style timelines, Mastodon, BGG plays, GitHub events) can be accumulated this way with nothing more than a cron + `git log --reverse`.
- **Pre-compute everything.** The frontend never aggregates. `compute_stats.py` is the single place that knows what a "decade" is or how a rating histogram is bucketed. The browser is dumb by design, which means the page loads fast and the CI machine does the heavy lifting once every six hours instead of 10,000 times in users' tabs.
- **The archive is load-bearing.** RSS alone can't cold-start the dataset. Shipping the historical export CSV into the repo gives the pipeline a baseline it can forever layer on top of.
- **Keep the deploy shape static.** Output is a plain HTML page plus two JSON files on GitHub Pages. No server, no database, no runtime scraping. If Letterboxd rate-limits or the worker evaporates, the dashboard still renders its last-good snapshot indefinitely.

The full repo, including the scripts and the Actions workflows, is at [github.com/michaellambgelo/letterboxd-viewer](https://github.com/michaellambgelo/letterboxd-viewer).
