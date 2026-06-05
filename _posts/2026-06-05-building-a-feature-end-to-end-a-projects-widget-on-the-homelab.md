---
layout: post
title: "Building a feature end to end: a Projects widget on the homelab"
image: "/seo/2026-06-05-building-a-feature-end-to-end-a-projects-widget-on-the-homelab.png"
category: software
tags:
- kotlin
- ktor
- homelab
- software
---

## The smallest interesting feature

The Projects section of my [/about](/about.html) page used to be three lines of hand-written HTML. Every time I shipped something new I'd open `about.html`, copy a `<li>`, paste a status badge, and push the blog. It worked. It was also the kind of small, recurring chore that quietly tells you the boundary is in the wrong place: content was living in markup.

So I moved it. The list is now a **server-rendered widget** backed by a database, with a little admin form to maintain it — and the blog just fetches a fragment of HTML. Nothing about that is novel. What I want to write down is the *process*, because the process is the part that transfers to every other feature.

This is the kind of change that's easy to do badly: bolt on a table, hard-code some HTML, ship it. Doing it well took the same afternoon and left the codebase more consistent than it found it. Here's how.

## Start by reading, not writing

The service behind this is [`kotlin-tutorial`](https://kotlin-tutorial.michaellamb.dev) — a small Ktor app on node5 of my Raspberry Pi cluster whose whole reason for existing is to be a pedagogical, well-factored example. It already had three patterns I needed:

- **Widgets** — `widgets/` renders cached HTML fragments the blog embeds (this is how `/now` shows my recent films and commits).
- **Persistence** — `/notes` is CRUD over SQLite-on-disk via [Exposed](https://github.com/JetBrains/Exposed), the JetBrains SQL framework.
- **Admin** — `/admin` is a Cloudflare-Access-gated form that edits the "Recently updated" feed.

The Projects feature is *literally just those three things composed*. So the first hour was spent reading the existing code, not writing new code. The best way to make a change feel like it belongs is to copy the conventions already in the repo: the same `Route.xWidget(...)` extension functions, the same `newSuspendedTransaction(Dispatchers.IO)` wrapper, the same "store epoch millis, not a `timestamp()` column" trick that dodges a SQLite timezone bug I'd already been bitten by once.

> If your feature can be described as "the X pattern plus the Y pattern," your job is mostly plumbing — and plumbing should look like the plumbing next to it.

## Decide the data model before the code

A project is richer than a bookmark, so I gave each record real fields:

```kotlin
data class Project(
    val id: UUID,
    val name: String,
    val url: String,
    val description: String,
    val statusMonitorId: Int?,   // Uptime Kuma monitor → live status badge
    val tech: List<String>,      // e.g. [Kotlin, Ktor]
    val archived: Boolean,       // hide from the page without deleting
    val position: Int,           // manual ordering
    val createdAt: Instant,
)
```

Two of those fields are the difference between "a list" and "something I'll actually maintain." `position` lets me curate order with ▲/▼ buttons instead of accepting whatever sort the database hands back. `archived` lets me retire a project from the public page without losing the record — soft-delete is almost always the right call for human-curated content.

The Exposed table maps one-to-one, with one deliberate simplification: `tech` is stored as a comma-separated `text` column rather than a join table. A handful of tags on a handful of projects doesn't earn a second table. *Pick the boring encoding until the data tells you otherwise.*

## One database decision, made on purpose

The notes feature already opens a SQLite file on a mounted Docker volume so the data survives redeploys. I had a real fork in the road: put projects in a second table inside that same file, or give it its own `projects.db` next to it.

I chose a **separate database file on the same volume**. In a production service I might consolidate; here the repo's whole job is to *teach*, and a faithful copy of the notes pattern — its own table, its own `Database` handle, its own env-overridable path — is more legible than two tables sharing one connection. The cost was one line in the Dockerfile:

```dockerfile
ENV PROJECTS_DB_PATH=/app/data/projects.db
```

Because the volume mounts the whole `/app/data` directory, the new file rides along with zero changes to my Ansible cluster config. The decision that matters here isn't which option I picked — it's that I picked it *on purpose* and wrote down why, instead of letting the first thing I typed become the architecture.

## Seed the migration into the code

The page already had three projects on it. A feature that launches empty and makes you re-enter your existing content is a feature that annoys you on day one. So the repository seeds those three records on first run:

```kotlin
fun seedDefaults() = transaction(db) {
    if (!ProjectsTable.selectAll().empty()) return@transaction
    DEFAULT_PROJECTS.forEachIndexed { index, seed -> /* insert */ }
}
```

Deploy, and the widget immediately shows exactly what the static list showed — same projects, same status badges — except now they're editable. The migration *is* the seed; there's no separate manual step to forget.

## The admin form is the feature

It's tempting to think the widget is the feature and the admin is overhead. It's the other way around. The read path is a few lines — query the visible rows, render cards, cache for 60 seconds. The thing that makes this worth doing is that maintaining the list is now a form instead of a git push:

- **No JavaScript.** Plain same-origin HTML form POSTs that redirect on success — the same approach as the existing admin. Editing reloads the page with `?edit=<id>` and pre-fills the form. Reordering is two tiny submit buttons that POST a `move`.
- **No new auth.** The form lives under `/admin/projects`, and my Cloudflare Access policy already covers `/admin*`. Authentication happens at the edge before a request ever reaches Ktor; the new route inherited it for free. Designing your URLs so security policies *compose* is worth more than any code you could write.

Reordering is the one bit of real logic, and even it stays simple — swap the two neighbours' stored `position` values:

```kotlin
suspend fun move(id: UUID, up: Boolean): Boolean = newSuspendedTransaction(Dispatchers.IO, db) {
    val ordered = /* all rows, by position */
    val index = ordered.indexOfFirst { it.id == id }
    val swapIndex = if (up) index - 1 else index + 1
    if (swapIndex !in ordered.indices) return@newSuspendedTransaction false
    // swap the two position values
    true
}
```

## Verify like you mean it

The change isn't done when it compiles. I wrote tests at two levels — a repository test that drives CRUD, reorder edge cases (moving the top item up is a no-op), the archived/visible split, and the idempotent seed; and a routes test that hits the real HTTP endpoints through Ktor's `testApplication`, including the "blank name is rejected" path and the redirect-after-create.

Then I ran the actual server and exercised it by hand with `curl` — created a project, moved it up, archived it (and watched it vanish from the public widget but stay in the admin list with an "archived" tag), then deleted it. Automated tests prove the logic; driving the running app proves the *wiring*. You want both, because they fail differently.

## Ship the two halves in the right order

The last subtlety is sequencing a change that spans two repos. The blog's `about.html` now contains:

```html
<h2>Projects</h2>
<div id="projects-widget"
     data-src="https://kotlin-tutorial.michaellamb.dev/widgets/projects">
  loading projects…
</div>
```

That `data-src` is fetched on page load and its response injected — degrading to a quiet "unavailable" message if the service is down. Which means the order of operations matters: **deploy the service first**, confirm the endpoint is live, *then* push the blog that depends on it. Ship them backwards and you get a flash of "loading…" on production until the service catches up.

## The takeaway

None of these steps is clever. Read the existing patterns. Decide the data model and the one real architectural choice deliberately. Migrate by seeding. Treat the admin path as the actual feature. Test at two levels and then poke the running thing. Order your deploys by their dependencies.

That's the whole job. The feature is small on purpose — it's the *shape* of building it that I keep reusing, whether the thing I'm shipping is a Projects list or something a hundred times bigger.
