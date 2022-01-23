---
layout : post
title : Using VB-Audio tools to share audio via Discord
image : "/seo/2022-01-15.png"
category : social
---

## Problem

Discord is useful for text and voice chat and sharing a screen is trivially simple. Despite these incredibly powerful features, it is less intuitive to share audio from your computer to a Discord channel. Enter, VB-Audio.

This blog post is based on setting up VoiceMeeter Banana on Windows 10 but the software is also supported on Mac OS devices.

## VB-CABLE Virtual Audio Device

The first step for getting audio from desktop applications to Discord is to send the audio to an application we can control. VB-Audio software provides a virtual cable driver. The driver creates a single virtual input and a single virtual output. This enables Windows to pipe audio output to a virtual input. On my computer, this is named VoiceMeeter Input.

![In the operating system sound settings, select VoiceMeeter Input as the audio output for all desktop audio.](/img/sound-settings.png)

[Download and install the Virtual Audio Cable from VB-Audio.](https://vb-audio.com/Cable/index.htm)

## VB-Audio VoiceMeeter Banana

VoiceMeeter Banana is a virtual audio mixer. It will allow us to control physical and virtual I/O. In addition to sending audio to Discord this application is useful for streaming or creating networked audio systems.

![VoiceMeeter Banana displays audio inputs into the mixer and can be configured to go to any output using the A/B toggles](/img/voicemeeter-config.png)

I have configured Discord to use the virtual cable input as its audio output so that I can control the audio from other speakers in Banana. This audio is sent to my headphones (A1) but if I were to take my headphones off then I would also send it to my desktop speakers (A2).

My headset microphone is configured in input 2 and sent to the virtual output called VoiceMeeter VAIO. This is how I am able to send desktop audio to Discord: it takes the same route as my microphone audio. There is an additional virtual output called VoiceMeeter AUX VAIO, which is useful if configuring an additional output like another pair of monitor headphones.

[Download and install VoiceMeeter Banana virtual audio mixer from VB-Audio.](https://vb-audio.com/Voicemeeter/banana.htm)

## Join the Discord

I am in a number of servers but the impetus for setting up a virtual mixer came from my desire to host a watch party in a server I set up for `jxnfilm.club`.

Join the discord here: [discord.jxnfilm.club](https://discord.jxnfilm.club)
