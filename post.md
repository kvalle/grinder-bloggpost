# Getting Started With The Grinder

Performance testing is important. 
In this blog post we will explain why, introduce you to The Grinder, and take you through five examples which will get you started using Grinder to test the performance of your web application.

The post is based on workshops held at [ROOTS](http://www.rootsconf.no/talks/42) and [FreeTest](http://free-test.org/node/81#2012051009-EspenHalvorsen).
The materials from these--slides, tasks and code--are [available on GitHub](https://github.com/kvalle/grinder-workshop).
To get the most out of the examples, you may want to follow along with the workshop trying each task on you own, before we present the solutions here.

## So, Why Should I Test Performance?

*TODO: Espen*

## Grinder 101

*TODO: Kjetil*

## Bootstrapping the Framework

*TODO: explain how to download the code from the workshop, and use it to follow along with the examples*

## Example 1 - Testing GET Response Time

In the first example, we will start simle by writing a test for GETing a single URL and measuring the response time.

First, we need some setup.
Like in the grinder 101 example, we start with a simple configuration file in `1.properties`.

    grinder.processes = 1
    grinder.threads = 1
    grinder.runs = 10
    
    grinder.useConsole = false
    grinder.logDirectory = log

    grinder.script = scripts/task1.py

The first group of properties specifies how much load the test will utilize.
The defaults for all three properties are 1. 
Our setup will run the test 10 times sequentially in a single thread.
The two next settings tells Grinder not to attempt connecting with the console and to store all log files in the `log` directory.
Finally, the last property informs Grinder about which test script to run.

We'll need to write this test script next.
Our `scripts/task1.py` should look something like this:

    from net.grinder.script.Grinder import grinder
    from net.grinder.script import Test
    from net.grinder.plugin.http import HTTPRequest

    class TestRunner:
        
        def __init__(self):
            test = Test(1, "GETing some webpage")
            self.request = test.wrap(HTTPRequest())
        
        def __call__(self):
            self.request.GET("http://foobar.example.com/page42")

We implement two methods: the `__init__` method for setting up the test, and the `__call__` method which is called by Grinder once per test run to be performed.

In the init-method we first crate a `Test` object and then use its `wrap` method to create a proxy object wrapping an instance of `HTTPRequest`.
This proxy is then stored as an instance variable `self.request`, ready for use in the test runs.

The reason we need to use the `Test` to create a proxy is in order for Grinder to be able to track what is happening.
Every method invoked on the proxy is recorded and timed by Grinder, before passing the call on to the wrapped object or function.

In this example, the call-method simply invoks the `GET` method on the proxy, which is then passed through to the `HTTPRequest` instance performing the actual request.

If you are following along with the [workshop materials](https://github.com/kvalle/grinder-workshop), you can now run the test by using the `startAgent` script.

    ./startAgent.sh tasks/1.properties
   

This should generate a few files in the `log` directory specified in the test configuration, where the results of the test are recorded.

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
