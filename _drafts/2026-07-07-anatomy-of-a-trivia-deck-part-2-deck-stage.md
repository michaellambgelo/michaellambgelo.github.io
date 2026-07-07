---
layout: post
title: "Anatomy of a trivia deck, part 2: a web component at the center of a React app"
date: 2026-07-07 09:10:00 -0500
category: development
subtitle: "Part 2 of 5 — the <deck-stage> element: scaling, navigation, and print in vanilla JS."
image: "/seo/2026-07-07-anatomy-of-a-trivia-deck-part-2-deck-stage.png"
tags:
- web-components
- react
- javascript
- trivia
---

## The stage is not React

[Part 1]({% post_url 2026-07-07-anatomy-of-a-trivia-deck-part-1-no-backend %}) laid out the shape of the pub-trivia scaffold. This post is about the piece at the center of the display window: `<deck-stage>`, a vanilla-JS custom element that every React slide renders into.

Usage looks like this — React composes the slides, but the element owns the show:

```jsx
<deck-stage ref={stageRef} width="1920" height="1080">
  {slides}
</deck-stage>
```

The stage handles everything a projector app needs and nothing a trivia app specifically needs: auto-scaling a fixed 1920×1080 canvas to whatever screen it lands on, keyboard navigation (arrows, Space, PgUp/PgDn, Home/End, number keys, R to reset), tap zones for driving it from a phone, an auto-hiding slide-count overlay, and print support. It knows nothing about rounds, questions, or timers.

## Why a custom element

Splitting the stage out of React was one decision that keeps paying for itself:

- **The stage is presentation infrastructure, not application state.** Which slide is active, how the canvas scales, what arrow keys do — none of that belongs in React's render cycle. Navigation is a DOM concern with DOM-speed requirements.
- **It's portable.** The same file works in any deck that renders `<section>` children, regardless of framework. The scaffold's sibling decks all share it unmodified, and it originally came from a plain-HTML deck with no build step at all.
- **It forces a clean contract.** React talks to the stage through a ref (`stage.next()`, `stage.prev()`, `stage.goTo(n)`) and listens for one event coming back. That's the whole API.

## The scaling trick

Every slide is authored at exactly 1920×1080 — real pixels, real font sizes, no responsive breakpoints. The stage then scales the whole canvas as a unit:

```javascript
_fit() {
  const vw = window.innerWidth;
  const vh = window.innerHeight;
  const s = Math.min(vw / this.designWidth, vh / this.designHeight);
  this._canvas.style.transform = `scale(${s})`;
}
```

That one `transform: scale()` is why the deck looks identical on my laptop, the taproom TV, and an OBS browser source. Slides get to be dumb about layout — a 560px round numeral is always a 560px round numeral — and the letterboxing falls out of a flexbox centering the canvas.

The slides themselves live in the **light DOM** through a `<slot>`, which matters more than it sounds: the stage's shadow DOM encapsulates its own chrome (overlay, tap zones), but the slides stay in the page where React and the app's styles can reach them. The stage stacks the slotted children and controls visibility:

```css
::slotted(*) {
  position: absolute !important;
  inset: 0 !important;
  opacity: 0;
  visibility: hidden;
}
::slotted([data-deck-active]) {
  opacity: 1;
  visibility: visible;
}
```

## Hidden, not unmounted

Note that inactive slides are hidden with `visibility: hidden` — they are never unmounted. All ~70 slides exist in the DOM for the entire event.

For a deck this is the right trade. Slide content is cheap, and keeping React trees mounted means slide-local state survives navigation: a question slide's countdown timer keeps its value if I flip back to re-read the question, a video keeps its playback position, a form input keeps its text. Unmount-on-navigate would make every slide responsible for serializing its own state, which is a lot of machinery to save a few kilobytes of DOM.

## One event out: `slidechange`

The stage's entire output surface is a single `CustomEvent`, dispatched with `bubbles: true, composed: true` so it escapes the shadow DOM and can be heard on `document`:

```javascript
document.querySelector('deck-stage').addEventListener('slidechange', (e) => {
  e.detail.index;    // new 0-based index
  e.detail.total;    // slide count
  e.detail.slide;    // the active <section> element
  e.detail.reason;   // 'init' | 'keyboard' | 'click' | 'tap' | 'api'
});
```

Everything downstream hangs off this one event. The display window forwards it to the control window so the presenter view highlights the active row. Question slides listen for it to learn whether they're the active slide — which is how the timer knows to start ticking (part 3 covers that dance). Slides carry a `data-label` attribute ("R2 Q01", "Intermission · Round 01"), so consumers can pattern-match on *what kind* of slide became active without knowing anything about deck order.

> One event with a rich `detail` beats ten narrow callbacks. Every subscriber decides for itself what "slide changed" means.

## BroadcastChannel: the pub/sub server built into the browser

Next in the series: the two-window architecture, and how 26 lines of `BroadcastChannel` glue replaced what would otherwise be a websocket server.
