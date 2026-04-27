---
layout: post
title: "My week with Claude -- April 20 - April 24"
date: 2026-04-27
category: software
image: "/seo/2026-04-27-my-week-with-claude-april-20-april-24.png"
tags:
- claude-code
- ai
- weekly-review
---

## The week at a glance

| Stat | Value |
| --- | --- |
| Messages | 856 |
| Lines | +51,195/-3,208 |
| Files | 657 |
| Days | 23 |
| Msgs/Day | 37.2 |

I doubt that I will keep this up, but I wanted to try it out. I recently learned about the Claude Code native skill `/insights` which tries to provide actionable prompts that solve recurring problems. The skill analyzes the last 30 days of your sessions with Claude Code, so if you haven't been using Claude Code for very long, give it some time before you use it. Don't overthink it — the report is still not completely aware of all the context around your projects and so sometimes the suggestions need to be tweaked.

As an example, I want to share a skill that the report generated for me and how I adapted it.

<!-- Write the week up here. -->
### New Skill — /pre-deploy

Claude could see that there were many times where I came back because of some assumption made by either me or Claude following the deployment of a project to its `staging` or `production` environments. It might have been a change that broke the build in a remote environment but not locally or Claude might have skipped writing new tests for feature coverage, but the pattern was still essentially just: broken deployment, Michael comes back to Claude and enters a debug loop.

The skill Claude suggested was created assuming the project is TypeScript or using npm.

```bash
mkdir -p .claude/skills/pre-deploy && cat > .claude/skills/pre-deploy/SKILL.md <<'EOF'
# Pre-Deploy Check
Run before any deploy:
1. `npm run typecheck && npm test`
2. Grep for env vars referenced in code; confirm each exists in .env.production
3. Check wrangler/bundler versions match production
4. Verify no allowlist/config entries were removed without grep confirmation
5. Report findings before deploying
EOF
```

I modified the skill prompt and then asked Claude to give me feedback, allowing it to compare the report-generated prompt to mine.

```bash
mkdir -p .claude/skills/pre-deploy && cat > .claude/skills/pre-deploy/SKILL.md <<'EOF'
# Pre-Deploy Check
Run before any deploy:
1. Run all tests
2. Grep for env vars referenced in code; confirm each exists in relevant config files
3. Check wrangler/bundler versions match production for codebases with Cloudflare Workers
4. Verify no allowlist/config entries were removed without grep confirmation
5. Report findings before deploying
EOF
```

Here's what happened next: Claude interviewed me about the changes and tweaked the design.

```md
⏺ User answered Claude's questions:
  ⎿  · Where should /pre-deploy live? → ~/.claude/skills/ (global)
     · How should the skill figure out which project / stack it's deploying? → Both: arg if provided, else auto-detect cwd
     · Should step 3 cover Ruby bundler for Jekyll deploys, not just wrangler? → Yes -- cover both
     · Add YAML frontmatter so /pre-deploy is discoverable? → Yes, add it
```

### Elsewhere on the internet

<blockquote class="bluesky-embed" data-bluesky-uri="at://did:plc:tjk5ddnhhjm5ndhvhubi4xwn/app.bsky.feed.post/3mjftgrfkuk23" data-bluesky-cid="bafyreihg5vbppsykyf5ea54z7ievxz67bclnexwamxxttjfywaml2rrm2i" data-bluesky-embed-color-mode="dark"><p lang="en">I’ve never been married and don’t have any kids but I do have a 17-year old Steam profile</p>&mdash; michael lamb (<a href="https://bsky.app/profile/did:plc:tjk5ddnhhjm5ndhvhubi4xwn?ref_src=embed">@michaellamb.dev</a>) <a href="https://bsky.app/profile/did:plc:tjk5ddnhhjm5ndhvhubi4xwn/post/3mjftgrfkuk23?ref_src=embed">April 13, 2026 at 4:41 PM</a></blockquote><script async src="https://embed.bsky.app/static/embed.js" charset="utf-8"></script>
