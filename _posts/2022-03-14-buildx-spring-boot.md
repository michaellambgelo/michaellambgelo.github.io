---
layout : post
title : Docker Buildx and Platform-specific Images
image : "/seo/2022-03-14.png"
category : docker
---

## Problem

I am playing around with a new build pipeline. I want to be able to create Spring Boot applications and build Docker images that can run on a Raspberry Pi computer. Because the Pi uses an ARM processor the image build step is more involved. In this post, I will outline how I built an ARM-specific image from my [Spring Boot demo codebase][gh-demo].

## Required

- Java 8
- Maven (mvnw packaged with repo)
- Docker

## Build Steps

### Maven

First, we use Maven to compile the Java code into a JAR. This can be accomplished from the commandline.

```bash
mvnw spring-boot:build-image
```

Successful build console output:

```log
[INFO] Scanning for projects...
[INFO] 
[INFO] --------------------------< dev.michael:demo >--------------------------
[INFO] Building demo 0.0.1
[INFO] --------------------------------[ jar ]---------------------------------
[INFO] 
[INFO] >>> spring-boot-maven-plugin:2.6.3:build-image (default-cli) > package @ demo >>>
[INFO] 
[INFO] --- maven-resources-plugin:3.2.0:resources (default-resources) @ demo ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] Using 'UTF-8' encoding to copy filtered properties files.
[INFO] Copying 1 resource
[INFO] Copying 0 resource
[INFO]
[INFO] --- maven-compiler-plugin:3.8.1:compile (default-compile) @ demo ---
[INFO] Changes detected - recompiling the module!
[INFO] Compiling 5 source files to C:\Workspace\demo\demo\target\classes
[INFO] 
[INFO] --- maven-resources-plugin:3.2.0:testResources (default-testResources) @ demo ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] Using 'UTF-8' encoding to copy filtered properties files.
[INFO] skip non existing resourceDirectory C:\Workspace\demo\demo\src\test\resources
[INFO]
[INFO] --- maven-compiler-plugin:3.8.1:testCompile (default-testCompile) @ demo ---
[INFO] Changes detected - recompiling the module!
[INFO] Compiling 1 source file to C:\Workspace\demo\demo\target\test-classes
[INFO] 
[INFO] --- maven-surefire-plugin:2.22.2:test (default-test) @ demo ---
[INFO] 
[INFO] -------------------------------------------------------
[INFO]  T E S T S
[INFO] -------------------------------------------------------
[INFO] Running dev.michael.demo.DemoApplicationTests
... (tests omitted)
[INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 5.863 s - in dev.michael.demo.DemoApplicationTests
[INFO] 
[INFO] Results:
[INFO]
[INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0
[INFO]
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  01:23 min
[INFO] Finished at: 2022-03-11T22:08:02-06:00
[INFO] ------------------------------------------------------------------------
```

### Docker

Docker users may be familiar with the `docker build` command. `buildx` is "`build` extended" which is an experimental CLI command to enable the creation of platform-specific Docker images. Here's the command I used to generate one for the 32-bit OS running on my Pis.

```bash
docker buildx build --push --platform=linux/arm/v7 --tag=michaellambgelo/demo:latest .  
```

The output shows Docker using Buildkit. The dockerfile lets Docker know how to package and start an application container. With `openjdk:8-jdk-alpine` included as the container OS runtime the Spring Boot application is then pushed to the Docker registry. From the registry, the image can be downloaded to whatever Pi/Docker configuration I want.

```bash
[+] Building 38.7s (11/11) FINISHED
 => [internal] booting buildkit                                                                                                                                                                                         1.5s 
 => => starting container buildx_buildkit_magical_thompson0                                                                                                                                                             1.5s 
 => [internal] load build definition from Dockerfile                                                                                                                                                                    0.1s 
 => => transferring dockerfile: 141B                                                                                                                                                                                    0.0s 
 => [internal] load .dockerignore                                                                                                                                                                                       0.1s 
 => => transferring context: 2B                                                                                                                                                                                         0.0s 
 => [internal] load metadata for docker.io/library/openjdk:8-jdk-alpine                                                                                                                                                 3.1s 
 => [auth] library/openjdk:pull token for registry-1.docker.io                                                                                                                                                          0.0s 
 => [internal] load build context                                                                                                                                                                                       0.8s 
 => => transferring context: 30.75MB                                                                                                                                                                                    0.7s 
 => [1/2] FROM docker.io/library/openjdk:8-jdk-alpine@sha256:94792824df2df33402f201713f932b58cb9de94a0cd524164a0f2283343547b3                                                                                           7.1s 
 => => resolve docker.io/library/openjdk:8-jdk-alpine@sha256:94792824df2df33402f201713f932b58cb9de94a0cd524164a0f2283343547b3                                                                                           0.1s 
 => => sha256:43ff02e0daa55f3a4df7eab4f7128e6b39b03ece75dfeedb53bf646fce03529c 67.40MB / 67.40MB                                                                                                                        6.4s 
 => => sha256:962e53e3f8337e63290eb26703e31f0e87d70db371afae581ad3898b1dccb972 238B / 238B                                                                                                                              0.1s 
 => => sha256:856f4240f8dba160c5323506c1e9a4dbaaca840bf1b0c244af3b8d1b42b0f43b 2.35MB / 2.35MB                                                                                                                          0.9s 
 => => pushing layers                                                                                                                                                                                                  22.4s
 => => pushing manifest for docker.io/michaellambgelo/demo:latest@sha256:87640f491f579237e378aa832614df036720da21ed0d74cbe248ba1ed6ae4acb                                                                               0.3s
 => [auth] michaellambgelo/demo:pull,push token for registry-1.docker.io                                                                                                                                                0.0s
 => [auth] michaellambgelo/demo:pull,push token for registry-1.docker.io    
 ```

### Future

I want to look into using [Spotify Dockerfile Maven][spotify] which takes an opinionated view of the Maven and Docker build processes, enabling users to combine the two build steps into one.

[gh-demo]: https://github.com/michaellambgelo/demo
[spotify]: https://github.com/spotify/dockerfile-maven