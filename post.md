# Getting Started With The Grinder

Performance testing is important. 
In this blog post we will explain why, introduce you to The Grinder, and take you through five examples which will get you started using Grinder to test the performance of your web application.

The post is based on workshops held at [ROOTS](http://www.rootsconf.no/talks/42) and [FreeTest](http://free-test.org/node/81#2012051009-EspenHalvorsen).
The materials from these--slides, tasks and code--are [available on GitHub](https://github.com/kvalle/grinder-workshop).
To get the most out of the examples, you may want to follow along with the workshop trying each task on you own, before we present the solutions here.

## So, Why Should I Test Performance?

*TODO: Espen*

## Grinder 101

Okay, you get it already, performance testing is important.
But why should you use Grinder in particular?
Lets have a closer look!

Grinder is a load testing framework written in Java.
It is free, open under a BSD-stype open-source licence, and supports large scale testing using distributed load injector machinces.

The main selling point of Grinder, however, is that it is lightweight and easy to use.
With Grinder there are no licences to buy or large environments to set up.
...

The reason you, as a developer, will prefer Grinder is that you create your tests in code, not some GUI.
(Conversely, if you happen to not be a developer, then Grinder might not be the tool for you. But you still need to understand why your developers should use Grinder!)
Although Grinder itself is written in Java, Jython or Closure are used for scripting tests.

Why Grinder? ... compared to LoadRunner, JMeter, etc.

- Written in Java, but using Jython and Clojure for test scripting.
- Tests written i code, not created in a GUI
- Few requirements - all you need is Java

(if you don't like scripting, Grinder is probably not the best tool for you...)

The Grinder framework is comprised of three types of processes (or programs):

1. *Worker processes*: Interprets test scripts and performs the tests using a number of parallel *worker threads*.
1. *Agent processes*: Long running process that starts and stops worker processes as required.
1. *The Console*: Coordinates agent processes, and collates and displays statistics.

![Overview of the Grinder framework](./images/grinder-overview.png)

## Bootstrapping the Framework

*TODO: explain how to download the code from the workshop, and use it to follow along with the examples*

## Example 1 - Testing GET Response Time

*TODO: Kjetil*

## Example 2 - Testing multiple URLs

*TODO: Kjetil*

## Example 3 - Validating the responses

*TODO: Kjetil*

## Example 4 - Testing of a typical JSON-API (REST API)

*TODO: Espen*

## Example 5 - Using Grinder's TCPProxy to automatically generate tests

*TODO: Espen*

## Summary

*TODO: something to wrap everything up nicely*

---

Espen Herseth Halvorsen / Kjetil Valle
