---
layout: post
title: "kotlin-tutorial: a Ktor service that teaches Kotlin and feeds my blog"
date: 2026-05-17
category: software
image: "/seo/2026-05-17-kotlin-tutorial-pedagogy-and-blog-widgets.png"
tags:
- kotlin
- ktor
- tutorial
- cluster
- homelab
published: true
---

I've always viewed [the homelab cluster]({{ site.url }}/2021/03/cluster-computing/) and this blog as intrinsically related. What happens on the cluster ends up on the blog.

This blog now has two pages with live data on them. [`/cluster`]({{ site.url }}/cluster.html) shows the up/down status of every service running on my six-node Raspberry Pi homelab, sourced from Uptime Kuma. [`/now`]({{ site.url }}/now.html) — modeled on the old-web [now-page convention](https://nownownow.com/about) — lists my recent Letterboxd watches and recently-played Steam games.

None of that data lives in the Jekyll source. The blog is still a static site generator; when it builds, both pages have empty `<div>`s where the live content goes. The HTML that fills them is fetched at page-load time from a Ktor service running on `node5` of the cluster itself.

That service is called [`kotlin-tutorial`](https://kotlin-tutorial.michaellamb.dev). It exists for two reasons: it teaches Kotlin language features through deliberately-duplicated demo routes, and it serves the live widgets `/cluster` and `/now` embed.

## Why a Ktor service and not a static page

The widgets need somewhere to live that can hold an API key (Steam), keep a 60-second cache so I don't hammer Letterboxd's RSS feed on every page view, and serve HTML fragments back to the blog. That ruled out doing the work in client-side JavaScript — a Steam API key can't ship to the browser, and Letterboxd's RSS feed doesn't send CORS headers, so the fetch has to happen server-side. It also ruled out a serverless function — I have a Pi cluster sitting there; I'd rather use it.

At the same time I'd been writing far more TypeScript than Kotlin lately and wanted somewhere to keep the language in my hands. The two needs were a good fit: a small Ktor service on `node5` could host the widgets the blog needed *and* be the place I reach for when I want to internalize a Kotlin feature, with the rest of the routes — the `/tour/*` set — written explicitly as teaching artifacts. The widgets and the tour routes both end up on the blog: the widgets directly, the tour routes via posts like this one.

So `kotlin-tutorial` has two route trees that share a build, a Dockerfile, a deploy pipeline, and a CORS config. The trees are different in what they're for but identical in shape, because they're both there to be read.

## The /tour/\* routes — duplication on purpose

Under `src/main/kotlin/dev/michaellamb/tutorial/tour/` there are seven files, each demonstrating exactly one Kotlin feature:

| Route | File | What it teaches |
|---|---|---|
| `/tour/data-class` | `DataClassRoutes.kt` | `data class`, `copy()`, destructuring |
| `/tour/null-safety` | `NullSafetyRoutes.kt` | `?.`, `?:`, `let`, smart casts |
| `/tour/sealed-when` | `SealedWhenRoutes.kt` | `sealed interface` + exhaustive `when` |
| `/tour/coroutines` | `CoroutineRoutes.kt` | `suspend`, `coroutineScope`, parallel `async` |
| `/tour/extensions` | `ExtensionRoutes.kt` | extension functions |
| `/tour/scope-functions` | `ScopeFunctionRoutes.kt` | `let` / `run` / `with` / `apply` / `also` |
| `/tour/collections` | `CollectionRoutes.kt` | `groupBy`, `sumOf`, `partition`, `runningFold` |

Each file has the same shape: a header comment explaining the feature, a small demo type, a single `Route.xRoutes()` extension function, and a JSON response that returns every variation of the feature side by side.

There is no shared `Tour.kt` base class. There is no `AbstractTourHandler`. There is no `tour-utils` package. The files repeat themselves — the import block, the routing extension, the `call.respond(mapOf(...))` at the bottom — because the repetition is what makes any single file readable on its own.

Here's the whole of `ScopeFunctionRoutes.kt`:

```kotlin
// Kotlin: scope functions (let, run, with, apply, also).
// They differ on (a) what `this` and `it` refer to inside the block, and (b) what the
// expression returns. Same effect, five flavors — pick by what reads cleanest.
private data class GreetingBuilder(var name: String = "", var emoji: String = "")

fun Route.scopeFunctionRoutes() {
    get("/scope-functions") {
        // let:   `it` is the receiver; returns block result. Good for nullable chains.
        val withLet = "kotlin".let { name -> "Hello, $name!" }

        // run:   `this` is the receiver; returns block result. Like let, but receiver-style.
        val withRun = "kotlin".run { "Hello, $this!" }

        // with:  `this` is the receiver (passed as arg); returns block result. Not an extension fn.
        val withWith = with("kotlin") { "Hello, $this!" }

        // apply: `this` is the receiver; returns the receiver. Used to configure a mutable object.
        val withApply = GreetingBuilder().apply {
            name = "kotlin"
            emoji = "K"
        }

        // also:  `it` is the receiver; returns the receiver. Good for side effects (logging, etc.).
        val withAlso = "kotlin".also { println("logging: $it") }

        call.respond(/* ... */)
    }
}
```

If I refactored this into a shared "demo helper" that took a list of `(label, () -> Any)` pairs and rendered them generically, the file would be shorter. It would also stop teaching. The point of this route is *the five lines next to each other*, not the JSON shape they produce. Seeing `let` immediately above `run` immediately above `with` is what makes the difference between them legible. Abstract that and you've abstracted the lesson out of the code.

In production code, this much duplication would be a smell. In teaching code, premature abstraction is the smell. `kotlin-tutorial` is the only codebase I work in where I have to actively suppress my refactor instinct, and I've decided that's good practice.

## /notes — same idea, applied to Ktor itself

There's a second route tree under `src/main/kotlin/dev/michaellamb/tutorial/notes/` — a tiny in-memory CRUD module across three files: `Note.kt` (request/response data classes), `NoteRoutes.kt` (the handlers), and `NoteRepository.kt` (a `MutableMap` behind a thin interface). The data resets on restart, on purpose.

This module isn't teaching a Kotlin language feature. It's teaching Ktor request/response idioms: `call.receive<CreateNoteRequest>()` for typed JSON deserialization, `call.respond(HttpStatusCode.Created, note)`, `runCatching { UUID.fromString(id) }.getOrNull()` for safe parsing without a try/catch, `return@post call.respond(NotFound)` for early exits without nesting. Same philosophy as the tour routes: the *shape* of a handler is the lesson; persistence is a distraction.

## How the widgets fit back in

The widget routes under `src/main/kotlin/dev/michaellamb/tutorial/widgets/` follow the same one-file-per-concern rule as the tour routes, and the header comment on each one names the Kotlin feature it's there to demonstrate:

- `LetterboxdWidget.kt` — **kotlinx.html DSL**. Parses my Letterboxd RSS feed and emits a poster-grid `<div>` via type-safe Kotlin HTML builders.
- `SteamWidget.kt` — **data classes + Jackson**. The `SteamGame` data class doubles as a JSON DTO, with `@JsonProperty` mapping Steam's snake_case fields (`playtime_2weeks`, `rtime_last_played`) onto camelCase Kotlin properties. The widget shows games played in the last two weeks with their recent + lifetime playtime.
- `ClusterWidget.kt` — **structured concurrency**. Hits two Uptime Kuma endpoints in parallel via `coroutineScope { async { } ; async { } }` and combines the results into the per-group service table.
- `WidgetCache.kt` — a 60-second in-memory TTL cache, used by all three.

`WidgetCache` is the one place duplication earned the right to die: every widget genuinely needs a cache, and the cache logic isn't the feature being demonstrated. Everywhere else, the widgets stay as side-by-side standalone examples. They're the bridge between the two halves of the project — useful enough that the blog depends on them, instructive enough to belong in a folder called `tutorial`.

The cluster widget today reads from Uptime Kuma at `status.michaellamb.dev`; eventually I want to replace that with a small Homelab Bot of my own (also Kotlin), but that's a different post.

The deploy path is unremarkable in the way I like: GitHub Actions builds a multi-arch image to `ghcr.io/michaellambgelo/kotlin-tutorial`, the Ansible playbook at `cluster-ops/playbooks/update-kotlin-tutorial.yml` swaps the container on `node5`, and `cloudflared` on `node6` exposes it at `kotlin-tutorial.michaellamb.dev`. The blog's `/cluster` and `/now` pages each `fetch()` HTML fragments from `/widgets/cluster`, `/widgets/letterboxd`, and `/widgets/steam`, with CORS on the Ktor side configured for the blog's origin.

## Why I like this

The two halves of `kotlin-tutorial` keep each other honest. The widgets force the service to be a real Ktor app — it has to handle CORS, caching, environment-variable config, missing-API-key fallbacks, and a Docker healthcheck. The tour routes force me to keep the codebase readable as a teaching artifact — no clever shared infrastructure, no premature abstractions, every route file a self-contained example.

The next time I want to learn a Kotlin feature I keep forgetting — `Flow`, `Result`, context receivers — I'll add a new file under `tour/`, register it in `Routing.kt`, and the deploy will carry it to `node5` like the others. And the next post will tell you what it taught me.
