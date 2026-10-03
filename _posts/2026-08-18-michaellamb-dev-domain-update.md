---
layout: post
title: "michaellamb.dev: A Three-Month Domain Update"
image: "/seo/2026-08-18-michaellamb-dev-domain-update.png"
category: software
tags:
- life-update
- homelab
---

## Three months is long enough to lose the thread

I write posts about individual things. A landing page moves. A KV store gets built. A
trivia deck gets taken apart in five parts. Each one is honest about its own scope and
completely silent about everything happening next to it.

So here is the wide shot. Between May 18 and today, michaellamb.dev picked up a new front
door, a membership platform, a podcast pipeline, a TV in my living room that reports on
itself, and a security pass I should have done sooner. GitHub counts 629 contributions in
that window, but that number flatters me: about eighty of them are a cron job refreshing
Letterboxd data, which commits under my name and has never had an idea in its life. Strip
those out and it is closer to 550 — plus 36 pull requests and seven repos that did not
exist in May. Twenty-eight repositories saw a push. Four more live on public GitLab.
Seventeen posts went up here.

Those are just numbers, so let's go property by property.

## The front door moved off Carrd

My Carrd Pro subscription was ending in August, which set a deadline I hit a month early.
[michaellamb.dev](https://michaellamb.dev) is now a static page I own end to end, deployed
to Cloudflare, built on the same design system as this blog. I wrote that one up already in
[Announcing the Redesigned michaellamb.dev Landing Page]({% post_url 2026-07-24-redesigned-michaellamb-dev-landing-page %}),
so I won't repeat it — the short version is that the whole migration took about two days of
tinkering and the hero effect is a canvas trick no page builder would ever have let me have.

## The blog got a series and a new set of cards

Seventeen posts, and the biggest single chunk was *Anatomy of a Trivia Deck*, a five-part
walkthrough of the presentation app I use to run pub trivia. It published across five days
in July.

Less visible but more satisfying: I rebuilt the SEO card generator on the site's design
system and regenerated every card in the archive. The social previews now match the site
they link to, which they had never quite done before. I also did a full audit pass over
post categories and tags — an updated taxonomy that hopefully makes my content easier to
navigate.

## jxnfilm.club stopped being a signup form

This was the single biggest line item of the quarter — roughly 110 hand-written commits,
ahead of anything else I touched. Another 220-odd commits in that repo are the bot
refreshing Letterboxd data and snapshotting attendance, which is progress of a sort, but
not the sort I get to take credit for.

In May, [Jackson Film Club](https://jxnfilm.club) was a landing page with an email capture.
Today it is a membership platform. Members host their own screenings with RSVPs, a waitlist,
and a private address that is only ever revealed by email. There is a newsletter composer I
built rather than renting — it pulls poster art from TMDB, inserts what members have been
watching (with their Letterboxd star ratings and likes), and has a proper opt-out. There is
an admin portal on its own subdomain behind Cloudflare Access. There is a Watched page that
opens with a list of what the whole club saw in the last seven days, then lists the last four
films watched by members.

The feature I have had in the back of my mind for years: `/speak`. Members record voice clips
answering a prompt, the clips land in R2 with a 60-day retention policy, and I can compile
them into a podcast segment — or export a single clip as a branded audiogram video for social.
That went from idea to shipped in about a day.

There is also a privacy policy, and it is not decoration. A daily cron scrubs RSVP emails
and host addresses thirty days after an event. Deleting your account purges your RSVP
records. The fonts are self-hosted so Google never sees a request. When I changed how host
names are handled this month, I changed the policy in the same commit, because policy should
always align with code.

Signups ran just under forty in the window, with a handful of removals — which is to say the
self-service *Remove Membership* button works, which is its own kind of good news. Most of
those were profiles I created for testing, but a few members have legitimately decided to
remove themselves — there are exit signs in every building open to the public, and community
web portals should operate the same. No one's data should be held hostage.

## Fertile Ground got a real front end

The Fertile Ground events app runs the trivia leaderboard, the pinball tournament brackets,
and the venue calendar. Over the last three months it grew a public landing hub at the root
(admin moved to `/admin` where it belongs), an events calendar with iCal subscription and
add-to-calendar links, admin-managed pinball tournaments that no longer require a redeploy
to change, and shareable results graphics so the winners have something to post. It also
picked up Grafana Faro instrumentation, so I can finally answer questions like "does anyone
actually open the leaderboard on their phone during the show" with data instead of a guess.

Alongside it, [fertile-ground-trivia](https://fertile-ground-trivia.pages.dev) forked out of
my generic scaffold in July and became the real Taproom Trivia deck — Fertile Ground's
palette, Fertile Ground's copy, deployed on its own. This is just the beginning of my
branded trivia days.

## The scaffolds stayed scaffolds on purpose

[pub-trivia-scaffold](https://michaellambgelo.gitlab.io/pub-trivia-scaffold/) is public on
GitLab and stayed theme-neutral by design, because its job is to be cloned. This quarter it
got a pulp-poster restyle, a picture round with configurable fit modes, a CSV round-trip that
actually survives a spreadsheet edit, and a Google Sheets template so a host who does not
write code can still build a deck. When I fixed the CSV path for Fertile Ground, I backported
it to the scaffold — that direction of travel feels pretty normal in my software dev experience.

## Boxd Card moved and then got hardened

[Boxd Card](https://boxd-card.com) moved to its own domain in June and got a marketing
landing page to go with it. Then, two days ago, it got a proper security and privacy pass: the
extension now parses fetched review HTML inertly, the Worker re-checks its allowlist after
redirects and sets CORS headers on error paths, a stuck image load times out instead of
hanging the render, and telemetry stopped recording the Letterboxd URLs and slugs the privacy
copy promises not to collect. That last one was a real gap between what the page said and
what the code did, and it is closed.

## Custom Letterboxd apps

The Letterboxd side of the house also got the
[rolodex](https://letterboxd.michaellamb.dev/rolodex): a page of curated Letterboxd profiles
showing each person's last four watched, streamed as NDJSON so cards fill in progressively
instead of blocking on the slowest scrape, with a filter box, an A–Z rail, and sort options.

My [custom Letterboxd stats dashboard](https://letterboxd.michaellamb.dev) was also enriched with archive data listing diary entries I created but the film was removed from Letterboxd, for whatever reason. I think some of the cases are artist takedown requests, but I suspect there are titles which are removed by Letterboxd editorial staff. I don't know that for certain, but I suspect it.

## The homelab cluster learned to talk to the TV

The [Kotlin tutorial service](https://kotlin-tutorial.michaellamb.dev) — still deliberately
pedagogical, still one endpoint per language feature, still not refactored into cleverness —
picked up the `/now` widget that backs this blog's Now page, Steam cover art for the games
section, and `/signage`: a full-page, TV-optimized digest of everything the service knows.
This week it grew a commit ticker and QR codes for note links.

I have a Discord bot hosted on the homelab cluster. It learned to cast that page to the living 
room TV on a slash command, and grew a Hue widget so the display doubles as a light-status panel. 
Underneath all of it, the cluster migrated its Docker runtime off snap on four nodes, and image 
builds moved to a Mac mini that builds arm64 natively instead of emulating it in CI — a change 
that took deploys from "go get coffee" build times to "just wait a minute." My Ansible deploy 
config handles the rest once the image is built.

## What I'd tell you if you asked what I actually did

I built things for people who are not me. The film club is for a room full of people in
Jackson who want to watch movies together. The trivia apps are for a taproom on a Tuesday.
The signage is so guests at my house can glance at a TV and know how to turn the lights off.

The infrastructure posts get the traffic, but the reason the infrastructure exists is that
somebody is standing in a bar waiting for a leaderboard to load.

## Subscribe

If you want content like this sent to you directly — the posts, the build logs, the occasional
correction when I got something wrong in public — the newsletter is at
[subscribe.michaellamb.dev](https://subscribe.michaellamb.dev). No algorithm — just the posts, in the order I wrote them.

One more thing about that `subscribe` app. It is not a form; it is a terminal. Type `help` and it will
list its commands.

`help` is not the complete list.

There is a `chatbot` in there, and it has opinions about a very specific set of sitcoms. If a
line from one of them comes to mind while you are sitting at that prompt, type it. Some of
them answer back.
