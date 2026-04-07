---
layout: post
title: "Reflecting on Claude Code creating Boxd Card"
date: 2026-04-07
category: software
image: "/seo/2026-04-07.png"
tags:
- claude-code
- chrome-extension
- ai
---

## Introduction

[Boxd Card](https://boxd-card.michaellamb.dev) is a tool I built with [Claude Code](https://claude.ai/code) that generates shareable PNG image cards from Letterboxd profiles. It started as a Chrome extension and grew into a dual-target project: the same codebase produces both a Chrome MV3 extension and a standalone web app at [boxd-card.michaellamb.dev/app/](https://boxd-card.michaellamb.dev/app/).

This post is a reflection on what Claude Code built and the technical decisions it made along the way — particularly around managing two build targets from one codebase, the versioning and release pipeline, and the automation that keeps it all working smoothly.

## What Boxd Card Does

Boxd Card scrapes your Letterboxd profile and renders the data onto an HTML5 Canvas, producing a downloadable PNG. There are six card types:

- **Last Four Watched** — the 4 most recent films on your profile
- **Favorites** — your pinned favorite films
- **Recent Diary** — diary entries (4, 10, or 20)
- **Lists** — any public list (4, 10, or 20 films)
- **Reviews** — 1–4 reviews with commentary and backdrop art
- **Stats** — summaries, genre breakdowns, weekly charts, and milestones (requires Letterboxd Pro or Patron membership; only available in the extension)

Each card type supports six layout formats: Landscape (1200px wide, ideal for Twitter/Discord), Square (1080×1080), 4:5 Portrait (1080×1350), 3:4 Portrait (1080×1440), Story (1080×1920), and Banner (1500×750). The entire rendering pipeline is pure Canvas 2D API — no image generation libraries.

## Two Build Targets, One Codebase

The most interesting architectural decision Claude Code made was how it split the project into two build targets without duplicating code.

### The Extension Build

The Chrome extension uses a minimal Vite config with `@crxjs/vite-plugin`:

```typescript
// vite.config.ts
export default defineConfig({
  plugins: [
    react(),
    crx({ manifest }),
  ],
})
```

This produces a `dist/` directory that can be loaded directly into Chrome via "Load unpacked." The extension has three runtime components: a **popup UI** (React) where you configure and generate cards, a **content script** that scrapes film data from the live Letterboxd DOM, and a **background service worker** that fetches poster images cross-origin.

### The Web App Build

The web app uses a separate Vite config that treats `src/web/` as its root:

```typescript
// vite.web.config.ts
export default defineConfig({
  plugins: [react()],
  root: resolve(__dirname, 'src/web'),
  envDir: __dirname,
  base: '/app/',
  build: {
    outDir: resolve(__dirname, 'docs/app'),
    emptyOutDir: true,
  },
})
```

The web app builds to `docs/app/`, which GitHub Pages serves at `boxd-card.michaellamb.dev/app/`. The `base: '/app/'` setting ensures all asset URLs resolve correctly under that path.

### Shared Code

Both targets share the core logic — the canvas renderer (`src/canvas/renderCard.ts`), type definitions (`src/types.ts`), alt text generation (`src/altText.ts`), and settings persistence (`src/storage/settings.ts`). The settings module is a good example of how the sharing works in practice:

```typescript
function hasChromeStorage(): boolean {
  return typeof chrome !== 'undefined' && !!chrome?.storage?.sync
}

export async function loadSettings(): Promise<UserSettings> {
  if (hasChromeStorage()) {
    const result = await chrome.storage.sync.get(STORAGE_KEY)
    return { ...DEFAULT_SETTINGS, ...(result[STORAGE_KEY] ?? {}) }
  }
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    if (raw) return { ...DEFAULT_SETTINGS, ...JSON.parse(raw) }
  } catch { /* malformed JSON — fall through to defaults */ }
  return { ...DEFAULT_SETTINGS }
}
```

At runtime, it detects whether `chrome.storage.sync` is available. In the extension, settings sync across Chrome profiles. In the web app, they persist to `localStorage`. Same interface, different backing store.

### The Scraping Difference

The biggest divergence between the two targets is how they get data from Letterboxd. The extension's content script runs directly on `letterboxd.com` pages and reads the live DOM. The web app can't do that — it takes a URL as input, fetches the HTML through a Cloudflare Worker CORS proxy (`boxd-card.michaellamb.workers.dev`), and parses it with `DOMParser`. The scraping selectors are mirrored between `src/content/index.ts` and `src/web/webScraper.ts`, but the plumbing underneath is completely different.

## The Release Pipeline

Claude Code set up a two-workflow GitHub Actions pipeline for releasing the Chrome extension.

### PR Checks

When a pull request targets the `release` branch, `pr-checks.yml` runs two jobs **in parallel**:

1. **Version Check** — reads the version from `package.json` and verifies no git tag `v{VERSION}` already exists. This catches the mistake of forgetting to bump the version before opening a release PR.
2. **Test & Build** — runs the full test suite (`npm run test:run`) and builds the extension to confirm it compiles cleanly.

Running these in parallel means you get fast feedback on both fronts without one blocking the other.

### Release

When a PR merges into the `release` branch, `release.yml` takes over:

1. Install dependencies and run tests (one more safety gate)
2. Read the version from `package.json`
3. Build the extension with `npm run build`
4. Zip the `dist/` directory as `boxd-card-{version}.zip`
5. Create and push a git tag (`v{version}`)
6. Create a GitHub Release with auto-generated release notes and the zip as a downloadable artifact

The workflow includes a safety guard: if the commit message starts with `"chore: release"`, it skips execution entirely to prevent re-triggering on its own tag push.

Version management is deliberately manual — you bump the version in both `package.json` and `manifest.json` (they must match), then open the PR. The CI validates and automates everything after that.

## Automating the Web App Build

The web app deployment uses a different strategy. Since GitHub Pages serves directly from the `docs/` directory, the built web app needs to be committed to the repo. Claude Code wrote a pre-commit hook to automate this:

```bash
#!/bin/bash
WEB_SOURCES=$(git diff --cached --name-only | \
  grep -E '^(src/web/|vite\.web\.config\.ts|\.env\.production)')

if [ -z "$WEB_SOURCES" ]; then
  exit 0
fi

echo "▶ Web source changed — rebuilding docs/app/..."
cd "$(git rev-parse --show-toplevel)"

if ! npm run build:web; then
  echo "✗ build:web failed — commit aborted." >&2
  exit 1
fi

git add docs/app/
echo "✓ docs/app/ rebuilt and staged."
```

When you stage changes to `src/web/`, `vite.web.config.ts`, or `.env.production`, the hook automatically rebuilds the web app and stages the output into the same commit. The source change and its build artifact always land together — no drift between what's in `src/web/` and what's deployed.

If the build fails, the commit is aborted. You fix the issue, re-stage, and try again. Simple and reliable.

## Working with Claude Code

What stands out to me about this project is how much of the architecture emerged from conversation rather than upfront design. I didn't sit down and plan a dual-target build system — it grew from asking Claude Code to add a web app alongside the existing extension. Claude Code chose the separate Vite config approach, wrote the CORS proxy worker, set up the settings abstraction that bridges `chrome.storage.sync` and `localStorage`, and created the pre-commit hook to keep the build output in sync.

The release pipeline was similar. I asked for automated releases and Claude Code produced the two-workflow system with parallel PR checks, version validation, and the safety guard against re-triggering. These are the kinds of infrastructure details that are easy to get wrong or skip entirely on a side project — CI that actually catches mistakes before they ship.

The test suite (Vitest with jsdom) covers the canvas renderer, both scraping implementations, the Cloudflare Worker proxy, alt text generation, and the background service worker. Claude Code added tests alongside features rather than as an afterthought, which meant the release pipeline had something meaningful to gate on from the start.

Building Boxd Card with Claude Code felt less like directing an assistant and more like collaborating with a developer who happens to have strong opinions about build tooling and CI. The project is at v0.5.0 now, and the infrastructure it built has held up well as the feature set has grown from four card types to six, from one layout to six, and from extension-only to extension-plus-web-app.

## Conclusion

A project of this size would have taken me months of attention and testing and research to build. I've never built a Chrome extension before, and I have a better idea of what it takes to do that now. It feels like I could reference this project as a template for future extensions, and in that way I have added more to my library of architectures. 

![Boxd Card: michaellamb's Favorites — Midsommar (2019), Tenet (2020), Wake Up Dead Man (2025), Sinners (2025)](/img/2026-04-07-boxd-card.png)
