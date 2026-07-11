---
layout: post
title: "Anatomy of a trivia deck, part 5: theming as architecture"
date: 2026-07-11 09:40:00 -0500
category: development
subtitle: "Part 5 of 5 — the palette contract, anchor strings, and one repo becoming many decks."
image: "/seo/2026-07-11-anatomy-of-a-trivia-deck-part-5-theming-as-architecture.png"
tags:
- design-systems
- react
- claude-code
- trivia
---

## The scaffold's second job

Through this series the pub-trivia scaffold has been one app: [no backend]({% post_url 2026-07-07-anatomy-of-a-trivia-deck-part-1-no-backend %}), a [web-component stage]({% post_url 2026-07-07-anatomy-of-a-trivia-deck-part-2-deck-stage %}), [two windows over a channel]({% post_url 2026-07-09-anatomy-of-a-trivia-deck-part-3-two-windows-one-channel %}), [localStorage underneath]({% post_url 2026-07-10-anatomy-of-a-trivia-deck-part-4-the-data-layer %}). This last post is about its second job: being the template that themed decks are cloned from. A Star Wars night, a LOTR night, a Pokémon night — each is a full sibling repo produced by a Claude Code skill that copies the scaffold and re-skins it end to end.

That only works if "what is theme" versus "what is engine" is an explicit, written-down boundary. Making that boundary real changed decisions all the way down to how the CSS is written.

## The palette contract: ink and paper

Every color in the deck comes from a seven-key `PALETTE` object at the top of `slides.jsx`. The naming convention is the interesting part:

```javascript
const PALETTE = {
  ink: "#1A2A4A",       // THE SLIDE BACKGROUND — whatever color that is
  paper: "#F2E8CF",     // THE PRIMARY TEXT COLOR — whatever color that is
  inkDeep: "#1A1410",   // outlines + hard offset shadows
  rust: "#C8201E",      // structural accent (rule bars, feature slides)
  // ...
};
```

`ink` is not "the dark color." It is *the background*, whatever that happens to be. The scaffold has shipped both light-background and dark-background designs under the same keys — themed forks invert the **values** and never touch the **keys**, so every downstream style (`background: PALETTE.ink, color: PALETTE.paper`) survives any palette. Semantic-by-role naming instead of semantic-by-appearance is an old design-token idea; the discipline is refusing to break it even in a hundred small inline styles.

Two supporting conventions keep the contract airtight:

- **No CSS files.** Every visual lives as inline style objects in `slides.jsx`. For a themable deck this beats stylesheets: there is exactly one place a fork edits, the palette is enforced by reference rather than by grep, and nothing cascades in from a file someone forgot about.
- **Translucency is alpha-hex on tokens.** A dimmed label is `${PALETTE.paper}99`, a hairline border is `${PALETTE.paper}29` — never a literal `rgba(...)`. Swap the palette and every frame, hairline, and caption gradient tracks it automatically.

## Anchor strings: theme content as an interface

Palette is the easy half. The harder half is copy — round titles, house rules, the title-slide tagline, the browser tab title. The scaffold's answer is a table in its `CLAUDE.md` listing every **anchor string**: the exact, verbatim text the re-skinning skill finds and replaces, file by file, alongside the things it must never touch.

That turns theme content into an interface with the same obligations as an API:

- Anchors must stay **verbatim** — paraphrasing one during a refactor silently breaks the skill until the docs are updated to match. Changing one is a breaking change and gets treated like one.
- Everything not an anchor is engine, and the skill's instructions say so explicitly: don't touch the recap-splitting math, the timer, the persistence helpers, the stage.
- When a hardcoded string turned out to be something hosts change per event — the title-slide tagline, most recently — the fix wasn't a better anchor. It was **promoting it to data**, into the runtime-editable meta from part 4, where it stopped being the skill's problem at all.

The clone itself renames the deck's identity in the same pass: `BroadcastChannel` name, localStorage key prefixes, the export-file `type` string. Two decks can then run side-by-side on the same machine without their control windows cross-talking or their saves colliding — which sounds theoretical until the night you're testing next week's themed deck while this week's is still loaded.

> A theme is not a coat of paint; it's a second consumer of your codebase. The moment something has two consumers, the boundary between them wants to be written down.

## Visual identity is more than the palette

One lesson from actually producing themed decks: the palette swap alone reads as a re-skin, not a theme. So the scaffold documents a wider set of swap points as first-class theme dimensions — the font trio (a hero slab, a condensed display face, a body face, loaded in one place and referenced through three constants), the divider ornament between title-slide sections (a diamond by default; forks have made it a saber, a snowflake), the venue logo (a PNG that hides itself cleanly if a fork deletes it), and a per-round accent rotation hook that maps round numbers to accent colors.

The current look — a pulp-poster design with hard offset shadows and red feature slides — came out of a [Claude Design](https://claude.ai/design) project and was ported into the scaffold's inline-style system, replacing the previous design wholesale. That swap touched one file's styles, the fonts link, and zero engine code, which is about the strongest evidence I have that the boundary sits in the right place.

## What the series adds up to

Five posts, one small app, and the same idea underneath each piece: pick the boundary first, then let it make the decisions. Necessity breeds innovation.

Claude Code was used in the creation of both this article series and the [`pub-trivia-scaffold`](https://gitlab.com/michaellambgelo/pub-trivia-scaffold) app itself. I have personally reviewed all of the content of this blog series.
