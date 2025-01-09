---

layout : post
title : An overview of LinkStack
category : social

image : "/seo/2023-06-07.png"
---

## My Self-hosted Link Sharing Hub

I use LinkStack as an app at [link.michaellamb.dev][linkstack-app] and have added it to my social media pages as a link dashboard. I often share the link to the app with new contacts to give them all the options to connect with me. There are even a few other users on my LinkStack with their own pages as the app has an admin feature and a registration toggle (disabled by default). My instance of LinkStack is running in the Raspberry Pi cluster<sup>[1][1]</sup> I have documented in the past<sup>[2][2]</sup>.

[LinkStack][linkstack] is an open source project which solves link sharing and management of shared links. It offers a customizable page like Linktree, but with so much more opportunity and freedom -- as long as you're comfortable starting a Docker container!

I trust the project's [documentation on GitHub][linkstack-repo] and recommend using that to determine how you might want to add this free and available resource to your web properties.

## LinkStack vs. Linktree

### Features

Linktree is a very quick and simple solution for creating a list of links with customizable buttons, colors, and backgrounds but its features are limited. Linktree intentionally limits these features to ensure only the most user-friendly experience is possible on their platform. When compared to LinkStack, Linktree has no feature that comes close to the Themes offered by default with new instances of a LinkStack app. Custom Themes in LinkStack gives users the ability to design their page exactly how they like it.

### Hosting

LinkStack offers a robust platform with the option to host yourself or host on their servers. Self-hosting a LinkStack app is straightforward and can happen in a few clicks. LinkStack's inspiration is to empower data ownership among individuals and groups who need a reliable and autonomous solution for sharing links. Alternatively, you may find using a hosted instance might be right for you. The LinkStack org provides low-cost hosting in addition to their community instance program which anyone can use for free.

Linktree isn't a project, it's a product. Their pricing model is a higher premium than LinkStack's.

### Support

Because it is an open source project, LinkStack offers community support on [Mastodon][linkstack-mastodon] and [Discord][linkstack-discord].

## Developer Contribution Guide

LinkStack is written in PHP with the Laravel framework. Developers may contribute bug reports, code discussions, code fixes, and new features. The [Discord server][linkstack-discord] is where communication around this work takes place. The maintainers use [GitHub Flow][ghflow] as an integration strategy.

![linkstack animated logo](https://raw.githubusercontent.com/LinkStackOrg/branding/main/logo/svg/logo_animated.svg)

[1]:<<<<<<<<https://michaellamb.dev/cluster-computing/2021/03/25/cluster-computing.html>>>>>>>>
[2]:<<<<<<<<https://michaellamb.dev/cluster-computing/2021/03/26/cluster-update.html>>>>>>>>
[linkstack-app]:<<<<<<<<https://link.michaellamb.dev>>>>>>>>
[linkstack]:<<<<<<<<https://linkstack.org/>>>>>>>>
[linkstack-repo]:<<<<<<<<https://github.com/LinkStackOrg/LinkStack>>>>>>>>
[linkstack-discord]:<<<<<<<<https://discord.com/invite/MwEYK73erE/>>>>>>>>
[linkstack-mastodon]:<<<<<<<<https://mstdn.social/@linkstack>>>>>>>>
[ghflow]:<<<<<<<<https://docs.github.com/en/get-started/quickstart/github-flow>>>>>>>>
