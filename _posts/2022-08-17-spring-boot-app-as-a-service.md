---
layout : post
title : Spring Boot App as a Service
image : "/seo/2022-08-17.png"
category : spring
---

Docker as a deployment strategy can have its shortcomings. One shortcoming I experienced recently was a breakdown in being able to make requests and receive responses from other michaellamb.dev apps and the Spring Boot demo app.

Instead of fighting with Docker (a tool I'm less familiar with) I opted to install the Spring Boot application as a service on a single node. This process could be automated using a CI/CD strategy and I may implement something using GitHub Actions in the future, but it is a more involved process than pulling a Docker image and running it as a container.

[Baeldung][baeldung] wrote an article I used as a guide for installing the [Spring Boot demo app][demo] as a service on Linux.

## Maven Configuration

The first step is to enable the executable flag in the `spring-boot-maven-plugin` referenced in `pom.xml`

```xml
<configuration>
    <executable>true</executable>
</configuration>
```

See this change in the linked commit: [update pom][update-pom]

## Build

The second step is to copy the source code to the node and package it for deployment.

```bash
./mvwn clean package
```

It may be necessary to change directory permissions to allow the app to read and write using the file system.

## System V Init

Using the traditional System V init, we create a symbolic link that we can use to reference as a service.

```bash
sudo ln -s /home/michael/demo/target/demo-0.1.0.jar /etc/init.d/demo
```

This link would need to be updated any time the jar is renamed

The app needs to be enabled by the system using the following command:

```bash
sudo systemctl enable demo
```

Once the system knows the app is available as a service, the service can be started.

```bash
sudo service demo start
```

Other commands are available using the standard service script: `stop`, `restart`, and `status`. Moreover, logs can be viewed under `var/log/demo.log`.

[baeldung]:[https://www.baeldung.com/spring-boot-app-as-a-service]
[demo]:[https://github.com/michaellambgelo/demo]
[update-pom]:[https://github.com/michaellambgelo/demo/commit/c8e42bad5eb8a901e68fdc0398582ce9bf41a450]
