---
layout: post
title: Relocating a Docker Container
category: infrastructure
image: "/seo/2023-12-29.png"
tags:
- guide
- docker
- raspberry-pi
redirect_from:
- /docker/2023/12/29/container-relocation.html

---

[Employing the help of ChatGPT](https://chat.openai.com/share/c944806a-de80-4384-908b-a4317108b638), I was able to successfuly relocate a Docker container from one host to another.

## Context

The container in question runs an application that uses a Docker Volume for persistent storage; this decouples the database from the application, so I really only needed to copy the volume to the new host and pull the latest application image to start the container on a new host.

## Prompt

> You are a system administrator. Your goal is to copy the volume of an existing Docker container to another host, where the app image will be pulled and the volume mounted to the new container. The old container will be stopped before copying. Write the instructions and each command with expected output. Refer to each host as node1 and node2.

## Response

To copy the volume of an existing Docker container from one host (node1) to another host (node2), you can follow these steps. I'll provide you with the necessary commands and expected outputs:

### Archive Volume On node1 (Source Host)

1. Stop the old container (if running):

```bash

docker stop <container_name_or_id>

```

#### Expected output (1)

```bash

<container_name_or_id>

```

1. Create a tarball of the Docker volume:

```bash

docker run --rm -v <volume_name>:/data -v $(pwd):/backup alpine tar czf /backup/backup.tar.gz -C /data .

```

#### Expected output (2)

```bash

backup.tar.gz

```

1. Copy the tarball to node2 (replace <node2_ip> and <path_on_node2> with the appropriate values):

```bash

scp backup.tar.gz <node2_ip>:<path_on_node2>

```

#### Expected output (3)

```bash

backup.tar.gz                                100% 1234KB  123.4KB/s   00:10

```

### Create Container On node2 (Destination Host)

1. Pull the Docker image for your application (replace <app_image> with the actual image name):

```bash

docker pull <app_image>

```

#### Expected output (4)

```bash

<app_image>:latest: Pulling from library/<app_image>
...

```

1. Load the tarball into a new Docker volume on node2:

```bash

docker run -v <volume_name>:/data -v <path_on_node2>:/backup alpine sh -c "tar xzf /backup/backup.tar.gz -C /data"

```

#### Expected output (5)

```bash

<container_id>

```

1. Run a new container with the application image and the copied volume:

```bash

docker run -d --name <new_container_name> -v <volume_name>:/path/in/container <app_image>

```

#### Expected output (6)

```bash

<new_container_id>

```

1. Verify that the new container is running:

```bash

docker ps

```

#### Expected output (7)

```bash

CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
<new_container_id>  <app_image>         "<startup_command>"     1 minute ago        Up 1 minute                             <new_container_name>

```

## Conclusion

The task I had identified was solved by ChatGPT.

I was able to relocate the data for an application because it was decoupled from the runtime in the container, demonstrating how useful Docker Volumes can be.
