---
layout: post
title: "My experience with the Intelligence we have given machines"
date: 2025-01-09
category: machine-intelligence
image: "/seo/2025-01-09.png"
---

I have not posted a blog update since March when I announced that I had purchased an M3 MacBook Air. 
My curiosity with local LLMs was relatively short-lived, mostly because my life is already a lot of tinkering and the true value in running a local LLM is to customize it to do what you want — but I don't always know what I want.

## Local LLMs

I played around with a few different LLMs using Ollama. 
Ollama provides a CLI tool for managing models and serving them locally.
Most 7B models work well on my M3, but higher parameter models were too slow.
Still, the only real benefit was that I could run a local model and use it to generate text, it just wasn't very good or useful text.

I installed [Ollama Autocoder][autocoder] to interact with local models within VS Code.
Though this provided a neat autocomplete feature, most of the suggestions were poor.

## ChatGPT

My experience with ChatGPT has been mixed at best. 
It does okay with some generations but more often than not it is less than helpful in any coding problems. 
I have found some success in using ChatGPT to generate the incorrect answers in a trivia game, but mostly it has become a spellcheck and sentiment analysis tool for my correspondence.

## Codeium

When C Spire began exploring AI tools, leadership decided to run a pilot program. 
Three groups of developers were assigned to the pilot: one was the control group, the others were split between GitHub Copilot and Codeium. 

When Codeium received the best marks among developers, the rest of the development teams adopted the tool.
I have had the fortunate position to speak with developers both freshman and senior and glean from them the value they find in generative AI.
Junior developers are more enthusiastic about the tool as it provides feedback for them to iterate on their problems independently — a goal which always seems to be front of mind for junior devs as they perceive their senior team members' time as more valuable.
Senior developers either use the tool with specific use cases or they don't use it at all. 

In my own development work with C Spire I have used Codeium, the biggest help to me being frontend tasks which require more layout or lots of file touches. 
Some of our older frontend apps are large and unwieldy but Codeium has resulted in fewer headaches for me when making changes in those apps. 
The newer apps (in frameworks like Angular) are much more pleasant for me to work in, and even better to do work with Codeium. 

## Windsurf and Cascade

In my personal capacity as a software engineer, I've recently adopted Windsurf and Cascade and found a lot of joy in accomplishing things quickly.
The motivating reason for trying out Windsurf was to create a custom stream overlay for my Twitch channel. 
I wanted something that would make my stream look professional and Cascade helped deliver that for me.

Windsurf is the IDE created by Codeium to work with their AI models.
Cascade is the agentic AI model built into Windsurf.
One important difference I've noted is that Cascade does more than simply respond to a prompt — it thinks ahead and plans accordingly.

I've employed Cascade to analyze and refactor aspects of this very blog site (most changes are under-the-hood). 

## What's next?

I have a few ideas for things I'd like to create but haven't had the time, motivation, or resources to accomplish. With Cascade at my fingertips, I'm eager to build something new.

[autocoder]:https://github.com/ollama/ollama-autocoder
