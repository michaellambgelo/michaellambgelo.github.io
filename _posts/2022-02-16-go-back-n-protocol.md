---
layout : post
title : Go-Back-N Protocol
image : "/seo/2022-02-16.png"
category : distributed-systems
---

## An algorithm solving for a lossy network

In what was probably my favorite college course I implemented a client/server system which would transmit messages across a lossy network. A client connects to the server to send a file. By tracking packet acknowledgements from the server, the client should repeat lost packets by using a go-back- _n_ protocol where _n_ is limited to 8 packets.

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

[![client includes and namespace](/img/2022-02-16-client-includes.png)][clientLink]

Libraries included in the client provide basic i/o and networking.

`packet.h` provides a class to represent individual packets sent between the client and server. Constants are defined to represent the type of packet received; `PACKET_ACK` describes a packet from the server acknowledging receipt; `PACKET_DATA` describes a packet from the client with data; `PACKET_EOT_SERV2CLI` is a one-time packet type which tells the client to close; `PACKET_EOT_CLI2SERV` is a one-time packet type which tells the server to close because of the end of transmission.

The client uses libraries in the `std` namespace.

### `server.cpp`

[![server author comment](/img/2022-02-16-server-author.png)][serverLink]

The best resource I found for the basics of getting a server up and running was from [linuxhowtos.org](https://www.linuxhowtos.org/C_C++/socket.htm). I referenced it here because I'm a good boy who doesn't want to plagiarize. Always give credit.

[![server includes and namespace](/img/2022-02-16-server-includes.png)][serverLink]

Libraries included in the server provide basic i/o and networking.

`packet.h` provides a class to represent individual packets sent between the client and server. Constants are defined to represent the type of packet received; `PACKET_ACK` describes a packet from the server acknowledging receipt; `PACKET_DATA` describes a packet from the client with data; `PACKET_EOT_SERV2CLI` is a one-time packet type which tells the client to close; `PACKET_EOT_CLI2SERV` is a one-time packet type which tells the server to close because of the end of transmission.

The server uses libraries in the `std` namespace.

[![server randomPort function](/img/2022-02-16-server-randomPort.png)][serverLink]

`randomPort` is a function which accepts an `int` parameter and returns an `int` value. `n_port` is the port number with which a random port will communicate, so the value is required to be different from `n_port`. There is a problem with the assignment to `val` in the `while` loop: a random value is modded by 64511 which is computed first and 1024 is added to the computed remainder. When I originally wrote this I was attempting to enforce some guarantee that the random port number wouldn't use one of the commonly reserved ports (below 1024) and the thought process I had is an attempt at hashing out the logic: a random value will be some large number seeded on the system clock and so I should attempt to generate a value between the possible port numbers while accounting for the fact that ports lower than 1024 are reserved, so I should add that amount back.

The problem is that there is a chance this algorithm accidentally creates a port number outside of the acceptable range 65535. A correct implementation would have separated the conditions: once a value is assigned modded by 65535, check if the value is less than 1024. If yes, then re-roll.

Here's how I'd rewrite it now:

```c++
int randomPort(int n_port) //pick a random port
{
    int val = n_port;
    srand(time(NULL));
    while(val == n_port && val < 1024) //ensure r_ is different from n_
                                       //ensure r_ is not a reserved port
        val = rand() % 65535;

    return val;
}
```

If the return value would result in a reserved port number, the `while` loop would simply generate a new value until it finds one which satisfies the exit condition of the loop.

[![server error function](/img/2022-02-16-server-error.png)][serverLink]

The `error` method provides a convenient way to fail fast by printing out a custom error message and exiting. I've learned a lot about error handling since this program but this is still one of the most elegant pieces of code I've ever seen.

[repo]:https://github.com/michaellambgelo/DataComm/tree/master/PA2
[makefileLink]: https://github.com/michaellambgelo/DataComm/blob/master/PA2/makefile
[serverLink]: https://github.com/michaellambgelo/DataComm/blob/master/PA2/server.cpp
[clientLink]: https://github.com/michaellambgelo/DataComm/blob/master/PA2/client.cpp
