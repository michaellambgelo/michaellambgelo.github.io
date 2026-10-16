---
layout: post
title: "Embed Builder Available for All Servers"
image: "/seo/2026-10-15-embed-builder-available-for-all-servers.png"
category: software
tags:
- discord
- javascript
- cloudflare
- claude-code
---

## The bot is verified

Discord has verified the Embed Builder app. The bot behind [embed-builder.michaellamb.dev](https://embed-builder.michaellamb.dev) can now be added to any Discord server, not just a short list of servers I know about.

That sounds like a formality, and mostly it is. It also removes a hard ceiling. Discord does not let an unverified app join more than 100 servers. Before verification, every server that added the bot used up one of those slots. Now there is no limit, so if you were waiting to see whether this thing would stick around, this is your sign.

I wrote [a full build log of the app]({% post_url 2026-09-21-discord-embed-builder %}) last month. This post is the short version: what changed, and how to put the bot in your server.

## What verification actually covered

Verification is Discord checking who runs an app and what it does with your server's data. For this app, that came down to two privileged intents. Discord approved both of them.

**Message Content** is the one that matters to you. Channel watchers read the messages in your channels and repost the ones that match your query, so the bot has to see what those messages say. An app in fewer than 100 servers can switch that permission on for itself. Past 100 servers, Discord has to approve it. Without approval, the bot would receive every message with the text blanked out and the watchers would match nothing. With approval, watchers work the same in every server.

**Server Members** lets the bot read a server's member list. I only use it for a member list I show on my own blog, and only for servers I have opted in by ID. Adding the bot to your server does not publish your members anywhere.

## You still don't need the bot for most of it

The editor, the live preview, JSON export and sending through a webhook all work without logging in and without the bot. If you paste a webhook URL and send one announcement, you never need anything in this post.

RSS subscriptions and scheduled messages need a Discord login, but they post through webhooks, so they don't need the bot either.

The bot is for the features that need to see inside your server:

- **Channel watchers**, which poll your channels and repost messages that match a query
- **Creating webhooks from inside the app**, so you don't have to dig through channel settings to copy a URL
- **Slash commands**: `/help`, `/link`, `/rss list`, `/channels list`, `/scheduled list` and `/scheduled cancel`

## How to add it to your server

The quickest way is the install link: **[add Embed Builder to your server](https://discord.com/oauth2/authorize?client_id=967558945512230954)**. Discord asks which server you want, and that's the whole process.

You can also add it from inside the app, which helps when you're already there setting up a watcher:

1. Go to [embed-builder.michaellamb.dev](https://embed-builder.michaellamb.dev) and log in with Discord.
2. Open the channel picker. Any server the bot isn't in yet shows **The bot isn't in this server yet** and an **Add Bot to Server** button.
3. Click it. Discord's authorization screen opens with that server already selected.
4. Approve it, go back to the app, and click **I've added it**. Your channels load.

Discord requires the Manage Server permission to add any bot, so you need to be an admin or a moderator with that permission. Making a watcher in the app requires Manage Server too.

Either way, the bot asks for two permissions: **View Channels** and **Manage Webhooks**. That's all the watchers and webhook creation need. It doesn't ask for Send Messages, because the bot never posts as itself. Everything the app sends goes through a webhook, so it shows up in your channel under your embed's name and avatar, not mine.

## Come say hi

If you add it to your server, I'd like to hear what you use it for. Check out my [Discord server members](https://blog.michaellamb.dev/members) and find the link to join. If something breaks, the feedback form in the last tab of the in-app guide sends straight to a channel I read, and you don't have to log in to use it.
