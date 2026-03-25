---
layout: post
title: "Don't screenshot your Letterboxd Last Four Watched anymore"
image: "/seo/2026-03-25.png"
category: software
tags:
- letterboxd
- chrome-extension
- react
- typescript
---

## On Fridays, we post our Last Four Watched
     
On Threads or Bluesky, I'll look for a post from the official Letterboxd account. This post in particular will feature an image from a film, usually in two panels, where a user's Last Four Watched movies are photoshopped in. It is a ritual of screenshotting, cropping, and perhaps writing copy content before posting. When it comes to sharing attractive layouts of your Last Four Watched, there's not a native way to do it on letterboxd.com or the mobile app. 

## Introducing boxd-card (beta)

[![Boxd Card logo](/img/2026-03-25-boxd-card-favicon.svg)](https://boxd-card.michaellamb.dev)

Boxd Card is web browser extension that generates a shareable image card from your Letterboxd profile. A web app version also exists but faces some technical limitations, so for the full-featured experience I recommend taking the 4 steps required to install the browser extension. 

## What it generates

![Top 10 2025 releases ranked](/img/2026-03-25-boxd-card.png)

The above image is a generated card showing 10 films from a given list.

![Screenshot of extension creating example image](/img/2026-03-25-Screenshot.png)

### Card types

- Last Four Watched (the flagship)
- Favorites
- Recent Diary
- List (with 4, 10, or 20 films)
- Review

## How it works under the hood

### Web browser extension (beta)

The extension reads film metadata and poster images directly from the Letterboxd page DOM — no backend, no API calls, no CORS workarounds. Poster images are fetched cross-origin by the background service worker (which has the necessary host permissions) and drawn to an HTML5 Canvas to produce the final PNG.

The web browser extension works with any Chromium-based browser with developer mode enabled.

### Web app (beta boxd-card.michaellamb.dev/app/)

The web app exists but has some technical limitations that prevent it from being as feature-rich as the browser extension. It uses a Cloudflare Worker to proxy requests to Letterboxd, which unfortunately blocks some requests using WAF rules. Last Four Watched and Favorites work fine, but other card types may not work as expected. This is because the web app cannot directly access the Letterboxd page DOM like the browser extension can, and the proxying adds an extra layer of complexity. WAF rules block known browser automation tools, making it difficult to scrape data directly from the page. An API integration with Letterboxd could assist with this, but I have not submitted a request for credentials.

## Getting started

1. Download and unzip the [latest release](https://github.com/michaellambgelo/boxd-card/releases)
2. Open `chrome://extensions` in Chrome/Edge/Brave
3. Enable **Developer mode** (top-right toggle).
4. Click **Load unpacked** and select the unpacked extension folder.

## What's next

Please use the extension to generate attractive cards so you can share and discuss the movies you love. It is my hope that this tool will help others connect over their shared love of cinema.

Are you looking to get this tool to work how **YOU** want? Please use the [Discussions](https://github.com/michaellambgelo/boxd-card/discussions) board to request features, report bugs, or discuss other potential improvements.

Feel free to clone the repository and submit pull requests if you want to contribute. 
