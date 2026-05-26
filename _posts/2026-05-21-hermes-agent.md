---
layout: post
title: "Setting up Hermes Agent, my first AI harness"
date: 2026-05-21
category: machine-intelligence
image: "/seo/2026-05-21-hermes-agent.png"
tags:
- ai
- agents
- llm
- nous-research
published: true
---

> **Correction (2026-05-26):** This post implies Hermes runs Claude under your existing Claude.ai subscription. In practice, Hermes's default request shape (Opus + full toolset, with auto-retries) gets routed onto Anthropic's overage / extra-usage path — real money, not subscription headroom. I burned through $60 in extra-usage credits before I figured this out. See [the follow-up post]({% post_url 2026-05-26-hermes-agent-cost-correction %}) for the full story.

## What is an AI harness?

Honestly, I don't know. I'm doing this to learn it. [NetworkChuck happened to post about it today on YouTube](https://www.youtube.com/watch?v=QQEgIo4Juxg) and I liked the vibe of the [Hermes Agent](https://hermes-agent.nousresearch.com/) website.

After installing, I ran a quick setup which took about 10 minutes, including setting up a Discord bot. I haven't gotten Hermes to chat with me in Discord yet, still working on that at this point in writing, but Hermes did describe itself:

> The harness — that\'s Hermes. Hermes is the agent framework wrapped around the model. It\'s what gives me hands: the terminal access, file editing, web browsing, subagents, cron jobs, memory across sessions, skills, messaging integrations. The model alone is just text-in/text-out; Hermes is what turns it into an agent that can actually do things on your Mac. (That\'s also why my tools are named things like mcp_terminal, mcp_browser, etc.)

Another quote, this time from the creators of Claude:

> Anthropic's key distinction: workflows = LLMs on predefined code paths; agents = "LLMs dynamically direct their own processes and tool usage." A harness is the runtime that makes the latter possible. — Anthropic [[source](https://www.anthropic.com/engineering/building-effective-agents)]

As I understand it, Claude Code will spawn agents which follows the distinction outlined by Anthropic; Hermes, to contrast, is not spawned *by* Claude but rather *sits on top of* Claude, which can continue to spawn subagents for tasks.

I'll continue my story below this code block, but first, here's my opening conversation with Hermes. Below is my first launch of `hermes` and I desire to know two things on first boot: "how do I use you?" and "am I talking to Hermes or to Claude or sometimes both or something else?"

```bash
╭─░▒▓    ~/Workspace ····················································································································· 1 ✘  took 15s   at 22:36:26  ▓▒░─╮
╰─ hermes                                                                                                                                                                           ─╯

██╗  ██╗███████╗██████╗ ███╗   ███╗███████╗███████╗       █████╗  ██████╗ ███████╗███╗   ██╗████████╗
██║  ██║██╔════╝██╔══██╗████╗ ████║██╔════╝██╔════╝      ██╔══██╗██╔════╝ ██╔════╝████╗  ██║╚══██╔══╝
███████║█████╗  ██████╔╝██╔████╔██║█████╗  ███████╗█████╗███████║██║  ███╗█████╗  ██╔██╗ ██║   ██║
██╔══██║██╔══╝  ██╔══██╗██║╚██╔╝██║██╔══╝  ╚════██║╚════╝██╔══██║██║   ██║██╔══╝  ██║╚██╗██║   ██║
██║  ██║███████╗██║  ██║██║ ╚═╝ ██║███████╗███████║      ██║  ██║╚██████╔╝███████╗██║ ╚████║   ██║
╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚══════╝      ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝   ╚═╝

╭─────────────────────────────────────────────────────────────── Hermes Agent v0.14.0 (2026.5.16) · upstream 4e2c66a0 ────────────────────────────────────────────────────────────────╮
│                                   Available Tools                                                                                                                                   │
│  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⡀⠀⣀⣀⠀⢀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀   browser: browser_back, browser_click, ...                                                                                                         │
│  ⠀⠀⠀⠀⠀⠀⢀⣠⣴⣾⣿⣿⣇⠸⣿⣿⠇⣸⣿⣿⣷⣦⣄⡀⠀⠀⠀⠀⠀⠀   browser-cdp: browser_cdp, browser_dialog                                                                                                          │
│  ⠀⢀⣠⣴⣶⠿⠋⣩⡿⣿⡿⠻⣿⡇⢠⡄⢸⣿⠟⢿⣿⢿⣍⠙⠿⣶⣦⣄⡀⠀   clarify: clarify                                                                                                                                  │
│  ⠀⠀⠉⠉⠁⠶⠟⠋⠀⠉⠀⢀⣈⣁⡈⢁⣈⣁⡀⠀⠉⠀⠙⠻⠶⠈⠉⠉⠀⠀   code_execution: execute_code                                                                                                                      │
│  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⣿⡿⠛⢁⡈⠛⢿⣿⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀   computer_use: computer_use                                                                                                                        │
│  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠿⣿⣦⣤⣈⠁⢠⣴⣿⠿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀   cronjob: cronjob                                                                                                                                  │
│  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠻⢿⣿⣦⡉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀   delegation: delegate_task                                                                                                                         │
│  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢷⣦⣈⠛⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀   feishu_doc: feishu_doc_read                                                                                                                       │
│  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣴⠦⠈⠙⠿⣦⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀   (and 19 more toolsets...)                                                                                                                         │
│  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⣤⡈⠁⢤⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                                                                                                                                                     │
│  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠷⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀   Available Skills                                                                                                                                  │
│  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⠑⢶⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀   apple: apple-notes, apple-reminders, findmy, imessage,...                                                                                         │
│  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠁⢰⡆⠈⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀   autonomous-ai-agents: claude-code, codex, hermes-agent, kanban-codex-...                                                                          │
│  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠳⠈⣡⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀   creative: architecture-diagram, ascii-art, ascii-video, b...                                                                                      │
│  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀   data-science: jupyter-live-kernel                                                                                                                 │
│                                   devops: kanban-orchestrator, kanban-worker, webhook-sub...                                                                                        │
│  claude-opus-4-7 · Nous Research  email: himalaya                                                                                                                                   │
│     /Users/michael/Workspace      gaming: minecraft-modpack-server, pokemon-player                                                                                                  │
│  Session: 20260521_223629_91dd5e  general: dogfood, yuanbao                                                                                                                         │
│                                   github: codebase-inspection, github-auth, github-code-r...                                                                                        │
│                                   mcp: native-mcp                                                                                                                                   │
│                                   media: gif-search, heartmula, songsee, spotify, youtub...                                                                                         │
│                                   mlops: audiocraft-audio-generation, dspy, evaluating-l...                                                                                         │
│                                   note-taking: obsidian                                                                                                                             │
│                                   productivity: airtable, google-workspace, linear, maps, nano-...                                                                                  │
│                                   red-teaming: godmode                                                                                                                              │
│                                   research: arxiv, blogwatcher, llm-wiki, polymarket, resea...                                                                                      │
│                                   smart-home: openhue                                                                                                                               │
│                                   social-media: xurl                                                                                                                                │
│                                   software-development: debugging-hermes-tui-commands, hermes-agent-ski...                                                                          │
│                                                                                                                                                                                     │
│                                   29 tools · 89 skills · /help for commands                                                                                                         │
╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯

Welcome to Hermes Agent! Type your message or /help for commands.
✦ Tip: MCP servers send notifications/tools/list_changed to trigger automatic tool re-registration without restart.


────────────────────────────────────────
● How do I use you?
Initializing agent...

────────────────────────────────────────

╭─ ⚕ Hermes ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
    I\'ll pull up the actual Claude Code reference so I give you accurate commands rather than guessing.
╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
  ┊ ⚡ preparing mcp_skill_view…
  ┊ 📚 skill     claude-code  0.0s

╭─ ⚕ Hermes ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
    Short version: just talk to me in plain language and I\'ll do the work. I\'m an AI agent running in your terminal with access to your machine, the web, and your projects. You don\'t need special syntax — describe what you want and I handle the tools behind the scenes.

    Here\'s what I can actually do for you:

    Code & projects
      - Read, write, edit, and refactor code across all your repos in ~/Workspace
      - Run builds, tests, linters, git operations, deploys
      - I already have your CLAUDE.md context loaded, so I know your projects (boxd-card, game-finder, kotlin-tutorial, the trivia scaffolds, the homelab cluster, etc.) and their stacks/commands

    The machine & web
      - Run shell commands, manage files and processes on your Mac
      - Search the web, browse pages, extract data
      - Drive a real browser for things that need clicking/forms

    Bigger workflows
      - Spawn parallel subagents for independent tasks
      - Schedule recurring jobs (cron) — daily briefings, monitors, etc.
      - Remember durable facts about you across sessions
      - Use "skills" — pre-built playbooks for specific tools (GitHub, Discord, email, Obsidian, music gen, and a lot more)

    How to work with me effectively
      - Be direct: "fix the auth bug in game-finder" or "deploy kotlin-tutorial" or "what changed in boxd-card this week"
      - I\'ll ask before anything destructive
      - For multi-step work I\'ll keep a task list so you can see progress

    A few quick examples you could try right now:
      - "What projects do I have and which are active?"
      - "Run the tests in boxd-card"
      - "Search the web for X and summarize"
      - "Set up a daily 9am summary of my git activity"

    One clarifying thing — when you say "you," do you mean me (this agent), or are you asking specifically about the Claude Code CLI tool itself (the claude command and its flags)? I can go deep on either.
╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯

────────────────────────────────────────
● Am I talking to Hermes or to Claude or sometimes both or something else?
────────────────────────────────────────


╭─ ⚕ Hermes ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
    Good question, and the honest answer is: both, layered together. Let me break down what\'s actually happening.

    The model — that\'s Claude. Specifically the Claude model (opus-class) made by Anthropic. That\'s the actual "brain" doing the reasoning, writing, and deciding which tools to call. When you get a thoughtful answer, that\'s Claude.

    The harness — that\'s Hermes. Hermes is the agent framework wrapped around the model. It\'s what gives me hands: the terminal access, file editing, web browsing, subagents, cron jobs, memory across sessions, skills, messaging integrations. The model alone is just text-in/text-out; Hermes is what turns it into an agent that can actually do things on your Mac. (That\'s also why my tools are named things like mcp_terminal, mcp_browser, etc.)

    The persona — I\'m dressed up as "Claude Code," Anthropic\'s coding-agent CLI. That\'s a personality/role layer on top, set by a config file in your setup. It shapes my tone and focus toward coding work, but it\'s cosmetic — it doesn\'t change the underlying model or the Hermes capabilities.

    So the stack is:

      Claude (the model)  →  reasoning & language
      Hermes (the harness)  →  tools, memory, scheduling, integrations
      "Claude Code" persona  →  tone & framing

    In practice you\'re just talking to one assistant — but if you want the precise mental model: it\'s Claude\'s mind running inside Hermes\'s body, wearing a Claude Code nametag. The naming overlap is admittedly confusing because Anthropic ships a real product literally called "Claude Code," and this persona is imitating it — but the engine underneath is Hermes, not Anthropic\'s official CLI.

    Anything you want me to clarify further, or shall we get into actual work?
╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯

⚙️  /help

+-------------------------------------------------------+
|               (^_^)? Available Commands               |
+-------------------------------------------------------+

  ── Session ──
    /new            - Start a new session (fresh session ID + history) (usage: /new [name])
    /reset          - Start a new session (fresh session ID + history) (alias for /new)
    /clear          - Clear screen and start a new session
    /redraw         - Force a full UI repaint (recovers from terminal drift)
    /history        - Show conversation history
    /save           - Save the current conversation
    /retry          - Retry the last message (resend to agent)
    /undo           - Remove the last user/assistant exchange
    /title          - Set a title for the current session (usage: /title [name])
    /handoff        - Hand off this session to a messaging platform (Telegram, Discord, etc.) (usage: /handoff <platform>)
    /branch         - Branch the current session (explore a different path) (usage: /branch [name])
    /fork           - Branch the current session (explore a different path) (alias for /branch)
    /compress       - Manually compress conversation context (usage: /compress [focus topic])
    /rollback       - List or restore filesystem checkpoints (usage: /rollback [number])
    /snapshot       - Create or restore state snapshots of Hermes config/state (usage: /snapshot [create|restore <id>|prune])
    /snap           - Create or restore state snapshots of Hermes config/state (alias for /snapshot)
    /stop           - Kill all running background processes
    /background     - Run a prompt in the background (usage: /background <prompt>)
    /bg             - Run a prompt in the background (alias for /background)
    /btw            - Run a prompt in the background (alias for /background)
    /agents         - Show active agents and running tasks
    /tasks          - Show active agents and running tasks (alias for /agents)
    /queue          - Queue a prompt for the next turn (doesn\'t interrupt) (usage: /queue <prompt>)
    /q              - Queue a prompt for the next turn (doesn\'t interrupt) (alias for /queue)
    /steer          - Inject a message after the next tool call without interrupting (usage: /steer <prompt>)
    /goal           - Set a standing goal Hermes works on across turns until achieved (usage: /goal [text | pause | resume | clear | status])
    /subgoal        - Add or manage extra criteria on the active goal (usage: /subgoal [text | remove N | clear])
    /status         - Show session info
    /resume         - Resume a previously-named session (usage: /resume [name])
    /sessions       - Browse and resume previous sessions

  ── Info ──
    /whoami         - Show your slash command access (admin / user)
    /profile        - Show active profile name and home directory
    /gquota         - Show Google Gemini Code Assist quota usage
    /help           - Show available commands
    /usage          - Show token usage and rate limits for the current session
    /insights       - Show usage insights and analytics (usage: /insights [days])
    /platforms      - Show gateway/messaging platform status
    /gateway        - Show gateway/messaging platform status (alias for /platforms)
    /copy           - Copy the last assistant response to clipboard (usage: /copy [number])
    /paste          - Attach clipboard image from your clipboard
    /image          - Attach a local image file for your next prompt (usage: /image <path>)
    /update         - Update Hermes Agent to the latest version
    /debug          - Upload debug report (system info + logs) and get shareable links

  ── Configuration ──
    /config         - Show current configuration
    /model          - Switch model for this session (usage: /model [model] [--provider name] [--global])
    /provider       - Switch model for this session (alias for /model)
    /codex-runtime  - Toggle codex app-server runtime for OpenAI/Codex models (usage: /codex-runtime [auto|codex_app_server])
    /codex_runtime  - Toggle codex app-server runtime for OpenAI/Codex models (alias for /codex-runtime)
    /personality    - Set a predefined personality (usage: /personality [name])
    /statusbar      - Toggle the context/model status bar
    /sb             - Toggle the context/model status bar (alias for /statusbar)
    /verbose        - Cycle tool progress display: off -> new -> all -> verbose
    /footer         - Toggle gateway runtime-metadata footer on final replies (usage: /footer [on|off|status])
    /yolo           - Toggle YOLO mode (skip all dangerous command approvals)
    /reasoning      - Manage reasoning effort and display (usage: /reasoning [level|show|hide])
    /skin           - Show or change the display skin/theme (usage: /skin [name])
    /indicator      - Pick the TUI busy-indicator style (usage: /indicator [kaomoji|emoji|unicode|ascii])
    /voice          - Toggle voice mode (usage: /voice [on|off|tts|status])
    /busy           - Control what Enter does while Hermes is working (usage: /busy [queue|steer|interrupt|status])

  ── Tools & Skills ──
    /tools          - Manage tools: /tools [list|disable|enable] [name...] (usage: /tools [list|disable|enable] [name...])
    /toolsets       - List available toolsets
    /skills         - Search, install, inspect, or manage skills
    /bundles        - List skill bundles (aliases /<name> for multiple skills)
    /cron           - Manage scheduled tasks (usage: /cron [subcommand])
    /curator        - Background skill maintenance (status, run, pin, archive, list-archived) (usage: /curator [subcommand])
    /kanban         - Multi-profile collaboration board (tasks, links, comments) (usage: /kanban [subcommand])
    /reload         - Reload .env variables into the running session
    /reload-mcp     - Reload MCP servers from config
    /reload_mcp     - Reload MCP servers from config (alias for /reload-mcp)
    /reload-skills  - Re-scan ~/.hermes/skills/ for newly installed or removed skills
    /reload_skills  - Re-scan ~/.hermes/skills/ for newly installed or removed skills (alias for /reload-skills)
    /browser        - Connect browser tools to your live Chromium-family browser via CDP (usage: /browser [connect|disconnect|status])
    /plugins        - List installed plugins and their status

  ── Exit ──
    /quit           - Exit the CLI (use --delete to also remove session history) (usage: /quit [--delete])
    /exit           - Exit the CLI (use --delete to also remove session history) (alias for /quit)

  ⚡ Skill Commands (89 installed):
    /airtable              - Airtable REST API via curl. Records CRUD, filters, upserts.
    /apple-notes           - Manage Apple Notes via memo CLI: create, search, edit.
    /apple-reminders       - Apple Reminders via remindctl: add, list, complete.
    /architecture-diagram  - Dark-themed SVG architecture/cloud/infra diagrams as HTML.
    /arxiv                 - Search arXiv papers by keyword, author, category, or ID.
    /ascii-art             - ASCII art: pyfiglet, cowsay, boxes, image-to-ascii.
    /ascii-video           - ASCII video: convert video/audio to colored ASCII MP4/GIF.
    /audiocraft-audio-generation - AudioCraft: MusicGen text-to-music, AudioGen text-to-sound.
    /baoyu-article-illustrator - Article illustrations: type × style × palette consistency.
    /baoyu-comic           - Knowledge comics (知识漫画): educational, biography, tutorial.
    /baoyu-infographic     - Infographics: 21 layouts x 21 styles (信息图, 可视化).
    /blogwatcher           - Monitor blogs and RSS/Atom feeds via blogwatcher-cli tool.
    /claude-code           - Delegate coding to Claude Code CLI (features, PRs).
    /claude-design         - Design one-off HTML artifacts (landing, deck, prototype).
    /codebase-inspection   - Inspect codebases w/ pygount: LOC, languages, ratios.
    /codex                 - Delegate coding to OpenAI Codex CLI (features, PRs).
    /comfyui               - Generate images, video, and audio with ComfyUI — install, launch, manage nodes/models, run workflows with parameter injection. Uses the official comfy-cli
for lifecycle and direct REST/WebSocket API for execution.
    /debugging-hermes-tui-commands - Debug Hermes TUI slash commands: Python, gateway, Ink UI.
    /design-md             - Author/validate/export Google\'s DESIGN.md token spec files.
    /dogfood               - Exploratory QA of web apps: find bugs, evidence, reports.
    /dspy                  - DSPy: declarative LM programs, auto-optimize prompts, RAG.
    /evaluating-llms-harness - lm-eval-harness: benchmark LLMs (MMLU, GSM8K, etc.).
    /excalidraw            - Hand-drawn Excalidraw JSON diagrams (arch, flow, seq).
    /findmy                - Track Apple devices/AirTags via FindMy.app on macOS.
    /gif-search            - Search/download GIFs from Tenor via curl + jq.
    /github-auth           - GitHub auth setup: HTTPS tokens, SSH keys, gh CLI login.
    /github-code-review    - Review PRs: diffs, inline comments via gh or REST.
    /github-issues         - Create, triage, label, assign GitHub issues via gh or REST.
    /github-pr-workflow    - GitHub PR lifecycle: branch, commit, open, CI, merge.
    /github-repo-management - Clone/create/fork repos; manage remotes, releases.
    /godmode               - Jailbreak LLMs: Parseltongue, GODMODE, ULTRAPLINIAN.
    /google-workspace      - Gmail, Calendar, Drive, Docs, Sheets via gws CLI or Python.
    /heartmula             - HeartMuLa: Suno-like song generation from lyrics + tags.
    /hermes-agent          - Configure, extend, or contribute to Hermes Agent.
    /hermes-agent-skill-authoring - Author in-repo SKILL.md: frontmatter, validator, structure.
    /himalaya              - Himalaya CLI: IMAP/SMTP email from terminal.
    /huggingface-hub       - HuggingFace hf CLI: search/download/upload models, datasets.
    /humanizer             - Humanize text: strip AI-isms and add real voice.
    /ideation              - Generate project ideas via creative constraints.
    /imessage              - Send and receive iMessages/SMS via the imsg CLI on macOS.
    /jupyter-live-kernel   - Iterative Python via live Jupyter kernel (hamelnb).
    /kanban-codex-lane     - Use when a Hermes Kanban worker wants to run Codex CLI as an isolated implementation lane while Hermes keeps ownership of task lifecycle, reconciliation,
testing, and handoff.
    /kanban-orchestrator   - Decomposition playbook + anti-temptation rules for an orchestrator profile routing work through Kanban. The "don\'t do the work yourself" rule and the
basic lifecycle are auto-injected into every kanban worker\'s system prompt; this skill is the deeper playbook when you\'re specifically playing the orchestrator role.
    /kanban-worker         - Pitfalls, examples, and edge cases for Hermes Kanban workers. The lifecycle itself is auto-injected into every worker\'s system prompt as KANBAN_GUIDANCE
(from agent/prompt_builder.py); this skill is what you load when you want deeper detail on specific scenarios.
    /linear                - Linear: manage issues, projects, teams via GraphQL + curl.
    /llama-cpp             - llama.cpp local GGUF inference + HF Hub model discovery.
    /llm-wiki              - Karpathy\'s LLM Wiki: build/query interlinked markdown KB.
    /macos-computer-use    - Drive the macOS desktop in the background — screenshots, mouse, keyboard,
scroll, drag — without stealing the user\'s cursor, keyboard focus, or
Space. Works with any tool-capable model. Load this skill whenever the
`computer_use` tool is available.
    /manim-video           - Manim CE animations: 3Blue1Brown math/algo videos.
    /maps                  - Geocode, POIs, routes, timezones via OpenStreetMap/OSRM.
    /minecraft-modpack-server - Host modded Minecraft servers (CurseForge, Modrinth).
    /nano-pdf              - Edit PDF text/typos/titles via nano-pdf CLI (NL prompts).
    /native-mcp            - MCP client: connect servers, register tools (stdio/HTTP).
    /node-inspect-debugger - Debug Node.js via --inspect + Chrome DevTools Protocol CLI.
    /notion                - Notion API + ntn CLI: pages, databases, markdown, Workers.
    /obliteratus           - OBLITERATUS: abliterate LLM refusals (diff-in-means).
    /obsidian              - Read, search, create, and edit notes in the Obsidian vault.
    /ocr-and-documents     - Extract text from PDFs/scans (pymupdf, marker-pdf).
    /opencode              - Delegate coding to OpenCode CLI (features, PR review).
    /openhue               - Control Philips Hue lights, scenes, rooms via OpenHue CLI.
    /p5js                  - p5.js sketches: gen art, shaders, interactive, 3D.
    /pixel-art             - Pixel art w/ era palettes (NES, Game Boy, PICO-8).
    /plan                  - Plan mode: write markdown plan to .hermes/plans/, no exec.
    /pokemon-player        - Play Pokemon via headless emulator + RAM reads.
    /polymarket            - Query Polymarket: markets, prices, orderbooks, history.
    /popular-web-designs   - 54 real design systems (Stripe, Linear, Vercel) as HTML/CSS.
    /powerpoint            - Create, read, edit .pptx decks, slides, notes, templates.
    /pretext               - Use when building creative browser demos with @chenglou/pretext — DOM-free text layout for ASCII art, typographic flow around obstacles, text-as-geometry
games, kinetic typography, and text-powered generative art. Produces single-file HTML demos by default.
    /python-debugpy        - Debug Python: pdb REPL + debugpy remote (DAP).
    /requesting-code-review - Pre-commit review: security scan, quality gates, auto-fix.
    /research-paper-writing - Write ML papers for NeurIPS/ICML/ICLR: design→submit.
    /segment-anything-model - SAM: zero-shot image segmentation via points, boxes, masks.
    /serving-llms-vllm     - vLLM: high-throughput LLM serving, OpenAI API, quantization.
    /sketch                - Throwaway HTML mockups: 2-3 design variants to compare.
    /songsee               - Audio spectrograms/features (mel, chroma, MFCC) via CLI.
    /songwriting-and-ai-music - Songwriting craft and Suno AI music prompts.
    /spike                 - Throwaway experiments to validate an idea before build.
    /spotify               - Spotify: play, search, queue, manage playlists and devices.
    /subagent-driven-development - Execute plans via delegate_task subagents (2-stage review).
    /systematic-debugging  - 4-phase root cause debugging: understand bugs before fixing.
    /teams-meeting-pipeline - Operate the Teams meeting summary pipeline via Hermes CLI — summarize meetings, inspect pipeline status, replay jobs, manage Microsoft Graph
subscriptions.
    /test-driven-development - TDD: enforce RED-GREEN-REFACTOR, tests before code.
    /touchdesigner-mcp     - Control a running TouchDesigner instance via twozero MCP — create operators, set parameters, wire connections, execute Python, build real-time visuals. 36
native tools.
    /webhook-subscriptions - Webhook subscriptions: event-driven agent runs.
    /weights-and-biases    - W&B: log ML experiments, sweeps, model registry, dashboards.
    /writing-plans         - Write implementation plans: bite-sized tasks, paths, code.
    /xurl                  - X/Twitter via xurl CLI: post, search, DM, media, v2 API.
    /youtube-content       - YouTube transcripts to summaries, threads, blogs.
    /yuanbao               - Yuanbao (元宝) groups: @mention users, query info/members.

  Tip: Just type your message to chat with Hermes!
  Multi-line: Alt+Enter for a new line
  Draft editor: Ctrl+G (Alt+G in VSCode/Cursor)
  Paste image: Alt+V (or /paste)

 ⚕ claude-opus-4-7 │ 46.3K/1M │ [░░░░░░░░░░] 5% │ 7m │ ⏲ 8s
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
❯
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
```

After this, Hermes helped me diagnose the missing permissions needed to enable its Discord bot. It told me which permissions I was missing, I flipped them on, and on the next try Hermes connected — my first message from it arrived in Discord.

## Hermes's first research task

With the plumbing working, I gave Hermes something real to chew on: find research on how an AI harness actually differs from the tools sitting next to it, and survey the alternatives to itself. Everything in the next two sections is what it came back with — the harness did the research, I just spot-checked it.

### How a harness differs from neighbors

| | Has tools? | Runs a loop? | Acts autonomously? |
|---|---|---|---|
| Raw LLM API | ❌ | ❌ | ❌ |
| Chatbot wrapper | sometimes | ❌ | ❌ |
| Agent framework (LangGraph) | ✅ (you wire it) | ✅ (you build it) | depends |
| Harness (Claude Code) | ✅ built-in | ✅ built-in | ✅ |

### Alternative AI harnesses

| Harness | Interface | Open source | Model flexibility | Niche |
|---|---|---|---|---|
| Claude Code | Terminal (+IDE) | ❌ Proprietary | 🔒 Claude only | Deep autonomous multi-file work |
| OpenAI Codex CLI | Terminal | ✅ Apache-2.0 (84k★, Rust) | Mostly OpenAI | Lightweight terminal agent |
| Aider | Terminal | ✅ Apache-2.0 (45k★, Python) | 🔓 Any model | Git-native pair programming |
| Cline | IDE ext / CLI / SDK | ✅ Apache-2.0 (62k★) | 🔓 Any model | Autonomous agent in your editor |
| Cursor | Full IDE (VS Code fork) | ❌ Proprietary | 🔓 Multi-model | Best-in-class IDE UX |
| GitHub Copilot (agent mode) | IDE / CLI | ❌ Proprietary | Multi (GPT/Claude/Gemini) | Enterprise + ecosystem |
| Windsurf | Full IDE | ❌ Proprietary | 🔓 Multi-model | "Flows" / agentic IDE |
| Gemini CLI | Terminal | ✅ Open | 🔒 Gemini | Huge context, Google tie-in |
| Hermes | Messaging (Discord/Telegram/Slack…) + Terminal | ✅ MIT (163k★, Python) | 🔓 Any model (multi-provider) | Ambient always-on agent: memory, cron, subagents |

*Star counts as of May 2026.*

## Where this leaves me

So which one do I reach for? For now, both — and that's the honest answer, not a cop-out.

Claude Code is Anthropic's official agent: Claude-only, proprietary, and frighteningly good at deep, multi-file coding work. Hermes is the other shape of the same idea — a harness you can point at almost any model, wrapped in a sprawling ecosystem of skills, cron jobs, memory, and messaging integrations. The irony I keep coming back to: the Hermes I set up was running *Claude* the whole time, wearing a "Claude Code" nametag. The model was the same brain; the body around it was different.

That's the thing a harness really is, and I only understood it by setting one up and poking at it until it talked back.

Next I want to give Hermes a job that isn't just talking about itself — a real task on one of my repos, or a scheduled briefing that lands in Discord every morning — and see how it holds up against the official tooling.

If you're running a harness or agent of your own — Hermes, Aider, Cline, something you stitched together yourself — I'd genuinely like to hear what's working. Drop a comment below.
