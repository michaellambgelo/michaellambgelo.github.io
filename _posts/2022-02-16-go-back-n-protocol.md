---
layout : post
title : Go-Back-N Protocol
image : "/seo/2022-02-16.png"
category : distributed-systems
---

## An algorithm solving for a lossy network

In what was probably my favorite college course I implemented a client/server system which would transmit messages across a lossy network. A client connects to the server to send a file. By tracking packet acknowledgements from the server, the client should repeat lost packets by using a go-back-_n_ protocol where _n_ is limited to 8 packets.

This was one of three programming assignments for a class called Data Communication Networks. I took this in the spring semester of 2016. My professor was Dr. Maxwell Young. In this post, I'll give an overview of [my archived repo available on GitHub][repo]. This assignment was foundational to my understanding of distributed systems. Using an emulator program to simulate a lossy network, I learned the importance of writing resilient code.

Usually, servers are programs that run as services on an operating system for high availability to accept clients. Because this particular client/server implementation was for a class assignment I opted to close my server once the program requirements are satisfied. Obviously this wasn't built for any sort of production use and is provided only as educational material.

## Files

### `makefile`

[![makefile](/img/2022-02-16-makefile.png)][makefileLink]

I was constantly rebuilding the entire distributed system and running it locally on my machine. My makefile here creates the necessary executable files from source in order: first create the `packet.o` executable, then use `packet.o` to build the client and server executables. Running `make main` accomplishes all of this. Because the client and server are tiny the build process executed in less than a second which made the feedback loop very quick when I was writing this.

Running `make zip` was a requirement from the assignment and so I included it here to make a zip file called `pa2.zip` including the specified source files.

`make clean` deletes all executables in the directory

### `client.cpp`

[![client author comment](/img/2022-02-16-client-author.png)][clientLink]

Shout out to Hannah Thiessen (referenced here by her former name, Hannah Church) who helped write the client implementation of go-back-_n_. We spent a long, long Saturday in Butler Hall working on just that portion alone. JJ Kemp observed our work, as was his way.

### `server.cpp`

[![server author comment](/img/2022-02-16-server-author.png)][serverLink]

The best resource I found for the basics of getting a server up and running was from [linuxhowtos.org](https://www.linuxhowtos.org/C_C++/socket.htm). I referenced it here because I'm a good boy who doesn't want to plagiarize. Always give credit.

[repo]:https://github.com/michaellambgelo/DataComm/tree/master/PA2
[makefileLink]: https://github.com/michaellambgelo/DataComm/blob/master/PA2/makefile
[serverLink]: https://github.com/michaellambgelo/DataComm/blob/master/PA2/server.cpp
[clientLink]: https://github.com/michaellambgelo/DataComm/blob/master/PA2/client.cpp