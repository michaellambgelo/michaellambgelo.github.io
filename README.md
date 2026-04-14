# michaellambgelo.github.io

Tech & life blog by Michael Lamb. Live at [blog.michaellamb.dev](https://blog.michaellamb.dev).

## About

Michael Lamb is a software engineer in Jackson, Mississippi. He organizes meetups with Jackson Film Club, Jackson Devs, and C Spire Gaming. Reach out at [michael@michaellamb.dev](mailto:michael@michaellamb.dev).

## Stack

- **Jekyll 3** (GitHub Pages) with `jekyll-seo-tag`, `jekyll-feed`, `jekyll-redirect-from`
- **Pure CSS** design system with CSS custom properties and `prefers-color-scheme` support — no Bootstrap, no jQuery, no Font Awesome
- **Inter** self-hosted (Light/Regular/SemiBold/Bold) as an SF Pro substitute
- **Giscus** for post comments (follows system color mode)

## Layouts

- `_layouts/post.html` — newsroom-style: full-bleed hero band + 680px reading column + tag footer + Giscus
- `_layouts/page.html` — minimal shell for static pages (About, Archive, Categories, Tags)
- `_layouts/filter.html` / `_layouts/newsletter.html` — specialized shells

## Documentation

- [Post Template](_templates/post.md) — template for creating new blog posts
- [Taxonomy](_templates/taxonomy.md) — canonical category list and tag conventions

## Authoring a post

Every post needs:

1. Front-matter `image:` pointing to a file in `seo/` (e.g. `image: "/seo/YYYY-MM-DD.png"`)
2. Exactly one `category` (from [taxonomy.md](_templates/taxonomy.md))
3. 2–5 lowercase, hyphenated `tags`

The `/new-blog-post` Claude Code skill scaffolds this automatically. Use H2→H4 heading hierarchy (H1 is the post title, rendered by the layout).

## Local development

```bash
bundle exec jekyll serve           # localhost:4000
bundle exec jekyll serve --drafts  # include drafts
```

## SEO images

Each post needs `seo/YYYY-MM-DD.png`. The pre-commit hook auto-generates it via `scripts/generate_seo_image.rb` (requires ImageMagick: `brew install imagemagick`). Verify all posts:

```bash
ruby scripts/verify_seo_images.rb
```

## Git hooks

Install once:

```bash
sh scripts/install-hooks.sh
```

- **pre-commit**: markdownlint on staged posts, auto-generates missing SEO images, auto-stages them
- **pre-push**: blocks push if any post is missing its SEO image

Emergency bypass: `--no-verify` on `git commit` or `git push`.

## License

See [SOURCE_CODE_LICENSE.txt](SOURCE_CODE_LICENSE.txt).
