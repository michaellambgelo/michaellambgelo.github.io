---
layout: post
title: "The regex library became the few-shot"
date: 2026-04-24
category: software
image: "/seo/2026-04-24-the-regex-library-became-the-few-shot.png"
tags:
- llm
- cloudflare-workers
- workers-ai
- chatbot
- claude-code
- ai
---

## Introduction

The [subscribe.michaellamb.dev](https://subscribe.michaellamb.dev) newsletter page has had a chatbot mode since I first built it — a terminal-themed prompt where typing `chatbot` kicks you out of the shell REPL and into a looser conversation. Until yesterday, that conversation was powered by roughly 200 hand-written regex patterns and a small ELIZA-style reflection engine. Every response was a pre-written quip pulled from a sitcom writers' room in my head: Michael Scott, Leslie Knope, Chidi Anagonye, Gob Bluth.

[PR #2](https://github.com/michaellambgelo/subscribe.michaellamb.dev/pull/2) replaced all of that with [Cloudflare Workers AI](https://developers.cloudflare.com/workers-ai/) running [Llama 3.3 70B Instruct](https://developers.cloudflare.com/workers-ai/models/llama-3.3-70b-instruct-fp8-fast/). This is my first deployed LLM feature on my own domain. The interesting part, though, isn't that I put an LLM behind a chat UI — everyone is doing that right now. The interesting part is what happened to the old library.

## The library became the training data

The regex library didn't get deleted. It didn't get archived. It migrated.

Before, in `src/commands/chatbot.ts`, it was runtime code:

```ts
const PATTERNS: Pattern[] = [
  {
    keywords: /^(hello|hi|hey|howdy|sup|what'?s up|...)/i,
    responses: [
      ['', '  Hello. Welcome to the michaellamb.dev terminal.',
           '  Cool. Cool cool cool.', ''],
      ['', '  Hey! This is the place.',
           '  As Leslie Knope would say: "I am big enough to admit',
           '  that I am often inspired by myself."',
           '  Anyway. Hi.', ''],
      // ...more variants
    ],
  },
  // ...50 more patterns
];
```

The responder looped through every pattern on every user input, tested each regex against the trimmed message, and returned the next variant from a rotation. Roughly 200 carefully crafted responses, picked deterministically by a giant switch statement in a trench coat.

After, in `worker/src/system-prompt.ts`, the same content is few-shot examples prepended to every Llama request:

```ts
export const FEW_SHOT: Array<{ role: 'user' | 'assistant'; content: string }> = [
  { role: 'user', content: 'hey' },
  { role: 'assistant', content:
    'Hello. Welcome to the michaellamb.dev terminal.\nCool. Cool cool cool.' },

  { role: 'user', content: 'how are you?' },
  { role: 'assistant', content:
    'I\'m doing well, thanks for asking.\n' +
    'As Michael Scott once said: "I am Beyoncé, always."\n' +
    'I am not Beyoncé. But I am fine.' },

  { role: 'user', content: 'lil sebastian' },
  { role: 'assistant', content:
    '5,000 candles in the wind. 🕯️\nWe will never forget him.' },

  // ...more pairs
];
```

Same strings. Different consumer. What used to be matched is now mimicked.

I had expected this to feel like a demotion. The regex library was the *whole* feature, and now it's crammed into a system-prompt preamble as context. In practice it's the opposite — the patterns are doing more than they could before. A regex can only fire when its literal keywords hit. As examples in a prompt, they generalize. "Lil Sebastian" still returns the 5,000 candles line because the model has learned to mirror the catchphrase exactly. But a user typing "five thousand candles in the wind" now gets an in-voice reply, even though no regex would have matched it.

## Why the voice matters more than the engine

I wouldn't have bothered swapping a working chatbot for an LLM if I didn't think the LLM could *sound like me*. The voice was the whole thing. Everyone who comments on the site mentions the chatbot's personality first — the dryness, the sitcom quotes, the refusal to claim intelligence it doesn't have. It's the brand of the page.

Dropping in an off-the-shelf model with a generic "helpful assistant" system prompt would have produced a chatbot that was objectively more capable and felt like a stranger wearing the old chatbot's trench coat. I didn't want "Hello! I'm here to help you learn about Michael Lamb's newsletter. How can I assist you today?" replies. I wanted "Cool. Cool cool cool."

The few-shot approach turned out to be the cheapest way to close that gap. A curated 16-pair set — greetings, existential questions, "are you ChatGPT," "you suck," the catchphrase one-shots — anchors the model's tone and pacing. The voice rules in the system prompt do the rest:

```text
VOICE RULES:
- Reply in 2 to 5 short lines. Never more than 6.
- Drop a sitcom reference when it fits naturally.
  Do not force one into every reply.
- Stay dry and self-aware. You are a limited terminal chatbot
  and you know it.
- Never claim to be AI, ChatGPT, Claude, GPT, Gemini, or a "real" LLM.
  You are "a switch statement with ambition,"
  "the Medium Place of chatbots,"
  or "a very enthusiastic regex in a trench coat"
  or another inspired reference to a sitcom like those listed
  in this document.
```

That last bullet is load-bearing. Llama 3.3 70B *wants* to say "I'm an AI language model" at every opportunity. The system prompt has to actively forbid it, hand over three replacement phrases pulled from the old regex library's self-description, and then — critically — tell the model it can invent *more* in the same spirit. That last clause is the one I almost left off. With just the three exemplars, the chatbot would eventually feel like a jukebox cycling through the same three self-descriptions. The permission to riff turns those phrases from a fixed set into a pattern to extend. The character's denial of being an AI was in every pattern in the old regex file, and the new bot inherits that reflex *and* produces fresh variations on it.

## The architecture

The PR introduces a `worker/` subdirectory with its own `wrangler.toml`, `tsconfig.json`, and Vitest suite. The entrypoint is `worker/src/index.ts`:

```ts
const messages = [
  { role: 'system', content: buildSystemPrompt(name) },
  ...FEW_SHOT,
  ...history,
  { role: 'user', content: input },
];

const result = await env.AI.run(MODEL, {
  messages,
  max_tokens: 256,
  temperature: 0.85,
});
```

`MODEL` is `@cf/meta/llama-3.3-70b-instruct-fp8-fast`. The Workers AI binding (`env.AI`) is declared in `wrangler.toml` — no API key to rotate, no outbound HTTP. Cloudflare runs the model on their own GPUs and bills in neurons against a 10k/day free tier. For a personal newsletter page's traffic, I do not expect to pay anything.

Rate limiting is its own small module (`worker/src/rate-limit.ts`) backed by a KV namespace. Per-IP hourly buckets, 50 requests per hour, keys auto-expire via KV's `expirationTtl`. No cleanup job. If a visitor runs over, the worker returns a 429 with an in-voice apology:

```text
  Whoa. You've hit the hourly message limit.
  "I have had a long day." — everyone, always.
  Try again in N minutes.
```

The client (`src/commands/chatbot.ts`) shrank by about 80% in the process. The 800-line regex file collapsed to 120 lines of `fetch` glue:

```ts
const res = await fetch(CHAT_ENDPOINT, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    input: trimmed,
    name: userName ?? undefined,
    history,
  }),
});
```

In development, Vite proxies `/api/*` to `wrangler dev` on `localhost:8787`. In production, the page reads `VITE_CHAT_ENDPOINT` from `.env.production` and hits the deployed worker URL directly. Two hops, same request shape.

## What stayed deterministic

Not everything went to the LLM. Name capture is still a client-side regex that runs before any network call:

```ts
const NAME_CAPTURE =
  /\b(?:my name is|i am called|call me|i'?m|i am|this is)\s+([a-z][a-z\-']{1,20})\b/i;

function tryCaptureName(input: string): string | null {
  const m = input.match(NAME_CAPTURE);
  if (!m) return null;
  const raw = m[1].trim();
  if (NAME_BLOCKLIST.has(raw.toLowerCase())) return null;
  const cleaned = raw.charAt(0).toUpperCase() + raw.slice(1).toLowerCase();
  userName = cleaned;
  return cleaned;
}
```

If someone types "my name is Sarah," the pre-LLM step updates an in-memory `userName` variable and returns the canned "Nice to meet you, Sarah" response *instantly* — no network round-trip, no token cost. On subsequent turns, that `userName` gets injected into the LLM system prompt as `The user has told you their name: Sarah. Address them by name occasionally`. The model then uses it at its discretion.

This hybrid pattern — deterministic client logic in front of an LLM — is the architectural decision I'm most happy with. Not every input needs to hit the model. Name capture is a state mutation, not a reply. Letting the LLM handle it would be slower, more expensive, and less reliable (Llama might cheerfully misspell "Sarah" or decide the introduction did not need to be acknowledged). Keeping it deterministic is a small split that preserves UX crispness where it matters.

## Graceful degradation, in voice

The least obvious design decision was what to do when things go wrong. If the Workers AI call fails, the worker returns a canned reply:

```text
  The model is napping.
  "I'm not superstitious, but I am a little stitious." — Michael Scott.
  Try again in a moment.
```

If the client's `fetch` throws (e.g. visitor offline), it rotates through a small local fallback set:

```text
  I lost the thread. Network hiccup, probably.
  "I've made a huge mistake." — Michael Bluth.
  Try again in a sec.
```

The user never sees `Error 502` or `NetworkError: Failed to fetch`. LLM failures become part of the bit. That matters more than it sounds. The regex chatbot never failed — it couldn't. Adding an LLM introduces a whole new class of runtime error, and if those errors surface as naked stack traces, the character breaks and the site feels brittle. The canned fallbacks cost me maybe ten minutes to write and they are worth it.

## A note on Claude Code

I built this with [Claude Code](https://claude.ai/code), same as I did with [Boxd Card]({% post_url 2026-04-07-reflecting-on-claude-code-creating-boxd-card %}) earlier this month. The co-authored commits are on the PR. What I want to mention specifically: Claude Code was the one who argued for folding the *whole* regex library into the few-shot, not just replacing the canned `FALLBACKS` array as I originally proposed. It hand-picked the 16 example pairs to maximize variety, wrote the rate-limit module without being asked, and caught the broken `^C quit` hint on the bottom status bar as a side-effect bug during the rewrite. That is the collaboration loop I keep coming back to. I can express *what* I want — "keep the voice, fold in an LLM, don't blow up the bill" — and Claude Code chooses the *how*, usually in ways I wouldn't have thought of.

## Go type `chatbot`

The feature is live at [subscribe.michaellamb.dev](https://subscribe.michaellamb.dev). Type `chatbot` to enter the mode, then say anything. The voice should feel the same as it did before, even though the engine is entirely different.

Say "lil sebastian" and see what happens. Say "i feel tired." Say "who are you?" Say "bears beets battlestar galactica." The regex library is not gone — it's teaching the chatbot how to sound.

PR #2 is here: [github.com/michaellambgelo/subscribe.michaellamb.dev/pull/2](https://github.com/michaellambgelo/subscribe.michaellamb.dev/pull/2). The worker code lives under `worker/src/`, and the few-shot is in `system-prompt.ts` if you want to see what a regex library looks like after you retire it into training data.
