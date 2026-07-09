---
layout: post
title: "Adapting the /now convention on my blog"
date: 2026-06-01
category: personal
image: "/seo/2026-06-01-adapting-the-now-convention.png"
tags:
- claude-code
- now-page
- indieweb
- letterboxd
- homelab
published: true
---

The suggestion came from a robot, which is a funny way to find a deeply human corner of the web.

I was trying to get [`kotlin-tutorial`]({% post_url 2026-05-17-kotlin-tutorial-pedagogy-and-blog-widgets %})
onto this blog in a way that was *direct and pedagogical* — not "here's a link to a repo," but
something a reader could actually see working and explore at their own pace. 
I asked Claude Code for ideas, and one of them was the now-page convention. 

I'd never heard of it until then — and I've been on the internet since 1999.

## What a now page is

The [now-page convention](https://nownownow.com/about) is old-web stuff: a person posts a
regular update — daily, weekly, whenever — just listing what they're working on or what they're up
to. Heads-down on a side project. On vacation. Taking time off. It's a `/now` page because it answers
"what are you doing *now*," as opposed to an `/about` page that answers "who are you in general."

I love the idea. It's the unhurried, un-metricked corner of the web I love to visit — no
algorithm, no engagement bait, just a person telling you what's on their plate this season.

## My take: let the API show it

Here's where I diverge from the purists. The classic now page is hand-written and reflective — you
sit down and type out where your head is. Mine is mostly automated. [`/now`]({{ site.url }}/now.html)
on this blog is an API connecting my digital life to the page: the movies I'm watching (Letterboxd),
the games I'm playing (Steam), and the software engineering I'm doing — as represented on my public
GitHub profile.

I never considered using a custom API to be shorting that promise. 
I appreciate that the whole charm of a now page is the intentional
*act* of writing it. 

An API that pulls my last few watched films and my last 24 hours of commits is,
by definition, not reflective. It's just *true*.

But I've decided the two aren't in conflict. The API is the **live layer**: always current, can't
drift out of date, can't quietly lie about what I've actually been up to. A hand-typed now page is
only honest on the day you write it; by the next week it's a slightly flattering memory. The feed
doesn't get that luxury, and I'm not always committing public code every day.

And nothing stops me from putting a few sentences of human context *above* the feed when I have
something to say — "on vacation," "heads-down on the homelab bot," "took the month off games to
read." The automated layer answers *what*; a line of prose answers *why*. I'd rather have both than
pick one, and I'd rather the *what* never go stale.

## Three feeds, because that's the public me

I picked movies, games, and code for an unglamorous reason: those are the three parts of my life that
already have a public face. Letterboxd is already public. My Steam profile is already public. My
GitHub commits are already public. The `/now` page doesn't expose anything new about me — it just
gathers the feeds I'd already opted into and points them at one spot.

## The how lives in another post

If you want the plumbing — the Ktor service on the homelab, the server-side cache so I'm not
hammering Letterboxd's RSS feed on every page view, the reason none of this could run as client-side
JavaScript — that's all in
[the kotlin-tutorial write-up]({% post_url 2026-05-17-kotlin-tutorial-pedagogy-and-blog-widgets %}).
This post is the *why*; that one is the *how*. The short version: a small service on `node5` of the
cluster fetches the three feeds, caches them for a minute, and hands the blog back HTML fragments
that [`/now`]({{ site.url }}/now.html) drops into place at load time.

That's the part that finally satisfied the original goal — getting `kotlin-tutorial` onto the blog
directly, not as a footnote. The service isn't *described* on the now page; it *is* the now page.

## So that's where I'm at, now

Claude Code introduced me to a nostalgic, hand-written convention and I promptly automated most of the
nostalgia out of it. I don't think that's a betrayal so much as a translation — the same "here's what
I'm up to" impulse, wired to the feeds that already know the answer. The prose layer is still there
when I want it. The rest writes itself.

There's one piece I haven't built yet. Right now "when I want it" means editing HTML and pushing a
commit — enough friction that I rarely do. So the next thing I want is a way to drop a one-line
status that publishes in seconds and maybe **clears itself at midnight**: a daily note with a built-in
expiration date, so the human layer can never sit there three weeks stale insisting I'm still
"heads-down on the homelab bot." The feeds stay honest by being live; the prose should stay honest by
being ephemeral. That's a different post — and the one I'm most looking forward to writing.

Go see [what I'm up to right now]({{ site.url }}/now.html). By the time you read this, it'll already
have changed — which is the entire point.
