---
layout: post
title: "Install Boxd Card from the Chrome Web Store"
image: "/seo/2026-04-14.png"
category: software
tags:
- letterboxd
- chrome-extension
- beta
---

## One-click install, finally

[Boxd Card](https://boxd-card.michaellamb.dev) is now available on the Chrome Web Store:

👉 [**Install Boxd Card**](https://chromewebstore.google.com/detail/boxd-card/kcholfdhfcojahebmneeeikelffkokdj?authuser=0&hl=en)

The listing is **unlisted** while the extension is in beta, which means you won't find it by searching the Chrome Web Store. The link above is the only way in for now, and that's by design — I want feedback from a small group of early users before I open the listing up to the public.

<!-- TODO: optional hero screenshot (/img/2026-04-11-*.png) -->

## Why this matters

Up until now, installing Boxd Card meant:

1. Download a zip from GitHub Releases
2. Unzip it somewhere you won't accidentally delete
3. Open `chrome://extensions`
4. Toggle on **Developer mode**
5. Click **Load unpacked** and pick the folder
6. Repeat steps 1, 2, and 5 every time there's a new release

That's a lot to ask for a tool that makes a picture of your Letterboxd profile. With the Chrome Web Store install, it's just: click the link, click **Add to Chrome**, done. Updates land automatically in the background — no more zipping, unzipping, or reloading.

## Already running the unpacked version?

If you installed an earlier build via **Load unpacked**, switch over like this:

1. Open `chrome://extensions`
2. Find the existing **Boxd Card** entry and click **Remove**
3. Click the [Chrome Web Store link](https://chromewebstore.google.com/detail/boxd-card/kcholfdhfcojahebmneeeikelffkokdj?authuser=0&hl=en) and **Add to Chrome**

Heads up: Chrome clears an extension's stored settings when you uninstall it, so you may need to re-pick your preferred card type, layout, and display options after switching. It only takes a few seconds in the popup's settings panel.

## How to send feedback

Boxd Card is still beta software, and the whole point of running an unlisted Chrome Web Store listing is to make it easy for early users to tell me what's broken, what's missing, and what's confusing. There are three ways to reach me, in rough order of preference:

- **[GitHub Issues](https://github.com/michaellambgelo/boxd-card/issues)** — best for bugs, crashes, and concrete requests. This is where I triage work, and issues get tracked publicly so other users can +1 or chime in.
- **[GitHub Discussions](https://github.com/michaellambgelo/boxd-card/discussions)** — best for open-ended ideas, questions, or "what if it did this" conversations that aren't quite a bug report.
- **Email: [boxdcardsupport@michaellamb.dev](mailto:boxdcardsupport@michaellamb.dev)** — if you'd rather not sign up for a GitHub account, or you just want to send a quick note, this goes straight to me.

Whichever channel you pick, screenshots and the URL of the Letterboxd page you were on when things went sideways are always helpful.

## What "beta" means

Practically, "beta" means the listing stays unlisted for now, and I treat every piece of feedback that comes in as load-bearing. I'd rather ship a small tool that feels right to a few people than a big one that's confusing to everyone.

<!-- TODO: tighten up these exit criteria in your own words before publishing -->

A rough bar for graduating to a public Chrome Web Store listing:

- No open issues tagged as bugs for all six card types across all six layouts
- At least one full week where new feedback is cosmetic or feature-wishlist, not "this is broken"
- I'm confident explaining what Boxd Card does to someone who's never opened Letterboxd

Until then: thanks for trying it, and thanks in advance for telling me what's wrong with it.

## Try it

[Install Boxd Card from the Chrome Web Store](https://chromewebstore.google.com/detail/boxd-card/kcholfdhfcojahebmneeeikelffkokdj?authuser=0&hl=en), generate a card from your profile, and share it somewhere. If it helps one person skip the Friday-morning screenshot-and-crop ritual, that's a win.
