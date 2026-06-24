---
layout: post
title: "Five deploys before last call: a build log for Taproom Trivia's leaderboard"
date: 2026-06-24
category: development
subtitle: "Published at 12:30 AM — three hours after trivia wrapped."
image: "/seo/2026-06-24-five-deploys-before-last-call-a-build-log-for-taproom-trivias-leaderboard.png"
tags:
- claude-code
- react
- cloudflare
- grafana
---

## A leaderboard with a deadline

I run Taproom Trivia at [Fertile Ground Beer Co](https://www.fertilegroundbeer.com/) here in Jackson, and the scoreboard behind it is a small app I call Fertile Ground Events — a React + Cloudflare app that takes paper-graded round scores from an admin console, shows a live leaderboard on the taproom TV, and spits out shareable recap cards when the night is over. Five rounds, ten questions a round, one total per team, and a Final Jeopardy tiebreaker when it comes to that.

What I want to write down isn't the app so much as one *afternoon* of it. Here's the deploy history from a single day:

![GitHub Actions deploy history: five green builds shipped in one evening, from a Grafana Faro instrumentation commit at 2:17 PM to a rank-column fix at 8:27 PM, each finishing in about a minute](/img/2026-06-24-fertile-ground-deploys.png)

Five builds: four features and one hotfix. Two were things I shot off quickly during the afternoon that I knew I wanted before trivia kicked off. Two changes were desired during the game. The singular fix was visually impacting.

## Why the loop is this fast

The stack is built to get out of the way. The front end is React + TypeScript + Vite + Tailwind. The back end is [Cloudflare Pages Functions](https://developers.cloudflare.com/pages/functions/) over a [D1](https://developers.cloudflare.com/d1/) SQLite database, with the admin console gated behind Cloudflare Access. There's no server to babysit and no container to rebuild.

The deploy is a push. A commit to `main` triggers a GitHub Actions workflow that lints, tests, builds, runs any pending D1 migrations, and deploys to Cloudflare Pages — and the whole thing lands in about a minute, which is what those `1m 05s`–`1m 13s` timers in the screenshot are. A minute is short enough that "fix it and push" stops feeling like a deploy and starts feeling like saving a file.

The features themselves I built with [Claude Code](https://claude.ai/code), which is a big part of why five of them fit in an afternoon — but the tool is only half of it. The other half is that a one-minute deploy makes small commits *worth* making. When shipping is cheap, you ship the rank-column fix instead of parking it in a branch for later.

## Observability first: the two afternoon commits

The two early commits aren't features anyone in the taproom would notice. They're the instrumentation I wanted in place *before* I started changing things during a live event.

### Deploy #48 — Grafana Faro RUM

The first commit wires up [Grafana Faro](https://grafana.com/oss/faro/) for real-user monitoring: Web Vitals, errors, and sessions, shipped through a small proxy so the ingest token never touches the browser. The one decision worth calling out is that every signal carries a `surface` attribute — `admin` or `public` — derived from the URL:

```typescript
function surfaceFor(pathname: string): 'admin' | 'public' {
  return pathname.startsWith('/admin') ? 'admin' : 'public';
}
```

The admin console and the public leaderboard are the same app, but they're two completely different audiences: one host, typing scores into a laptop, versus a roomful of people glancing at a TV or following along on their phone. Tagging the session up front means I can filter them apart in Grafana later instead of guessing. And `init` is written so it can never take the app down with it — a missing proxy URL or a thrown error just logs a warning and moves on:

```typescript
export function initFaro(): void {
  const proxyUrl = import.meta.env.VITE_FARO_PROXY_URL as string | undefined;
  if (!proxyUrl || faro) return;
  // ...initialize, then set the surface attribute
}
```

> Telemetry is the one subsystem that should never be load-bearing. If observability can crash the thing it observes, you've built a liability, not a safety net.

### Deploy #49 — the share card as a tracked action

The second commit instruments the part of the app with the most moving parts: generating a shareable PNG recap card. That path rasterizes a React component with `html-to-image`, and it can fail in interesting ways — a slow image decode, or the person tapping "cancel" on the OS share sheet. So the whole export runs inside a Faro *user action*:

```typescript
export async function trackCardGeneration<T>(
  attributes: Record<string, string>,
  run: () => Promise<T>,
): Promise<T> {
  if (!faro) return run();
  const action = faro.api.startUserAction?.('generate_share_card', attributes);
  try {
    const result = await run();
    endAction(action, { outcome: 'success' });
    return result;
  } catch (err) {
    const cancelled = err instanceof Error && err.name === 'AbortError';
    if (!cancelled) faro.api.pushError?.(err instanceof Error ? err : new Error(String(err)));
    endAction(action, { outcome: cancelled ? 'cancelled' : 'error' });
    throw err;
  }
}
```

Two details earn their keep. Everything that happens during `run()` — the image fetches, any error — gets correlated to a single top-level `generate_share_card` action instead of floating around as orphan signals. And a user *cancelling* the share sheet is recorded as an outcome, not pushed as an error, because a cancellation isn't a bug and I don't want it polluting the error rate. The function still rethrows, so the caller's own toast handling doesn't change — the tracking is a wrapper, not a rewrite.

That's the pair: get the leaderboard and the riskiest feature reporting for duty, *then* go change things.

## Polish during the night: the three evening commits

The afternoon was instrumentation. The evening was the event — and the last three commits are the kind of thing you only notice you need once real people are looking at the screen.

### Deploy #50 — auto-scroll in TV presenter mode

The leaderboard has a presenter mode (`?tv=1`) that drops the site chrome, doubles the type size, and is meant to live full-screen on a taproom TV. With a full house, the standings run past the bottom of the screen — and nobody's going to walk over and scroll the TV. This commit makes the leaderboard auto-scroll in presenter mode so every team cycles into view on its own. I'd first noticed the need at a Star Wars trivia night but never asked Claude to build it — until tonight, when I ended up running the public leaderboard myself and couldn't ignore it any longer.

### Deploy #51 — rank the scoring table by score

The admin scoring table — the grid the scorer is typing into behind the bar — originally listed teams in their entry order. This commit re-ranks it by cumulative score after each round is entered, so the running order of the night is right there in the tool I'm already looking at. Less mental math between rounds, fewer "wait, who's actually winning" moments while standings are read out — a change the scoring host, Jack Smith, asked for directly.

### Deploy #52 — widen the rank column

The last one is a one-line polish fix, and it's the most honest commit of the day: `widen rank column so T10+ tied indicators don't overlap`. When two teams tie for tenth, the cell shows a "T10" indicator, and at the old column width that badge collided with the number next to it. I saw it on the TV, fixed the width, pushed, and it was live before the next round. Total elapsed time from "that looks wrong" to "that's fixed in production" was about a minute of CI plus however long it took to find the file.

## The thread

There's an order to that day that I didn't fully plan but would do again on purpose: **instrument before you iterate.** The two boring commits happened first because I realized I had no observability and was about to be in the best possible position to use some. RUM was quick to add with Claude Code, so by the time I was making rapid changes during a live event, error reporting and session data were already flowing.

The rest is just the compounding effect of a cheap deploy. A one-minute push from `main` turns the feedback loop from "batch up changes for a release" into "notice, fix, ship, look again." Claude Code is what let me *write* five changes in an afternoon; the one-minute pipeline is what made it sane to ship them one at a time instead of hoarding them into an all-at-once deploy.

## The takeaway

None of these five commits is clever in isolation — a telemetry init, a tracked async action, an auto-scroll, a sort order, a column width. What made the day work was the shape around them: observability landed first, every change went out small, and the deploy was fast enough that fixing the thing you just saw on the TV cost about as much as ignoring it. That's the build log. The app happens to be a trivia scoreboard, but the loop — instrument, then iterate in small, fast, individually-shippable steps — is the part I keep reusing, whether the thing on the TV is a leaderboard or something a hundred times bigger.

If you want to know more about Taproom Trivia — or just want to talk shop about AI-assisted development — come find me on my Discord server: <https://discord.gg/YOUR-INVITE>.
