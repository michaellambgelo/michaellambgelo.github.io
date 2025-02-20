---

layout: post
title: "I built a custom Letterboxd diary viewer"
date: 2025-02-21 
category: Social
image: "/seo/2025-02-21.png"
published: true

---

I am an avid Letterboxd user and wanted to create a custom viewer for my diary entries. Since college, I've known about HTML5 UP, a website that offers free templates with beautiful, responsive designs. I decided to give it a try and see if I could create a viewer with it.

## HTML5 UP Template

Here's what the template looks like. It's named [Multiverse](https://html5up.net/multiverse).

![Multiverse](/img/multiverse-capture.png)

## Letterboxd Viewer

And here's how the viewer turned out.

![Viewer](/img/letterboxd-viewer-capture.png)

## Contact form

The template features an About section which contains a contact form. For simplicity and ease of use, I opted to publish new submissions to a Discord webhook in a private channel on my server. The form submits to an AJAX call which formats the message and sends it to the webhook. The webhook then posts the message to the channel.

![Webhook](/img/letterboxd-viewer-webhook.png)

## Architecture

![Architecture](/img/letterboxd-viewer-architecture.png)

## Links

Check out the repo [here](https://github.com/michaellambgelo/letterboxd-viewer) and feel free to fork and modify it to your needs. The README should have all the information you need to get started if you know how to poke around some code.

### [Open the Letterboxd Diary Viewer now](https://michaellambgelo.github.io/letterboxd-viewer/)
