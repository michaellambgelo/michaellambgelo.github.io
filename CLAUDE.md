# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
bundle exec jekyll serve          # local dev server at localhost:4000
bundle exec jekyll serve --drafts # include draft posts
ruby scripts/verify_seo_images.rb # verify all posts have SEO images (also runs on pre-push)
```

Markdownlint runs as a pre-commit hook on all posts. Configuration is in `.markdownlint.json`.

## Architecture

This is a Jekyll-based GitHub Pages blog (`blog.michaellamb.dev`). It uses a custom theme with Bootstrap, Font Awesome, jQuery, and `jekyll-seo-tag` for Open Graph / Twitter Card meta tags.

**Key directories:**

- `_posts/` — blog posts, named `YYYY-MM-DD-title.md`
- `_layouts/` — `post`, `page`, `filter`, `newsletter`
- `_includes/` — reusable partials (Giscus comments, etc.)
- `_templates/` — authoring guides (not built by Jekyll, listed in `_config.yml` exclude)
- `seo/` — per-post SEO images, named `YYYY-MM-DD.png` (plus `seo/default.png`)
- `img/` — general images referenced in post content

## Post Authoring

Every post requires:

1. A front matter `image` field pointing to a file in `seo/` (e.g. `image: "/seo/YYYY-MM-DD.png"`)
2. Exactly one `category` (see `_templates/taxonomy.md` for the canonical list)
3. 2–5 `tags` (lowercase, hyphenated)

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

The `/new-blog-post` skill scaffolds this automatically. Use heading hierarchy H2→H3→H4 (H1 is reserved for the post title rendered by the layout). Code blocks must specify a language (`MD040` is enforced).

## Git Hooks

- **pre-commit**: runs markdownlint on staged markdown files, then auto-generates any missing SEO images for staged posts and auto-stages them
- **pre-push**: runs `ruby scripts/verify_seo_images.rb` — will block push if any post is missing an SEO image

Reinstall hooks after modifying them: `sh scripts/install-hooks.sh`

## SEO Image Auto-Generation

The pre-commit hook calls `scripts/generate_seo_image.rb` for each staged `_posts/*.md` and auto-stages the generated `seo/YYYY-MM-DD.png` into the same commit. Requires ImageMagick:

```bash
brew install imagemagick
```

If ImageMagick is absent the hook warns but does not block the commit; the pre-push hook will still catch missing images.

**Manual generation / force-regeneration:**

```bash
ruby scripts/generate_seo_image.rb _posts/YYYY-MM-DD-title.md
# Force-regenerate (delete existing first):
rm seo/YYYY-MM-DD.png && ruby scripts/generate_seo_image.rb _posts/YYYY-MM-DD-title.md
```
