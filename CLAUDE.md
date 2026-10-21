# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
bundle exec jekyll serve          # local dev server at localhost:4000
bundle exec jekyll serve --drafts # include draft posts
ruby scripts/verify_seo_images.rb # verify all posts have SEO images (also runs on pre-push)
```

Markdownlint runs as a pre-commit hook on all staged posts. Configuration is in `.markdownlint.json`.

## Architecture

Jekyll 3 GitHub Pages blog at `blog.michaellamb.dev`. The design is Apple-inspired: pure CSS with custom properties, `prefers-color-scheme` inversion, self-hosted Inter as an SF Pro substitute, pill CTAs, translucent dark glass nav. **No Bootstrap, no jQuery, no Font Awesome.** `jekyll-seo-tag` handles Open Graph / Twitter Card meta.

**Key directories:**

- `_posts/` — blog posts, named `YYYY-MM-DD-title.md`
- `_layouts/` — `post`, `page`, `filter`, `newsletter`
- `_includes/` — only 6 files: `head/common/common.html`, `body/sections/{navbar,footer,newsletter,alerts_and_notices/site}.html`, `content/brief-bio.html`, `giscus.html`
- `_templates/` — authoring guides (excluded from build via `_config.yml`)
- `css/` — `theme.css` (tokens + base type), `gh-pages-blog.css` (components), `syntax.css` (code blocks), `newsletter.css`
- `font/inter/` — self-hosted Inter woff2 (Light/Regular/SemiBold/Bold), plus Regular/SemiBold `.ttf` used **only** by the SEO card generator (ImageMagick cannot read woff2). The site itself never serves the TTFs.
- `seo/` — per-post SEO images `YYYY-MM-DD-<slug>.png` + `default-card.png`, the site-wide Open Graph fallback (`image:` in `_config.yml`). It was `default.png` until 2026-10. Scrapers cache previews by image URL, so regenerating a card in place does not refresh old previews. If the default card ever changes, give it a **new filename** and update every reference.
- `img/` — general images referenced in post content
- `js/grafana-faro.js` — telemetry; only JS loaded site-wide

**Navigation** (`_includes/body/sections/navbar.html`): two bars. The primary bar has the same links, in the same order, as the nav on `michaellamb.dev` (repo `michaellamb-dev`): Blog, Letterboxd, Newsletter, Now, About, Book. It also uses the same 720px hamburger breakpoint and the same `aria-current` style. Change one site and you must change the other; nothing checks that they match. The second bar (`.sk-subnav`) holds the blog-only pages: Archive, Categories, Tags, every titled page except About, Now and Newsletter, and Shop. Its links are right-aligned under the primary links. It scrolls away with the page, and on phones it stays a row you can swipe sideways, aligned left.

**Entry pages:** `index.html` (cinematic hero stack), `archive.html`, `categories.html`, `tags.html`, `filter.html` (query-string filter), `about.html`, `newsletter.html` (redirect shim).

**Site plumbing:** `404.html` (GitHub Pages serves it for any miss; `exclude: true` keeps it out of the subnav, `sitemap: false` keeps it out of the sitemap). `robots.txt` is plain text with no front matter and points at `/sitemap.xml`, which `jekyll-sitemap` generates (redirect shims such as `newsletter.html` are skipped automatically). `apple-touch-icon.png` is the 180x180 monogram on `#f5f5f7`, generated from `img/favicon.png`.

## Feeds

Two feeds are published, and **both must keep existing**. GitHub Pages cannot send a 301, and a meta-refresh redirect (`jekyll-redirect-from`) does nothing for a feed reader, so deleting either URL breaks its subscribers outright.

- **`/feed.xml` (Atom, `jekyll-feed`) is the canonical feed.** `{% feed_meta %}` advertises it first in `<head>`. It is also reachable extensionless at `/feed`, and that is the URL the `discord-embed-builder` RSS subscription polls (`https://blog.michaellamb.dev/feed`; its test fixture is `feed.blog-michaellamb-dev.atom.xml`). That poller dedupes on the Atom `<id>` (`proxy/src/services/rss-fetcher.ts`), so changing a post's `<id>`, which comes from its date and slug, re-posts it to Discord.
- **`/rss.xml` (RSS 2.0, `rss.xml` + `_layouts/rss.xml`)** is the older feed, kept for existing subscribers and advertised second. It carries the same items as the Atom feed, the newest `feed.posts_limit` (default 10). Every text field is `xml_escape`d; a raw `&` in a title made the whole feed invalid XML until 2026-10. Do not change `<guid>`: readers would show every item as new again.

