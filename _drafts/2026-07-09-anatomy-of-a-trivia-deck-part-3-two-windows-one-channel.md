---
layout: post
title: "Anatomy of a trivia deck, part 3: two windows, one channel"
date: 2026-07-09 19:00:00 -0500
category: development
subtitle: "Part 3 of 5 — the display/control split over BroadcastChannel, and a timer that knows when it's on stage."
image: "/seo/2026-07-09-anatomy-of-a-trivia-deck-part-3-two-windows-one-channel.png"
tags:
- javascript
- react
- architecture
- trivia
---

## The presenter-view problem

Every presentation tool eventually grows a presenter view: the audience sees the slide, the presenter sees the slide *plus* what's next, notes, and controls. Keynote does it with two rendering pipelines. The trivia scaffold does it with two browser windows and a messaging primitive most web developers have never had a reason to touch.

The URL hash picks the personality. `/` boots the display — the fullscreen deck from [part 2]({% post_url 2026-07-07-anatomy-of-a-trivia-deck-part-2-deck-stage %}) — and `/#/control` boots a completely different React root: a dark, dense control panel with a presenter tab (live slide outline, timer controls), an editor tab (every question, every slide's copy), and the picture-round tab. On trivia night the TV gets the display window and my laptop gets control.

They coordinate over [`BroadcastChannel`](https://developer.mozilla.org/en-US/docs/Web/API/BroadcastChannel), and the entire transport layer is this:

```javascript
const CHANNEL_NAME = 'pub-trivia-scaffold';

let _channel = null;
function getChannel() {
  if (!_channel) _channel = new BroadcastChannel(CHANNEL_NAME);
  return _channel;
}

export function broadcast(type, payload) {
  getChannel().postMessage({ type, payload });
}

export function useBroadcast(handler) {
  useEffect(() => {
    const ch = getChannel();
    const wrapped = (e) => handler(e.data);
    ch.addEventListener('message', wrapped);
    return () => ch.removeEventListener('message', wrapped);
  }, [handler]);
}
```

Twenty-six lines. Same-origin windows, structured-clone payloads, no server, no handshake, no reconnect logic. This is the whole reason the no-backend constraint from [part 1]({% post_url 2026-07-07-anatomy-of-a-trivia-deck-part-1-no-backend %}) holds: the one thing that *looks* like it needs a server — two screens staying in sync — is a browser built-in.

> If you haven't met this API before, the [MDN BroadcastChannel documentation](https://developer.mozilla.org/en-US/docs/Web/API/BroadcastChannel) is a five-minute read: same-origin browsing contexts — tabs, windows, iframes, even workers — publishing structured-clonable messages to a named channel. Baseline-available in every modern browser.

## The message contract

Everything crossing the channel is a `{ type, payload }` object, and the protocol stays small enough to hold in your head:

| Direction | Types |
| --- | --- |
| control → display | `rounds:update`, `meta:update`, `pictures:update`, `tiebreakers:update`, `nav:next` / `nav:prev` / `nav:goto`, `timer:toggle` / `timer:reset` / `timer:adjust` |
| display → control | `slidechange`, `timer:state` |
| control → display | `sync:request` (on mount: "tell me where you are") |

Two design choices matter more than the list itself.

**Content messages carry full state, not diffs.** `rounds:update` ships the entire rounds array; `pictures:update` ships all ten picture slots. That sounds wasteful until you price in what diffs cost: ordering bugs, missed messages, merge logic. Full-state messages are idempotent — whatever arrives last is the truth. When a late-joining window might have missed anything, `sync:request` makes the display re-announce itself, and the same idempotence makes that trivially safe.

**Edits are buffered; navigation is live.** The editor tab accumulates changes into a draft with a dirty flag and only broadcasts on "Save & Push to Display" — nobody wants a half-typed question flashing onto the taproom TV. But navigation and timer controls fire immediately, because that's the host performing the action.

## The timer that knows it's on stage

The subtlest piece of the whole app is the question timer, because it inverts where you'd expect state to live. There is no global timer. Each of the ~40 question slides owns a private countdown, and every one of them hears every timer broadcast — remember from part 2 that slides stay mounted. So how does pressing "pause" on my laptop affect exactly one timer?

Each slide tracks whether it's the active slide, using the stage's `slidechange` event:

```jsx
useEffect(() => {
  const mySection = ref.current?.closest('section');
  if (!mySection) return;
  setIsActive(mySection.hasAttribute('data-deck-active'));
  const handler = (e) => setIsActive(e.detail.slide === mySection);
  document.addEventListener('slidechange', handler);
  return () => document.removeEventListener('slidechange', handler);
}, []);
```

And then every broadcast handler starts with the same guard:

```jsx
useBroadcast(useCallback((msg) => {
  if (!isActive) return;   // only the slide on stage responds
  if (msg.type === 'timer:toggle') setPaused((p) => !p);
  // ...
}, [isActive, /* ... */]));
```

The control window doesn't address a slide — it shouts into the room, and the one slide that's on stage answers. The active slide also emits `timer:state` back on every tick, which is what the control panel's live timer readout renders. Navigating away resets the incoming slide's clock on activation, so re-entering a question always starts fresh.

> Broadcast-and-filter beats addressing. When receivers know their own context, the sender doesn't need a routing table.

There's one sharp edge worth recording: on activation, the slide resets its clock *and broadcasts the fresh value in the same effect*. An earlier version broadcast from a separate effect that read the old state, and the control window would flash a stale count for one frame. Distributed-systems bugs show up even when the "distributed system" is two tabs on the same laptop.

Next: the data layer — localStorage as the only database, and what a 7.8MB photo taught me about its quota.
