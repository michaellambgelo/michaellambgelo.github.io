---
layout : post
title : Adding Swagger UI to Spring Boot projects
category : development
image : "/seo/2022-09-15.png"
tags:

- spring-boot
- api
- best-practices
- tutorial

redirect_from:
- /spring/2022/09/15/spring-boot-swagger-ui-redux.html

---

### This post copies and updates text from a previous version

[Check out the previous version of this post if you want to compare the differences.][previous]

Spring Boot is a powerful project from the Spring ecosystem which enables developers to maximize their leverage of Spring applications. Standalone projects can be generated at [start.spring.io](https://start.spring.io) with any other additional dependencies of Spring project included in just a few clicks.

I have created a [Spring Boot demo project available on my GitHub][demo]. I use this project to demonstrate some tasks I perform regularly in Spring Boot.

[![Spring Logo](https://spring.io/img/spring-2.svg)](https://spring.io/projects/spring-boot)

## Swagger UI

If you've been a follower of this blog you might recall I have previously integrated Swagger UI into a Go application (check out [this blog post from October 2021](https://michaellamb.dev/golang/2021/10/22/go-swagger.html)).

Swagger is a suite of tools which seeks to provide OpenAPI specifications and definitions. Codebases can be generated from a Swagger doc, just as an existing codebase can be documented by adding Swagger-identifiable annotations.

In this post I will show how I to integrate Springfox Swagger UI into a Spring Boot application. I will then demonstrate integrating Springdoc as an alternative, as Springfox hasn't been updated in a while ([the last commit was Oct, 2020][springfox-last-commit]). Springdoc supports the latest version of Spring Boot as of writing (2.7.2).

_but first..._

## How this post is structured

There are three MILE MARKER sections. #1 precedes the relevant code blocks for Springfox. #2 occurs after Springfox is concluded and before Springdoc code blocks begin. #3 appears after the conclusion of Springdoc.

## MILE MARKER 1

➡️ Springfox integration _(you are here)_

🔜 Springdoc integration

## Springfox

This configuration uses [an existing Spring Boot project][demo] and integrates io.springfox/swagger-boot-starter (version 3.0.0).

## pom.xml - add Springfox dependency

Add the Springfox Spring Boot starter dependency.

```java

<dependency>
    <groupId>io.springfox</groupId>
    <artifactId>springfox-boot-starter</artifactId>

    <version>3.0.0</version>

</dependency>

```

`springfox-boot-starter` provides the following artifacts from `io.springfox`:

- `springfox-oas`
- `springfox-data-rest`
- `springfox-bean-validators`
- `springfox-swagger2`
- `springfox-swagger-ui`

## Main Application Entry Point - add Springfox annotations

Wherever your Spring Boot app starts is dependent on your project. In my demo application, this is a file called `DemoApplication.java`.

In this file, only two annotations need to be added to the base class:

```java

@EnableOpenApi
@EnableSwagger2

```

## AppConfiguration.java - add Springfox annotations

If it doesn't exist yet, create a new Java class called `AppConfiguration.java`. The class itself will be empty but it will have a few annotations that will enable Springfox to scan the application code and identify endpoints. You could add these annotations on the main application class but I like it this way as it feels more explicit in intention.

```java

@Configuration
@EnableWebMvc
@ComponentScan("dev.michael.demo")
public class AppConfiguration {
}

```

## SpringConfig.java - add Springfox WebMvcConfigurer registries

`SpringConfig.java` will implement the `WebMvcConfigurer` interface. It will override a couple of methods so that Spring Boot can serve Swagger UI alongside the Spring Boot app.

```java

@Override
public void addResourceHandlers(ResourceHandlerRegistry registry) {
registry.
    addResourceHandler("/swagger-ui/**")
    .addResourceLocations("classpath:/META-INF/resources/webjars/springfox-swagger-ui/")
    .resourceChain(false);
}

```

`addResourceHandlers` will enable Spring Boot to find Swagger resources.

```java

@Override
public void addViewControllers(ViewControllerRegistry registry) {
registry.addViewController("/swagger-ui/")
    .setViewName("forward:" + "/swagger-ui/index.html");
}

```

`addViewControllers` will enable Spring Boot to serve the main Swagger UI page.

## Springfox Conclusion

Swagger UI will now automatically generate API documentation every time the Spring Boot application is started.

## MILE MARKER 2

✔️ Springfox integration

➡️ Springdoc integration _(you are here)_

## Springdoc

_Optional_: For an example migration from Springfox to Springdoc, [look at this commit][migration] on my Redis hackathon repo.

## pom.xml - add Springdoc depdendency

```xml

<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-ui</artifactId>

    <version>1.6.11</version>

</dependency>

```

## application.properties - add Springdoc configuration properties

```conf

springdoc.packages-to-scan=dev.michaellamb.demo
springdoc.paths-to-match=/api/**
springdoc.swagger-ui.path=/swagger-ui.html
springdoc.swagger-ui.enabled=true

```

## Springdoc Conclusion

Springdoc is a bit simpler in configuration than Springfox, relying primarily on `application.properties` to determine which packages to scan to document HTTP API routes for the app and without needing to override any Spring Beans to serve the frontend.

## MILE MARKER 3

✔️ Springfox integration

✔️ Springdoc integration

Great job! 🎉

You have a Spring Boot app ready to start developing an auto-documented HTTP API.

[previous]: https://michaellamb.dev/2021/03/01/spring-boot-swagger-ui.html
[demo]: https://github.com/michaellambgelo/demo
[springfox-last-commit]: https://github.com/springfox/springfox/commit/ab5868471cdbaf54dac01af12933fe0437cf2b01
[migration]: https://github.com/michaellambgelo/stackathon/commit/fae387b0f6a166aacd3e9bb829c120de4add3c01
