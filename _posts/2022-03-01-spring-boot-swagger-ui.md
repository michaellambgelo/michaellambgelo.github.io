---
layout : post
title : Adding Swagger UI to Spring Boot projects
category : spring
image : "/seo/2022-03-01.png"
---

Spring Boot is a powerful project from the Spring ecosystem which enables developers to maximize their leverage of Spring applications. Standalone projects can be generated at [start.spring.io](https://start.spring.io) with any other additional dependencies of Spring project included in just a few clicks.

I have created a Spring Boot demo project available from my GitHub. I plan to use this project to demonstrate some tasks I perform regularly in Spring Boot.

[![Spring Logo](https://spring.io/images/spring-logo.svg)](https://spring.io/projects/spring-boot)

## Swagger UI

If you've been a follower of this blog you might recall I have previously integrated Swagger UI into a Go application (check out [this blog post from October 2021](https://michaellamb.dev/golang/2021/10/22/go-swagger.html)).

Swagger is a suite of tools which seeks to provide OpenAPI specifications and definitions. Codebases can be generated from a Swagger doc, just as an existing codebase can be documented by adding Swagger-identifiable annotations.

In this post I will show how I integrated Springfox Swagger UI into my Spring Boot application.

### Considerations

This configuration assumes an existing Spring Boot project and integrates io.springfox/swagger-boot-starter (version 3.0.0).

## pom.xml

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

## Main Application Entry Point

Wherever your Spring Boot app starts is dependent on your project. In my demo, this is a file called `DemoApplication.java`.

In this file, only two annotations need to be added to the base class:

```java
@EnableOpenApi
@EnableSwagger2
```

## AppConfiguration.java

If it doesn't exist yet, create a new Java class called `AppConfiguration.java`. The class itself will be empty but it will have a few annotations that will enable Springfox to scan the application code and identify endpoints.

```java
@Configuration
@EnableWebMvc
@ComponentScan("dev.michael.demo")
@EnableOpenApi
public class AppConfiguration {
}
```

## SpringConfig.java

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

## Conclusion

Swagger UI will now automatically generate API documentation every time the Spring Boot application is started.
