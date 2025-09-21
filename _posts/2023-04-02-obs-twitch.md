---
layout : post
title : How I stream with OBS

image : "/seo/2023-04-02.png"

category: community
tags:
- streaming
- twitch
- tutorial
- technology

redirect_from:
- /social/2023/04/02/obs-twitch.html

---

## What is OBS

OBS (Open Broadcaster Software) is an open-source video capture and streaming application. Plugins are available to extend functionality and add helpful features, such as Twitch integration to view chat and live streaming stats. OBS is also capable of recording, which is helpful for people interested in sharing content like code reviews .

I use OBS to stream to two different channels: my personal channel [@michaellambgelo](https://twitch.tv/michaellambgelo) and the channel I run for work, [@cspiregaming](https://twitch.tv/cspiregaming). In general, I use OBS to put together the primary view for what I want to stream to Twitch.

I use the same technologies for both channels but in different ways. For my personal channel, I'm primarily interested in interacting with chat via microphone. With C Spire Gaming, I focus on interacting with chat through both camera and the assembled group. Since group composition varies, I've discovered multiple streaming implementations are possible.

## Video first

For most streams, I want a camera on myself and to capture at least one game screen. I've found it wonderfully trivial to use both my personal and my work iPhone as a camera to help me compartmentalize between the two streams. Using the continuity camera feature within OBS is intuitive since my phones appear in OBS on Mac OS as a Video Capture Device.

Desktop capture of my gaming PC or some other content can take place in many ways. One method is to use a capture card: a video interface capable of copying a video feed, which typically passes through an HDMI signal while capturing it. The interface can be added directly to OBS and formatted with any other elements as desired. Other, more complex methods include using virtual cameras in OBS and VDO.ninja. VDO.ninja will be discussed in a separate section below.

## Audio as a singular experience

There's always one experience I'm focused on: the viewers. This attention to viewer experience stems from my customer-focused mindset.

If there's someone who's out there watching the stream we are producing right now, we can only hope they're listening. There's also the chance they can't hear us, which begs the question of whether we can find a closed captioning solution.

I haven't found an easy solution for closed captioning on these streams that are available for public consumption. For professional work I'm able to use Microsoft Teams and its machine intelligence which takes advantage of the stream delay to parallel process the audio stream and generate live captioning that works well about 75% of the time.

Regardless, I have to think of the stream audio as a singular experience. For my streams at home, I include the desktop audio for whatever game I'm playing, plus a microphone I can physically mute. For C Spire Gaming streams featuring a virtual event, it's more complex. For C Spire Gaming streams that are in person, I want to be able to capture a group of people playing the same game, which is a different question with the same answer as my personal stream but which requires a different configuration: either a single microphone or an array of well-mixed microphones to capture multiple people and their crosstalk as a singular experience, as though one were in the room. I'll deal with virtual events in the next section, so in person events and personal streams are the focus here.

### iPhone as a microphone

I used the iPhone as a microphone at yesterday's C Spire Gaming Family Meetup. I streamed both the Mario Kart 8 Deluxe tournament ([Twitch VOD link](https://www.twitch.tv/videos/1781920061), [Challonge link](https://cspiregaming.challonge.com/mk8_april2023)) and our Mario-only Super Smash Bros. Ultimate tournament ([Twitch VOD link](https://www.twitch.tv/videos/1781920061), [Challonge link](https://cspiregaming.challonge.com/smash_april2023)) this way. It was great to capture the 4-5 people sitting in front of the screen as well as the general soundscape around them. Sometimes the crosstalk isn't intelligible, but that's when the most exciting things are happening on stream. It would be nearly impossible to separate individual voices without multiple cameras and a team of audio engineers working to isolate each player for individual streams while maintaining the group dynamic. C Spire Gaming isn't quite at that level of sophistication for our live tournaments, but maybe one day we'll have something that can scale to that level.

### Blue Yeti microphone

I use a Blue Yeti mic for my personal streams. There is a physical mute button, which I prefer, and the quality is higher than the wireless Corsair headset I have. I've learned that using a headset for all audio output is best when in a space that's also participating in the stream via audio. This way, there's no chance of audio feedback looping into the stream without the headset being deafeningly loud. I've gotten my mic configured such that it sounds good when I'm at a low volume and a high volume, should I get excited and exclaim. At least, I hope so! That's my goal, and I fully endorse my audience giving me feedback if this is offbase.

## VDO.ninja

For C Spire Gaming Community Game Nights I use a technology called [VDO.ninja](https://vdo.ninja). I can create a virtual room and invite a group of people inside. There, they're able to share their video and/or their microphone and camera. Similar to the sentiment I share in the **Blue Yeti microphone** section, anyone joining the stream must use a headset for all audio they want to hear so as not to crowd out the stream audio with ambient sound. I can include individuals dynamically using a link per person, though primarily I let the stream run viewing a group scene which is also a single link generated by VDO.ninja and imported into OBS as a browser source. VDO.ninja uses WebRTC to create peer-to-peer connections between anyone who joins the room, and it is relatively straightforward to share the desktop (and capture system audio, if needed) as well as any connected cameras, so joining a livestream for C Spire Gaming just requires a link and a password.

While I haven't needed to use VDO.ninja for an in-person event yet, I have found it useful for streaming to my personal channel. Because it's P2P streaming, using another machine in my house to run the stream decouples the stream processing from my gaming machine.

One drawback to VDO.ninja is that mixing audio for multiple people does not appear to be trivial, so for our purposes when streaming groups of people for C Spire Gaming everyone is muted in VDO.ninja and instead we use a Discord voice channel, which I'm then able to capture and send to the stream.

## Conclusion

OBS is a powerful tool which I use to stream for multiple channels on Twitch. The last, perhaps most important aspect of OBS is the ability to save and switch between profiles and scene collections. I consider these components of OBS tightly coupled, with many scene collections intended for one profile.