## Design tokens

Defined in `css/theme.css` under `:root` with a `@media (prefers-color-scheme: dark)` override that inverts the "light" alternation slot to `#1d1d1f`. Access them as CSS variables (`var(--sk-accent)`, `var(--sk-text-body)`, etc.) — do not hardcode palette colors in new components.

## Post authoring

Every post requires:

1. Front matter `image:` pointing to a file in `seo/` (e.g. `image: "/seo/YYYY-MM-DD-<slug>.png"`)
2. Exactly one `category` (see `_templates/taxonomy.md` for the canonical list)
3. 2–5 `tags` (lowercase, hyphenated)

Optional front matter:

- `hero_tone: light` — flips the post hero band to `#f5f5f7` instead of black. Default: `dark`.
- `subtitle:` — shown under the title in the hero band.

Front matter template:

```yaml
---
layout: post
title: "Your Post Title Here"
date: YYYY-MM-DD
category: category-name
image: "/seo/YYYY-MM-DD-<slug>.png"
tags:
- tag1
- tag2
published: true
---
```

The `/new-blog-post` skill scaffolds this automatically. Use heading hierarchy H2→H4 (H1 is rendered by the layout). Code blocks must specify a language (`MD040` is enforced).

## Git hooks

- **pre-commit**: first fails the commit if any staged file under `img/` is over 1 MiB (it measures the staged blob, not the working-tree file), printing each file, its size and a one-line `magick` command to shrink it. Set `ALLOW_LARGE_IMAGES=1` to commit a deliberate exception. It then runs markdownlint on staged markdown files, then auto-generates any missing SEO images for staged posts and auto-stages them
- **pre-push**: runs `ruby scripts/verify_seo_images.rb` — will block push if any post is missing an SEO image

Reinstall hooks after modifying them: `sh scripts/install-hooks.sh`

## SEO image auto-generation

The pre-commit hook calls `scripts/generate_seo_image.rb` for each staged `_posts/*.md` and auto-stages the generated `seo/YYYY-MM-DD-<slug>.png` into the same commit. Requires ImageMagick:

```bash
brew install imagemagick
```

If ImageMagick is absent the hook warns but does not block the commit; the pre-push hook still catches missing images.

**Card design.** The card is a 1200x630 rendering of the post hero band, built from the same tokens as `css/theme.css` — `#000000` (or `#f5f5f7` when `hero_tone: light`), the category as an accent-colored eyebrow, the title in Inter SemiBold with the hero's negative tracking, and a `--sk-rule` hairline above a tertiary footer. Change a token in `theme.css` and you should change it in `TONES` in the script.

The **ML monogram** (`img/favicon.png`) fills the right of the card. Its letterforms are a rich black (`#231F20`), so on the dark tone they are recolored to `#f5f5f7` before compositing — otherwise only the cyan/red chromatic fringing survives against the black ground and the mark reads as a smudge. The text column is capped at 640px to clear it; the 79-character title cap wraps to at most five lines and still fits.

Type is **Inter**, loaded from `font/inter/Inter-{SemiBold,Regular}.ttf`. ImageMagick here has no fontconfig, so `-weight` is a silent no-op on variable fonts and `.ttc` collections — the weight must come from the font *file*. That is why the TTFs exist.

**Manual generation / force-regeneration:**

```bash
ruby scripts/generate_seo_image.rb _posts/YYYY-MM-DD-title.md          # skips if card exists
ruby scripts/generate_seo_image.rb --force _posts/YYYY-MM-DD-title.md  # regenerate one
ruby scripts/generate_seo_image.rb --force --all                       # regenerate every card
```

Cards bake in the title, category, and date, so a post that is renamed or re-dated **must** be regenerated with `--force` — `verify_seo_images.rb` only checks that a file exists, not that it is current.
