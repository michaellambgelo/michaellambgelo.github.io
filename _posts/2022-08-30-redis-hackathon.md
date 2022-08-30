---
layout : post
title : Redis Hackathon Submission
image : "/seo/2022-08-30.png"
category : distributed systems
---

I participated in a Redis Hackathon hosted on [Dev.to][dev.to] which required use of the Redis Stack. Anyone familiar with Redis knows it for its primary use case as a cache, with popular adoption as a primary database because of its ease-of-use and high developer happiness as part of the ecosystem's DX metric.

The hackathon started at the beginning of August but I started late and had to balance free time against work time. The submission deadline was August 29 at 7 PM. Though I didn't have a finalized submission, just for participating I've gotten a $500 credit for Redis Stack!

## Redis Stack

The Redis Stack is a distributed system! Redis has multiple projects, meaning multiple parts of these applications can run in a distributed system to provide a single endpoint for a full-featured cache. _Redis_ means **Re**mote **Di**ctionary **s**erver, which is what they call the initial `redis` app which is historically compared to `memcached`.

[Redis Stack][redis-stack] is made up of several components, licensed as follows:

Redis Stack Server, which combines open source Redis with RediSearch, RedisJSON, RedisGraph, RedisTimeSeries, and RedisBloom, is licensed under the Redis Source Available License (RSAL).

RedisInsight is licensed under the Server Side Public License (SSPL).

Using these combined systems, I made a microservice app which enabled me to create an endpoint to easily store some data for the michaellamb.dev Discord bot. The project I came up with involved integrating Midjourney image generation and a frontend.

## The progress I did make

The following sections will be dated entries with commits SHAs and descriptions of the changes.

## August 17

1 commit

- [a013eaac3177db02ccb9918f27d5e01d1016f3d0][a013eaac3177db02ccb9918f27d5e01d1016f3d0]
**message**: initial commit

This is just the basic initialization of the app. It builds and runs. Swagger is available.

## August 20

1 commit

- [b396c77de5e795e8074d7fd50b5c8bfd294d6cab][b396c77de5e795e8074d7fd50b5c8bfd294d6cab]

**message**: creates example People repository

I'm following along with the [Stack Spring tutorial][stack-spring-tutorial] here to implement some basic functionality. This includes using the [skeleton app repo][skeleton-app] as a reference.

Progress here includes connecting to the Redis Stack. Of course, the password has been changed since this is open source. A future commit will rename the `application.properties` file to indicate it is an example only, after another commit which adds an entry for `application.properties` in `.gitignore`.

## August 22

3 commits

- [fc68711d291160dac4dd39f3c285afaa8fdf0387][fc68711d291160dac4dd39f3c285afaa8fdf0387]

**message**: ignore application.properties

- [6de183fb46e2990f275eaea32879039c9e95d2cc][6de183fb46e2990f275eaea32879039c9e95d2cc]

**message**: Update .gitignore

- [c134d264139e4020173529890ec2babfb210d75b][c134d264139e4020173529890ec2babfb210d75b]

**message**: Rename application.properties to last-application.properties

This does the things I said in the last description.

## August 23

- [fae387b0f6a166aacd3e9bb829c120de4add3c01][fae387b0f6a166aacd3e9bb829c120de4add3c01]

**message**: migrate to springdoc

Springfox doesn't support something in Spring 2.7.0 so I migrated the project to [Springdoc][springdoc].

- [12f46bc6f9919da4f10b7543e19c1ede0253a270][12f46bc6f9919da4f10b7543e19c1ede0253a270]

**message**: replaced import

Fixed an erroneous import in the `Person` domain class.

- [a8a39c4d5c56c4cae7b8bfe53ca66e556933707d][a8a39c4d5c56c4cae7b8bfe53ca66e556933707d]

**message**: implement RedisDocumentRepository operations

