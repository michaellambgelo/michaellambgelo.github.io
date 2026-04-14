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
- `font/inter/` — self-hosted Inter woff2 (Light/Regular/SemiBold/Bold)
- `seo/` — per-post SEO images `YYYY-MM-DD.png` + `default.png`
- `img/` — general images referenced in post content
- `js/grafana-faro.js` — telemetry; only JS loaded site-wide

**Entry pages:** `index.html` (cinematic hero stack), `archive.html`, `categories.html`, `tags.html`, `filter.html` (query-string filter), `about.html`, `newsletter.html` (redirect shim).

## Design tokens

Defined in `css/theme.css` under `:root` with a `@media (prefers-color-scheme: dark)` override that inverts the "light" alternation slot to `#1d1d1f`. Access them as CSS variables (`var(--sk-accent)`, `var(--sk-text-body)`, etc.) — do not hardcode palette colors in new components.

## Post authoring

Every post requires:

1. Front matter `image:` pointing to a file in `seo/` (e.g. `image: "/seo/YYYY-MM-DD.png"`)
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
image: "/seo/YYYY-MM-DD.png"
tags:
- tag1
- tag2
published: true
---
```

The `/new-blog-post` skill scaffolds this automatically. Use heading hierarchy H2→H4 (H1 is rendered by the layout). Code blocks must specify a language (`MD040` is enforced).

## Git hooks

- **pre-commit**: runs markdownlint on staged markdown files, then auto-generates any missing SEO images for staged posts and auto-stages them
- **pre-push**: runs `ruby scripts/verify_seo_images.rb` — will block push if any post is missing an SEO image

Reinstall hooks after modifying them: `sh scripts/install-hooks.sh`

## SEO image auto-generation

The pre-commit hook calls `scripts/generate_seo_image.rb` for each staged `_posts/*.md` and auto-stages the generated `seo/YYYY-MM-DD.png` into the same commit. Requires ImageMagick:

```bash
brew install imagemagick
```

If ImageMagick is absent the hook warns but does not block the commit; the pre-push hook still catches missing images.

**Manual generation / force-regeneration:**

```bash
ruby scripts/generate_seo_image.rb _posts/YYYY-MM-DD-title.md
# Force-regenerate (delete existing first):
rm seo/YYYY-MM-DD.png && ruby scripts/generate_seo_image.rb _posts/YYYY-MM-DD-title.md
```
