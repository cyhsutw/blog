---
layout: post
title: "Why You Should Use Linters"
published: false
---

Readability and maintainability are two of the most important factors of code quality, especially for large communities.

Recently, I started working on several open source projects, and discovered that most of the projects have **linters** in their continuous integration script.

So, what’s a *linter*? Here’s what Wikipedia says about “[lint](https://en.wikipedia.org/wiki/Lint_(software))”:

> In computer programming, lint is a Unix utility that flags some suspicious and non-portable constructs (likely to be bugs) in C language source code; generically, lint or a linter is any tool that flags suspicious usage in software written in any computer language.
>
> The term lint-like behavior is sometimes applied to the process of flagging suspicious language usage. Lint-like tools generally perform static analysis of source code.

In short, a *linter* is a program that analyze your code based on some rules.

What’s the point of doing this?
