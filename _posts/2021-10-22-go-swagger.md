---
layout : post
title : Swagger UI and Go
category : golang
image : "/seo/default.png"
---

## What is Swagger?

Swagger is a suite of tools to generate and represent RESTful APIs. It promotes the [OpenAPI 2.0 spec](https://github.com/OAI/OpenAPI-Specification/blob/main/versions/2.0.md) which describes an API using JSON representation in a specification file called `swagger.json`. Since YAML is a superset of JSON, the specification file can conform to YAML.

In my projects, I want to be able to generate `swagger.json` from an annotated codebase to serve using Swagger UI.

## Swagger Tools

- [go-swagger](https://goswagger.io/)
  - enables generating a Go client or server from an existing Swagger spec
  - can scan an annotated codebase and generate a Swagger spec
- [Swagger UI](https://github.com/swagger-api/swagger-ui)
  - serves visual documentation of an API based on a given Swagger spec

## Generating a Swagger spec

`go-swagger` is a CLI tool. The following is an example command for generating a Swagger spec

```sh
swagger generate spec -o ./swagger.json
```

## Installing Swagger UI in a Go application

Based on the [installation docs](https://github.com/swagger-api/swagger-ui/blob/master/docs/usage/installation.md) Swagger UI can be served as part of an application using plain HTML/CSS/JS.

### How to serve plain HTML Swagger UI

The folder `/dist` includes all the HTML, CSS and JS files needed to run SwaggerUI on a static website or CMS, without requiring NPM.

1. Download the [latest release](https://github.com/swagger-api/swagger-ui/releases/latest).
2. Copy the contents of the `/dist` folder to your server.
3. Open `index.html` in your HTML editor and replace "https://petstore.swagger.io/v2/swagger.json" with the URL for your OpenAPI 3.0 spec.

## What is the purpose?

Reading and writing code is a big part of my daily life and the opportunity to put things together in Go is a fun break from the enterprise application development I do at C Spire. Swagger UI is a tool we use in our Spring/Spring Boot applications to easily share our API documentation with each other and the teams which integrate with us. This post is my personal documentation for how to integrate a tool I know and love in a new programming language.
