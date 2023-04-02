---
layout : post
title : How I stream with OBS
image : "/seo/2023-04-02.png"
category: social
---

## What is OBS

I use OBS to stream to two different channels: my personal channel [@michaellambgelo](https://twitch.tv/michaellambgelo) and the channel I run for work, [@cspiregaming](https://twitch.tv/cspiregaming). In general, I use OBS to put together the primary view for what I want to stream to Twitch.

I use the same technologies for both channels but in different ways. For my personal channel, I'm primarily interested in interacting with the chat via microphone. With C Spire Gaming, I'm primarily interested in interacting with the chat myself via the camera and the group I have assembled. How that group is assembled is varied, and thus there are multiple implementations possible for streaming I've found. 

## Video first

For most streams, I want a camera on myself and to capture at least one game screen. I've found it wonderfully trivial to use both my personal and my work iPhone as a camera to help me compartmentalize between the two streams. The Twitch app for iPhone enables use of the front-facing camera for livestreaming with a simple interface that also displays quick stats and offers a view of the chat. For people interested in streaming using the Just Chatting cateogry, this is really all that's needed to get started building your Twitch presence.

## Audio singularly

There's always one experience I'm obsessed about: the viewers. Let's say it's a bleed over of being Customer inSPIREd.

If there's someone who's out there watching this stream, we can only hope they're listening. There's also the chance they can't hear us, so there's the question of whether finding a closed captioning solution is worthwhile or not.

I haven't found an easy solution for closed captioning on these streams that are available for public consumption. For professional work I'm able to use Microsoft Teams and its machine intelligence which takes advantage of the stream delay to parallel process the audio stream and generate live captioning.

Regardless, I have to think of the stream audio as a singular experience. For my streams at home, I include the desktop audio for whatever game I'm playing, plus a microphone I can physically mute. For C Spire Gaming streams featuring a virtual event, it's more complex. For C Spire Gaming streams that are in person, I want to be able to capture a group of people playing the same game, which is a different question with the same answer as my personal stream but which requires a different configuration: either a single microphone or an array of well-mixed microphones to capture multiple people and their crosstalk as a singular experience, as though one were in the room. I'll deal with virtual events in the next section, so in person events and personal streams are the focus here.

### iPhone as a microphone

I used the iPhone as a microphone at yesterday's C Spire Gaming Family Meetup. I streamed both the [Mario Kart 8 Deluxe tournament](https://cspiregaming.challonge.com/mk8_april2023) and our Mario-only [Super Smash Bros. Ultimate tournament](https://cspiregaming.challonge.com/smash_april2023) this way. It was great to capture the 4-5 people sitting in front of the screen as well as the general soundscape around them. Sometimes the crosstalk is intelligible but that's when the most exciting things are happening on stream, so it feels impossible to separate them without multiple cameras and a team of audio engineers working to individuate each player such that the stream is so dynamic that they could run an indivudal stream in addition to being included in another ongoing livestream. C Spire Gaming just isn't quite at that level of sophistication when it comes to our live tournaments, since the event is limited to C Spire employees and family.

### Yeti Blue microphone

I use a Yeti Blue mic for my personal streams. There is a physical mute button, which I prefer, and the quality is higher than the wireless Corsair headset I have. I've learned that using a headset for all audio out is the best when in a space that is also participating in the stream via audio, that way there is no chance of the audio doubling into the stream without the headset being deafeningly loud. I've gotten my mic configured such that it sounds good when I'm at a low volume and a high volume, should I get excited and exclaim. At least, I hope so! That's my goal, and I fully endorse my audience giving me feedback if this is offbase.

## VDO.ninja

For C Spire Gaming Officers Game Night virtual events I use a technology called [VDO.ninja](https://vdo.ninja). I can create a virtual room and invite a group of people inside. There, they're able to share their video and/or their microphone. Similar to the sentiment I share in the **Yeti Blue microphone** section, anyone joining the stream must use a headset for all audio they want to hear so as not to crowd out the stream audio with the ambient sound. I can include individuals dynamically using a link per person, though primarily I let the stream run viewing a group scene which is also a single link provided by VDO.ninja. It uses WebRTC to create peer-to-peer connections between anyone who joins the room, and it is relatively straightforward to share the desktop (and its audio, if needed) as well as any connected cameras, so joining a livestream for C Spire Gaming just requires a link and a password.

While I haven't needed to use VDO.ninja for an in-person event yet, I have found it useful for streaming to my personal channel. Because it's P2P streaming, using another machine in my house to run the stream decouples the stream processing from my gaming machine.

One drawback to VDO.ninja is that mixing audio for multiple people does not appear to be trivial, so for our purposes when streaming groups of people for C Spire Gaming everyone is muted in VDO.ninja and instead we use a Discord voice channel, which I'm then able to capture and send to the stream.

## Conclusion

OBS is a powerful tool which I use to stream for multiple channels on Twitch. The last, perhaps most important aspect of OBS is the ability to save and switch between profiles and scene collections. I consider these components of OBS tightly coupled, with many scene collections intended for one profile.
