---
layout: post
title: "There Are No Current Laws Which Limit or Restrict Saving Data"
date: 2026-09-03
category: reflections
image: "/seo/2026-09-03-no-current-laws-limit-saving-data.png"
tags:
- security
- cloudflare
---

Here is a sentence about the state of Nevada:

> Yes. There are no current laws which limit or restrict saving data from a scanned ID in Nevada.

It is a true sentence. It is also, as far as I can tell, a helpful one — it appears in a
state-by-state guide to ID scanning law that is genuinely useful if you run a business that has to
check IDs. Nevada requires you to authenticate an ID before you sell cannabis. It does not require
you to store an image of that ID, and it does not tell you when to throw one away.

The guide is published by IDScan.net.

On September 1st, [Brian Krebs
reported](https://krebsonsecurity.com/2026/09/fbi-probes-service-selling-153m-drivers-licenses/)
that a new dark web service was selling digital scans of more than 153 million drivers licenses
from the United States and Canada, and that the images appeared to be siphoned from IDScan.net, a
New Orleans identity verification company. The FBI's New Orleans field office opened an
investigation the same day. One of the few collection points anyone has confirmed on the record is
a cannabis dispensary in Las Vegas.

I want to be careful here, because the interesting thing about this story is **not** that a company
got breached. Companies get breached all the time. The interesting thing is the sentence above, and
the fact that it was on the internet, on the vendor's own website, before any of this happened.

## A year of collecting stolen data

The line in Krebs's reporting that stopped me was not the 153 million. It was the seller's own sales
pitch:

> We have been continuously exfiltrating new data for over a year into our private database.

A year. And over the twenty-four hours Krebs was writing the story, the record count went up by
about four hundred thousand.

I want to resist an inference here that I reached for immediately and cannot support. "Continuously
exfiltrating new data" is exactly what a live tap on a capture pipeline looks like, and the public
reporting cannot tell us whether these images sat in a vendor's storage for a year or were siphoned
off the moment each scan happened. Krebs's own license was captured in June of 2025 and was on sale
in September of 2026. That tells us the person holding the tap kept everything for fifteen months.
It does not tell us what the vendor kept.

What it does tell us is the shape of the exposure. The leaked set spans more than a year of
captures, whoever held the tap discarded none of it, and if those images had also been sitting in
storage at the other end, no law in Nevada would have said a word about it.

A commenter on the article named Jimmy put the consequence better than I would have:

> The bitter irony here is that the scans appear to come from identity verification vendors — the
> companies paid to establish trust are the ones that became the breach. A leaked license image plus
> a selfie cannot be rotated like a password, so victims carry this forever.

That is the part that makes this category of breach different in kind rather than degree. Our entire
professional vocabulary for responding to a breach assumes the leaked thing can be reissued. Rotate
the key. Force a password reset. Revoke the token, mint a new one. None of that has an analogue
here. I cannot rotate my face, my address history, or the hologram on my license. Even a brand new
license number would not help me, because the thing in that database is a photograph.

## We know how to write a delete clause

I want to head off the easy version of this argument, because I believed it myself for about an hour
and it is wrong.

The easy version is: the law tells businesses to check IDs and then goes silent, so of course
everyone keeps everything. Nobody ever wrote a rule about deletion.

Except they did. Texas HB 1181 — the age verification law for pornography sites, the one the Supreme
Court upheld in June of 2025 — says that a party performing age verification
[may not retain any identifying information of the
individual](https://capitol.texas.gov/tlodocs/88R/billtext/html/HB01181H.htm) after access has been
granted. It carries penalties of up to ten thousand dollars a day, plus a separate ten thousand
dollars a day specifically for unlawfully retaining the data.

That is a delete clause with teeth. It exists. Somebody drafted it, a legislature passed it, and the
Supreme Court let it stand. So the problem is not that we lack the concept.

The problem is where we spend it. We wrote the retention penalty for the thing that embarrasses us,
and not for the thing that exposes us. Nevada mandates the dispensary scan and says nothing about
keeping it.

And the vendor that operates in nineteen states and processes twenty-one million verifications a
month maintains the state-by-state guide to exactly this question. Its California page enumerates
the narrow purposes for which scan data may be retained there — fraud investigation, age
verification, a legal requirement to record it. Its Nevada page answers the same question with
"there are no current laws which limit or restrict saving data from a scanned ID."

That is not a loophole somebody found. It is a document somebody wrote. It is a door left open.

## Four fields

My own state is the clearest small example of this open door I have found.

[Mississippi Code § 63-1-67](https://law.justia.com/codes/mississippi/title-63/chapter-1/article-1/section-63-1-67/)
governs renting a car to somebody. Before you hand over the keys, you have to inspect the renter's
license and compare the signature on it against one the renter writes in front of you. Then you have
to keep a record. The statute says exactly what that record contains: the registration number of the
vehicle, the name and address of the person renting it, the license number, and the date and place
the license was issued.

Four fields and a signature check. That is a ledger entry. You could satisfy Mississippi with a
spiral notebook.

Mississippi's statute did not govern Krebs's own rental — he flew to the Midwest. But here is what
a rental counter produced in his record:

> The record that features my drivers license includes six image files — three pairs of photos of
> the license's front and back — a basic image scan — as well as infrared and ultraviolet versions of
> the same images.

Six timestamped images, including captures under infrared and ultraviolet light, per person. Nothing
in § 63-1-67 asks for a photograph. Nothing in it forbids one either. The law described a ledger and
the industry built an archive, and the gap between those two things is not a violation. It is just
the space that was left.

## What deleting actually costs

I keep coming back to this story because I have written the deletion path twice, and both times it
was my idea.

The first one is a Cloudflare Worker called `now-store` that backs the "recently updated" widget on
my [`/now` page](/now). I wrote about it [last
June](/2026/06/now-store-a-kv-store-built-to-forget-next-to-a-database-built-to-remember/). Its
entire retention policy is this function:

```js
/** Translate the chosen lifetime into a KV expirationTtl (seconds, >= 60). */
function ttlForExpiry(expiry, now = new Date()) {
  const toMidnight = secondsUntilNextChicagoMidnight(now);
  let ttl = toMidnight;
  if (expiry === 'day') ttl = toMidnight + DAY;
  else if (expiry === 'week') ttl = toMidnight + WEEK;
  return Math.max(ttl, KV_MIN_TTL);
}
```

The number that comes out goes straight into the write:

```js
await env.ENTRIES.put(`entry:${entry.id}`, JSON.stringify(entry), { expirationTtl: ttl });
```

That is the whole thing. The comment I left at the top of the file says it plainly: entries vanish
on their own — no cron, no cleanup.

I want to be precise about why that shape is good, because it is not that it is elegant. It is that
the deletion is a property of the write. It happens whether or not I am paying attention. It happens
if I lose interest in the project, if I stop paying for the domain, if I get hit by a bus. There is
no daily job to monitor, no dashboard that goes yellow, no runbook. I could not accidentally retain
that data if I wanted to, because retaining it would require me to go back and write new code.

That is about twenty lines. It cost me an afternoon.

## Except when it costs more than that

The second one was much harder, and it is the honest half of this post.

[JXN Film Club](https://jxnfilm.club) lets members host screenings at their houses. That means the
system holds a home address and some private notes, and those have to be visible to the people
coming — right up until the event happens, and then not. There is no TTL that expresses "keep this
until a date that a human typed into a form, then reduce it." So I wrote a cron:

```js
const SCRUB_AFTER_DAYS = 30

async function scrubPastEvents(env) {
  const cutoffDate = new Date(Date.now() - SCRUB_AFTER_DAYS * 86400_000)
  const cutoff = new Intl.DateTimeFormat('en-CA', { timeZone: 'America/Chicago' }).format(cutoffDate)
```

Thirty days after a screening, it strips the address and the notes off the event, then walks the
entire RSVP keyspace deleting records for events that are past the cutoff. It is maybe forty lines
instead of twenty, and every one of them is a liability. It has to run. It has to page through a
cursor correctly. It has to handle events that no longer exist.

I know it has to handle that last case because I wrote a comment in it admitting so:

```js
// RSVP sweep: delete every rsvp:{id} whose event is past the cutoff — or
// gone entirely (the admin dashboard writes KV directly and can orphan a
// record; handleDeleteEvent cleans up after itself).
```

The admin dashboard writes to KV directly and can orphan a record. I wrote that sentence about my own
software, on purpose. It is a promise I have to keep reminding myself of, forever, and I have
already documented one way it can quietly fail to be kept. An admin dashboard comes with access
privileges, and understanding the underlying architecture is vital to having enforceable retention
and deletion policies.

I am not going to resolve the tension between those two systems, because I do not think it
resolves.

Some data can expire on a timer and some data has a social lifetime instead, and the second kind is
genuinely harder to forget correctly. What I will say is that both times, the forgetting was
something I had to sit down and build. No framework gave it to me. No default did it for me. Nothing
in Cloudflare KV, or any other store I have used, deletes anything on its own unless I tell it to.

Retention is what happens when nobody does anything. That is the whole point. It is not a decision
anyone makes; in some cases it is the willful absence of one, exploitable.

## Where I have handed over a license

I have given my drivers license to a scanner at a rental counter. I have handed it to somebody at
the door of a bar. I have handed it across a desk at a clinic during check-in and had it
handed back to me a few seconds later. Some of them used an automated scanner. I have no clue what
they do with that information, and usually I'm not in the mood to ask. I know I won't like the answer.

After reading the comment thread on this article I am less confident that anyone on either side of
those counters knows what happens to the image — one commenter noted that license scans are now a
routine part of checking in at medical facilities, and another pointed at whole categories of venue
where cities have encouraged door scanners as a matter of policy.

So I am probably in this data set. Possibly more than once. If so, I cannot revoke it, for the
reason Jimmy already said. And the honest summary of my position is that I have no move available
to me at all, which is a strange thing to write two sections after showing you how cheap it would
have been to delete.

## Everyone's talking about a "blast radius" these days

The comment on the article I keep thinking about came from someone posting as Doug Fresh:

> Meridianlink is listed on idscan.net's website. They are the data broker that provides services
> for 100's of background check companies that in turn service 1,000's of companies. "If" idscan is
> indeed confirmed to be the source this will have a huge blast radius.

IDScan's own trust page names Hertz, Target, FedEx, Motorola Solutions, Jack Henry, and Caesars.
Twenty-one million verifications a month, twenty thousand locations. That concentration is not a
side effect of the business — it is the business. The entire value proposition of an identity
verification vendor is that a thousand companies do not each have to build this, so all thousand of
them point at one place instead.

Which means the number that matters is not 153 million. It is the number of independent decisions
that had to go right to keep 153 million people's documents from ending up in one searchable index,
and how few of those decisions there turned out to be. Warehousing sensitive information for
indeterminate periods of time was always a ticking time bomb. When, not if.

It reminds me of season 3 of *MR ROBOT* — spoilers ahead, so skip to the next heading if you want to
avoid them. Elliot spends the season trying to stop Stage 2, a Dark Army plot to blow up the
building holding E Corp's paper records. His countermeasure is to hack E Corp's shipping system and
scatter those records across 71 other facilities, so that there is no single building left to
destroy. The Dark Army bombs all 71. What Elliot didn't realize is that decentralizing the records
never touched the actual single point of failure: him. Being used in this way by the Dark Army,
Elliot was simply a vehicle for someone else's agenda, and I think that's how a lot of people who
have been affected by this breach might feel.

## The remediation vocabulary

Two more commenters, back to back, wrote the entire arc of a modern breach response before it
happened. First, from vbb:

> It's a bit late to hold ID vendors to a higher security standard, when the ID data has been
> exfiltrating for over a year. IDscan is so concerned about it, they sent a marketing person to talk
> to you. Surely, the next step is for IDscan to issue a press release saying "your security is our
> top priority".

And immediately below it, from Stephen Tinius:

> … and to show we're sincere, here's a year's free identity theft protection service, etc.

I laughed.

The joke is load-bearing, though. A year of free credit monitoring is a remedy designed for a stolen
card number — a credential with an expiry date, issued by an institution that can cancel it and send
you another one. Offered for a photograph of your face and your address, it is not cynical so much
as category-confused. There is no year at the end of which the images stop existing.

Shortly after Krebs published, the service went dark and replaced its login page with the words
"This service is no longer available." I do not find that reassuring in the slightest. Taking down
the storefront does not un-copy the inventory, and the seller told us they had been collecting for a
year before anyone noticed the shop was open.

## Ending where it is uncomfortable

I do not have a prescription, and I distrust the version of this post that ends with one.

I cannot tell you IDScan did anything wrong, and I am not going to, because there is an active
federal investigation and I have only read public reporting. What I can tell
you is that nothing in that reporting suggests anybody broke a retention rule — and in Nevada, where
the dispensary Edwards named sits, there was not one to break. That is not exoneration. It is
worse than that. It means the system worked as designed and produced 153 million license scans in a
searchable index anyway.

The rules we do have got written about content. What is being verified, who is allowed to see it,
which category of website has to check. Almost nothing got written about custody: where the document
goes after the check succeeds, who holds it, and for how long. Those are the questions an engineer
has to answer to build the thing at all, and they are the questions the statute mostly leaves blank.

And I would like to be able to end by telling you that I get this right in my own work. I get it
half right. One of my two systems cannot fail to forget, because forgetting is welded to the write.
The other one is a cron job I have to keep correct forever, and there is a comment in it explaining
exactly how a record can slip past it and survive. That's a system design constraint.

I wrote that comment because I wanted to be honest with myself about the sharp edge. I did not
expect to end up quoting it in a post about somebody else's breach.
