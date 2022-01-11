---
layout : post
title : Error Handling
category : golang
image : "seo/default.png"
---

I am continuing to learn more about Go and its history.

The language follows idioms.

## Idioms of Go

- get the job done
- one way of doing things
- be explicit
- build things by composing them

## Fundamentals of Software Development

One of the most important aspects of my job is writing meaningful error messages. It's something a lot of people don't ever stop to consider: where do error messages come from?

Software developers create tools used by others and by nature of the broad interconnected tooling systems in computers and the internet at-large it cannot be difficult to imagine how collaboration is vitally important. Error messaging is how a software developer communicates with their users about expected and unexpected behavior. I believe that software which does not provide meaningful error messages (here's what went wrong, here's how to fix it) is not well-written software.

Error handling is a fundamental skill for software engineering.

## Error Handling in Go

Review the following `go` packages for an example of returning an error. [Source](https://golang.org/doc/tutorial/handle-errors) from golang.org

`greetings.go`

```go
package greetings

import (
    "errors"
    "fmt"
)

// Hello returns a greeting for the named person.
func Hello(name string) (string, error) {
    // If no name was given, return an error with a message.
    if name == "" {
        return "", errors.New("empty name")
    }

    // If a name was received, return a value that embeds the name
    // in a greeting message.
    message := fmt.Sprintf("Hi, %v. Welcome!", name)
    return message, nil
}
```

`main.go`

```go
package main

import (
    "fmt"
    "log"

    "example.com/greetings"
)

func main() {
    // Set properties of the predefined Logger, including
    // the log entry prefix and a flag to disable printing
    // the time, source file, and line number.
    log.SetPrefix("greetings: ")
    log.SetFlags(0)

    // Request a greeting message.
    message, err := greetings.Hello("")
    // If an error was returned, print it to the console and
    // exit the program.
    if err != nil {
        log.Fatal(err)
    }

    // If no error was returned, print the returned message
    // to the console.
    fmt.Println(message)
}
```

## Notes

- the `log` and `errors` packages are golang builtins
- I would want to use constants for error messages, e.g., `errors.New(UNEXPECTED_ERROR)` or `errors.New(EXTERNAL_SERVICE_ERROR)` however Go does not support this pattern since it alternates between camelCase and PascalCase to denote variables which are global to a file vs. global to a package (respectively)

## Willow

![willow](/img/2021-10-04-willow.jpg)
