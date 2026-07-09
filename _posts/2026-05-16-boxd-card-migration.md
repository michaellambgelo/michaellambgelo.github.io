---
layout: post
title: Migrating boxd-card
image: "/seo/2026-05-16-boxd-card-migration.png"
category: software
tags:
- claude-code
- movies
- boxd-card
- chrome-extension
- letterboxd
---

## Overview

Below is the plan I am currently reviewing to migrate boxd-card.michaellamb.dev to boxd-card.com.

I am planning for the site to go live in **June**. 

```md
 Ready to code?

 Here is Claude's plan:
╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌
 Migrate boxd-card to boxd-card.com

 Context

 boxd-card is mature enough (v0.7.0 live on CWS, ~25 files reference the beta domain). Time to graduate from boxd-card.michaellamb.dev to the production domain boxd-card.com, and
 from the *.workers.dev preview worker URL to api.boxd-card.com.

 The migration also reshapes the marketing surface: boxd-card.com becomes a Claude Design–built landing with a single CTA; today's hero page (docs/index.html) moves to /about and
 gets a content refresh. The Letterboxd-scraping web app moves from boxd-card.michaellamb.dev/app/ to boxd-card.com/app/.

 Migration begins in June 2026, gated on prerequisites (Claude Design output ready, DNS verified, v0.7.1 shipped). No fixed start date.

 Decisions locked in

 ┌───────────────────┬──────────────────────────────────────────────────────────────────────────────┐
 │     Question      │                                   Decision                                   │
 ├───────────────────┼──────────────────────────────────────────────────────────────────────────────┤
 │ Site structure    │ Landing at /, hero at /about, web app at /app (single Cloudflare Pages site) │
 ├───────────────────┼──────────────────────────────────────────────────────────────────────────────┤
 │ Worker URL switch │ Ship as v0.7.1 patch before v0.8.0 (decouples migration from feature work)   │
 ├───────────────────┼──────────────────────────────────────────────────────────────────────────────┤
 │ Old domain        │ 301 redirect from boxd-card.michaellamb.dev → boxd-card.com                  │
 ├───────────────────┼──────────────────────────────────────────────────────────────────────────────┤
 │ Apex hosting      │ Cloudflare Pages, same repo (DNS already on CF)                              │
 ├───────────────────┼──────────────────────────────────────────────────────────────────────────────┤
 │ Landing source    │ Pasted into docs/landing/; served at apex via Pages rewrite                  │
 └───────────────────┴──────────────────────────────────────────────────────────────────────────────┘

 Phases

 Phase 0 — Prerequisites (late May, parallel)

 These can happen any time before Phase 1; nothing blocks each other.

 - Generate landing. Prompt Claude Design for a single-CTA, animated landing for boxd-card.com. CTA links to /about. Receive output, drop into docs/landing/ (don't commit yet — just
 have it ready).
 - DNS audit. Confirm boxd-card.com zone on Cloudflare has no conflicting records. Note nameservers, ensure SSL is on Full (strict).
 - Hero copy refresh. Decide what content changes in the hero (docs/index.html → moving to /about). Out of scope to draft here; capture as a TODO list.

 Phase 1 — v0.7.1: Worker custom domain (api.boxd-card.com)

 Goal: Worker accessible at api.boxd-card.com. Ship a CWS patch that updates host_permissions and client URLs. No other behavior changes.

 Critical files:

 ┌───────────────────────────────────────┬───────────────────────────────────────────────────────────────────────────────────────────────────┐
 │                 File                  │                                              Change                                               │
 ├───────────────────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
 │ Cloudflare dashboard                  │ Add custom domain api.boxd-card.com to the existing boxd-card worker. Wait for cert provisioning. │
 ├───────────────────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
 │ worker/wrangler.toml                  │ Optional: declare the route here for IaC parity. Not strictly required if managed via dashboard.  │
 ├───────────────────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
 │ worker/index.ts:48                    │ Update User-Agent comment URL to https://boxd-card.com                                            │
 ├───────────────────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
 │ src/background/service-worker.ts:37   │ TMDB_WORKER_BASE = 'https://api.boxd-card.com'                                                    │
 ├───────────────────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
 │ src/background/service-worker.test.ts │ Update expected URLs (~lines 54, 97, 119)                                                         │
 ├───────────────────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
 │ src/web/tmdbClient.ts:17              │ Fallback default → https://api.boxd-card.com                                                      │
 ├───────────────────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
 │ src/web/webScraper.ts:32              │ Fallback default → https://api.boxd-card.com                                                      │
 ├───────────────────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
 │ .env.production:1                     │ VITE_PROXY_URL=https://api.boxd-card.com                                                          │
 ├───────────────────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
 │ manifest.json:18                      │ host_permissions → https://api.boxd-card.com/* (replacing workers.dev)                            │
 ├───────────────────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
 │ manifest.json:4 + package.json:3      │ Bump version 0.7.0 → 0.7.1                                                                        │
 ├───────────────────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────┤
 │ .claude/settings.local.json           │ Update 3 curl health-check URLs                                                                   │
 └───────────────────────────────────────┴───────────────────────────────────────────────────────────────────────────────────────────────────┘

 Critical step: Keep boxd-card.michaellamb.workers.dev resolving (CF lets both URLs hit the same worker). Old extension installs hit the legacy URL until they update; new releases
 hit api.boxd-card.com. Don't decommission the workers.dev URL until v0.7.1 adoption is near 100% (likely defer to v1.0).

 Release flow (per [[feedback_release_flow]]):
 1. Open chore/bump-version-0.7.1 off main, PR targets main.
 2. After merge, open main → release PR.
 3. Workflow auto-creates GH release as draft. Flip prerelease flag manually until CWS approves.

 Verification:
 - curl https://api.boxd-card.com/tmdb?slug=dune-2021 returns expected JSON (assuming TMDB_API_KEY already set as secret).
 - Load extension unpacked from dist/; generate a card with TMDB enrichment on → poster + director/runtime populate.
 - npm run test:run passes.

 Phase 2 — Apex site: boxd-card.com on Cloudflare Pages

 Goal: boxd-card.com/ serves the new landing; /about serves today's hero (relocated); /app continues to serve the web app build. No content from boxd-card.michaellamb.dev is yet
 redirected — both domains live in parallel until Phase 4.

 Steps:

 1. Cloudflare Pages project. Create a new Pages project bound to this repo's release branch. Build output directory: docs/. No build command (static — Vite builds for docs/app/
 already happen on npm run build:web, which gets committed).
 2. DNS. Add boxd-card.com and www.boxd-card.com records pointing to the Pages project (Cloudflare auto-wires this from the dashboard).
 3. Apex rewrite. Add docs/_redirects (Cloudflare Pages syntax):
 /          /landing/index.html   200
 /about     /about/index.html     200
 3. The 200 rewrite preserves the URL bar.
 4. Move hero. git mv docs/index.html docs/about/index.html. Update internal links inside that file. Apply the content refresh from Phase 0.
 5. Drop landing in. Commit docs/landing/ (Claude Design output). Verify locally with npx wrangler pages dev docs or by previewing the Pages branch deployment.
 6. OG/social meta. Update docs/landing/index.html and docs/about/index.html og:url, og:image, twitter:card to point at boxd-card.com.

 Phase 3 — Web app & extension link updates to boxd-card.com

 Goal: Every UI link in the extension popup and web app points at boxd-card.com instead of boxd-card.michaellamb.dev. Web app's Vite base does not change — it stays /app/.

 Critical files:

 ┌───────────────────────────────┬────────────────────────────────────────────────────────────────────────────────────┐
 │             File              │                                       Change                                       │
 ├───────────────────────────────┼────────────────────────────────────────────────────────────────────────────────────┤
 │ src/popup/Popup.tsx:423       │ href="https://boxd-card.com"                                                       │
 ├───────────────────────────────┼────────────────────────────────────────────────────────────────────────────────────┤
 │ src/web/App.tsx:411, 758, 760 │ All three hrefs → https://boxd-card.com (plus /privacy.html references → /privacy) │
 ├───────────────────────────────┼────────────────────────────────────────────────────────────────────────────────────┤
 │ vite.web.config.ts:14         │ Update example comment                                                             │
 ├───────────────────────────────┼────────────────────────────────────────────────────────────────────────────────────┤
 │ docs/CNAME                    │ Replace boxd-card.michaellamb.dev with boxd-card.com                               │
 └───────────────────────────────┴────────────────────────────────────────────────────────────────────────────────────┘

 This ships in v0.8.0 alongside the new feature (whatever it ends up being — see prior brainstorm).

 Phase 4 — Old domain redirect

 Goal: boxd-card.michaellamb.dev/* 301s to boxd-card.com/*.

 Since boxd-card.michaellamb.dev is GitHub Pages on this same repo and we've moved the CNAME away from it, a separate redirect mechanism is needed:

 Option A (recommended): tiny landing on michaellamb.dev that 301s.
 Use a one-page redirects repo or a Cloudflare Worker route boxd-card.michaellamb.dev/* → 301 boxd-card.com/$1. Since michaellamb.dev is already on Cloudflare (per ~/Workspace
 CLAUDE.md patterns), a Worker route is the cleanest fit.

 Option B: Keep GH Pages serving a minimal index.html with <meta http-equiv="refresh"> + JS redirect for crawlers/users. Less SEO-correct than 301 but zero infra.

 Pick during execution; both are reversible.

 Phase 5 — Docs, store listing, telemetry cleanup

 ┌───────────────────────────────────────┬─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 │                 File                  │                                                                 Change                                                                  │
 ├───────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
 │ README.md:14, 124, 127                │ All URLs → boxd-card.com                                                                                                                │
 ├───────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
 │ docs/store-listing.md:39, 54, 73, 115 │ Same                                                                                                                                    │
 ├───────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
 │ .github/ISSUE_TEMPLATE/bug_report.yml │ "Web app (boxd-card.com)"                                                                                                               │
 ├───────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
 │ Privacy policy                        │ Move file from docs/privacy.html (current path) to docs/privacy/index.html, update CWS listing URL. Confirm CWS still accepts updated   │
 │                                       │ privacy URL without re-review (usually yes — but it's a separate dashboard field)                                                       │
 ├───────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
 │ grafana-faro-proxy repo (sibling)     │ Update referer routing rule from boxd-card.michaellamb.dev → boxd-card.com so RUM keeps flowing. See                                    │
 │                                       │ ~/Workspace/grafana-faro-proxy/worker.js.                                                                                               │
 └───────────────────────────────────────┴─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

 Store-listing changes ship to CWS as a metadata update (no version bump needed; only the listing fields change).

 Risks & rollback

 - Worker custom domain cert delay. CF issues certs fast (<5min usually) but plan for an hour. Mitigation: keep workers.dev URL live; if cert delays Phase 1 release, ship v0.7.1
 still pointing at the workers.dev URL — postpone the URL switch to v0.7.2.
 - CWS rejecting host_permissions change. Rare, but if api.boxd-card.com is flagged, revert to workers.dev and resubmit. The host_permissions list is the one CWS reviewer-sensitive
 field in the manifest diff.
 - Faro proxy routing regression. If the grafana-faro-proxy route isn't updated in time, RUM stops for the new domain. Symptom: blank dashboards for boxd-card after Phase 2. Fix:
 deploy the proxy update before Phase 2 (so it's ready when the new domain serves users).
 - Search-engine churn. 301 from old → new preserves most ranking. Without 301 (Option B refresh), expect a multi-week dip.

 Verification (end-to-end)

 After Phase 5:
 - curl -I https://boxd-card.com/ → 200, valid CF Pages cert
 - curl -I https://boxd-card.com/about → 200, served from docs/about/
 - curl -I https://boxd-card.com/app/ → 200, web app loads, can generate a card
 - curl -I https://api.boxd-card.com/tmdb?slug=dune-2021 → 200 with TMDB JSON
 - curl -I https://boxd-card.michaellamb.dev/ → 301 to https://boxd-card.com/
 - Chrome extension popup → CTA links → boxd-card.com
 - Generate a card with TMDB on → enrichment works (i.e., extension still reaches the worker)
 - Faro dashboard shows new sessions tagged with the boxd-card.com origin
 - Search the codebase: git grep "michaellamb.dev" -- ':!CHANGELOG*' ':!docs/store-listing.md' returns only intentional historical references

 Out of scope (track separately)

 - v0.8.0 feature itself (see prior conversation brainstorm).
 - Decommissioning the *.workers.dev URL — defer until v0.7.1 adoption nears 100% (likely v1.0).
 - Migrating from CWS listing screenshots that show the old domain — schedule alongside the next listing refresh cycle.
 - Updating any external links (the GitHub README of this repo is in scope; third-party sites linking to old domain are covered by the 301 indefinitely).
╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 Claude has written up a plan and is ready to execute. Would you like to proceed?

 ❯ 1. Yes, auto-accept edits
   2. Yes, manually approve edits
   3. No, refine with Ultraplan on Claude Code on the web
   4. Tell Claude what to change
      shift+tab to approve with this feedback

 ctrl-g to edit in  VS Code  · ~/.claude/plans/hello-are-you-working-graceful-pascal.md
```
