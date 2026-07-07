---
layout: post
title: "Anatomy of a trivia deck, part 4: localStorage is the database"
date: 2026-07-07 09:30:00 -0500
category: development
subtitle: "Part 4 of 5 — persistence patterns, a storage-quota war story, and the one-file deck bundle."
image: "/seo/2026-07-07-anatomy-of-a-trivia-deck-part-4-the-data-layer.png"
tags:
- javascript
- localstorage
- architecture
- trivia
---

## Four keys, one pattern

With no backend ([part 1]({% post_url 2026-07-07-anatomy-of-a-trivia-deck-part-1-no-backend %})), all persistence in the pub-trivia scaffold is localStorage. Four keys — `rounds`, `tiebreakers`, `meta`, `pictures` — and every one of them follows the same shape:

```javascript
export const DEFAULT_ROUNDS = [ /* real, hostable content */ ];

export function loadRounds() { /* parse, validate, fall back to defaults */ }
export function saveRounds(rounds) { /* stringify to the key */ }
export function resetRounds() { /* remove the key */ }
```

Three properties of this pattern do a lot of quiet work.

**Defaults are real content.** A fresh browser doesn't get an empty deck — it gets forty actual general-knowledge questions and three tiebreakers. The empty state *is* a working event, which means the scaffold is always demo-able and every fresh profile is a usable fallback machine.

**Loads are migrations.** `loadMeta` merges whatever it finds against the current defaults, field by field, validating enums against their allowed values and dropping garbage:

```javascript
function withDefaults(parsed) {
  return {
    title: { ...DEFAULT_META.title, ...(parsed?.title || {}) },
    // ...explicit, validated picks for the risky sections...
    pictureRound: {
      fit: PICTURE_FITS.includes(parsed?.pictureRound?.fit)
        ? parsed.pictureRound.fit
        : DEFAULT_META.pictureRound.fit,
      // ...
    },
  };
}
```

localStorage written by last month's code is this month's input. Treating every load as a lenient import means adding a field never breaks an old save, and renaming one degrades to a default instead of collapsing a layout.

**Resets are honest.** Reset deletes the key rather than writing defaults, so future default changes flow through automatically.

## The picture round vs. the quota

The picture round stores ten pasted images as data URLs in localStorage, in a single ten-slot buffer that feeds every surface: the on-screen recap slide, the editor preview, and the canvas-rendered paper handout teams write on all read the same slots and share the same cell geometry, so a crop set in the editor lands identically on screen and on paper. It's also where the design met reality. localStorage gives an origin roughly 5MB. A single photo off a modern phone can be 8MB — and base64 encoding adds a third on top. The first version stored pastes byte-for-byte, and the failure was ugly in a specific, instructive way: the write threw `QuotaExceededError` *after* React state had updated, so the image sat there looking saved in the editor — and silently vanished on the next reload. The picture round is exactly the wrong place for "vanished on the next reload," because it's prepared hours ahead of the event: the sheet teams write on has to be physically printed, which means the images are locked in well before game night. Paste ten images, print the handouts, close the laptop — and discover at the venue that the recap slide no longer matches the paper in people's hands.

Three fixes, in order of importance:

**1. Recompress on ingest.** Slides render picture cells at ~350px wide; storing 4000-pixel originals was pure waste. Every paste and drop now goes through a canvas resize — long edge capped at 1600px for cropping headroom, re-encoded as JPEG:

```javascript
const bitmap = await createImageBitmap(blob);
const scale = Math.min(1, maxEdge / Math.max(bitmap.width, bitmap.height));
// ...draw to canvas at scaled size...
return canvas.toDataURL('image/jpeg', 0.85);
```

In testing, a 10.2MB PNG became roughly 0.8MB stored; a realistic set of ten phone photos lands near 3MB total. The quota problem didn't get handled — it got deleted.

**2. Broadcast before persisting, and let saves fail soft.** The save now returns a boolean instead of throwing, and the commit sequence sends the other window its copy *first*, so the preview stays truthful for the session either way. More importantly, the failure now announces itself at paste time — a status warning that the buffer won't survive a reload — while I'm still at the desk preparing the round and can do something about it, instead of days later at load-in. This is more a UX design choice than anything, with the trivia administrator/author in mind.

**3. Commit crops on release.** Drag-to-crop was persisting on every pointer-move — re-stringifying all ten data URLs at mouse-event rate. The drag now previews through local component state and commits exactly once, on pointer-up.

> Storage limits aren't edge cases to catch — they're budgets to design under. The fix for "the write throws" was making the data an order of magnitude smaller, not a better try/catch. Though try/catch still exists, it's the seatbelt, not the brakes.

## The deck bundle

localStorage is per-browser, per-origin — which is wrong for the actual workflow, where I write questions on one machine during the week and present from another at the taproom. The bridge is a one-file export: **Export Deck** serializes rounds, tiebreakers, all the meta, and the picture round (data URLs and their crop positions included) into a single versioned JSON file.

```json
{
  "type": "pub-trivia-scaffold/questions",
  "version": 2,
  "rounds": ["..."],
  "tiebreakers": ["..."],
  "pictures": ["..."],
  "meta": { "...": "..." }
}
```

The details that took iteration to get right:

- **Import is staged asymmetrically.** Questions and meta land in the editor's draft (review, then push to display); pictures commit immediately, because the picture panel has no draft concept. Consistency with each subsystem's own editing model beat uniformity.
- **Absent beats empty.** An empty picture buffer exports *no* `pictures` key at all — not ten null cells — and importing a bundle without pictures leaves the target machine's pictures alone. When at least one image exists, all ten slots ship, because the nulls are positional: they keep image three in cell three.
- **Versioned from day one.** Version-1 files (questions only) still import. The same lenient-load philosophy as localStorage: old artifacts are inputs, not errors.

Spreadsheet CSVs still import — there's a writer-template flow so friends can contribute questions without touching the app — but the bundle is the only export. One file is the whole event.

Last in the series: theming as an architectural dimension — the palette contract, and how this one repo becomes a Star Wars deck without touching the engine.