This adds functionality around the Person objects using [RedisDocumentRepository][skeleton-app#repository] to generate boilerplate code. We can easily return an `Iterable<Person>` with whatever data points we can imagine because of the power of Redis. The OM library gives us the ability to stub basic methods. We can use these to query Redis for data.

- [fc69956ea1863d87069c9a106cb834c335a8aaba][fc69956ea1863d87069c9a106cb834c335a8aaba]

**message**: add controller operations

This exposes the functionality of the PeopleRepository as an API.

## August 24

- [0ae2657d51e8a8e1cb1e50eb38f7b3c32ad04a07][0ae2657d51e8a8e1cb1e50eb38f7b3c32ad04a07]
- [e9cfbb73508d43b399018c22a22c33a462e0e298][e9cfbb73508d43b399018c22a22c33a462e0e298]

**message**: refactor Person

These chisel down some of the fields on the `Person` class

- [25f2c603027790293b238d6c875aa19baeb247dc][25f2c603027790293b238d6c875aa19baeb247dc]

**message**: remove loadTestData CommandLineRunner

This is tutorial code and should be removed before further development.

- [4469131638057b4fbc8f4b57e832b47cf07b6920][4469131638057b4fbc8f4b57e832b47cf07b6920]

**message**: fix build

I'm not perfect.

## Reflection

I got a good deal of exposure to Redis OM Spring and more experience with RedisInight, the GUI used to inspect Redis databases. I ran into issues with the meta-model generation, I'm not sure if that was because VS Code doesn't know about meta-modeling or if I was missing a Maven compilation step. Overall, Redis OM Spring seems like it's headed in a good direction!

My code is not production ready but it's progress.

<!-- docs -->
[dev.to]:https://dev.to
[skeleton-app]:https://github.com/redis-developer/redis-om-spring-skeleton-app
[skeleton-app#repository]:https://github.com/redis-developer/redis-om-spring-skeleton-app#-the-repository
[redis-stack]:https://redis.io/docs/stack/
[stack-spring-tutorial]:https://redis.io/docs/stack/get-started/tutorials/stack-spring/
[springdoc]:https://springdoc.org/migrating-from-springfox.html
<!-- commit shas -->
<!-- 8/17 -->
[a013eaac3177db02ccb9918f27d5e01d1016f3d0]:https://github.com/michaellambgelo/stackathon/commit/a013eaac3177db02ccb9918f27d5e01d1016f3d0
<!-- 8/20 -->
[b396c77de5e795e8074d7fd50b5c8bfd294d6cab]:https://github.com/michaellambgelo/stackathon/commit/b396c77de5e795e8074d7fd50b5c8bfd294d6cab
<!-- 8/22 -->
[fc68711d291160dac4dd39f3c285afaa8fdf0387]:https://github.com/michaellambgelo/stackathon/commit/fc68711d291160dac4dd39f3c285afaa8fdf0387
[6de183fb46e2990f275eaea32879039c9e95d2cc]:https://github.com/michaellambgelo/stackathon/commit/6de183fb46e2990f275eaea32879039c9e95d2cc
[c134d264139e4020173529890ec2babfb210d75b]:https://github.com/michaellambgelo/stackathon/commit/c134d264139e4020173529890ec2babfb210d75b
<!-- 8/23 -->
[fae387b0f6a166aacd3e9bb829c120de4add3c01]:https://github.com/michaellambgelo/stackathon/commit/fae387b0f6a166aacd3e9bb829c120de4add3c01
[12f46bc6f9919da4f10b7543e19c1ede0253a270]:https://github.com/michaellambgelo/stackathon/commit/12f46bc6f9919da4f10b7543e19c1ede0253a270
[a8a39c4d5c56c4cae7b8bfe53ca66e556933707d]:https://github.com/michaellambgelo/stackathon/commit/a8a39c4d5c56c4cae7b8bfe53ca66e556933707d
[fc69956ea1863d87069c9a106cb834c335a8aaba]:https://github.com/michaellambgelo/stackathon/commit/fc69956ea1863d87069c9a106cb834c335a8aaba
<!-- 8/24 -->
[0ae2657d51e8a8e1cb1e50eb38f7b3c32ad04a07]:https://github.com/michaellambgelo/stackathon/commit/0ae2657d51e8a8e1cb1e50eb38f7b3c32ad04a07
[e9cfbb73508d43b399018c22a22c33a462e0e298]:https://github.com/michaellambgelo/stackathon/commit/e9cfbb73508d43b399018c22a22c33a462e0e298
[25f2c603027790293b238d6c875aa19baeb247dc]:https://github.com/michaellambgelo/stackathon/commit/25f2c603027790293b238d6c875aa19baeb247dc
[4469131638057b4fbc8f4b57e832b47cf07b6920]:https://github.com/michaellambgelo/stackathon/commit/4469131638057b4fbc8f4b57e832b47cf07b6920