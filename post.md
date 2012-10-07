Get Started Performance Testing Using The Grinder
=================================================

Performance testing is important. 
In this blog post we will explain why, introduce you to a tool for testing performance called The Grinder, and take you through five examples which will get you started using Grinder for testing your web application.

The post is based on workshops held at [ROOTS](http://www.rootsconf.no/talks/42) and [FreeTest](http://free-test.org/node/81#2012051009-EspenHalvorsen), and the materials -- slides, tasks and code -- are of course [available on GitHub](https://github.com/kvalle/grinder-workshop).
To get the most out of the examples, you may want to follow along with the materials trying each task on your own, before reading the solutions we present here.


So, Why Should I Test Performance?
----------------------------------

*TODO: Espen*


Why Grinder?
------------

Okay, you get it already, performance testing is important!
But why should you use Grinder in particular?
And what is Grinder anyway?
Lets have a closer look.

Grinder is a load testing framework written in Java.
It is free, open source under a BSD-style licence, and supports large scale testing using distributed load injector machinces.
The main selling point of Grinder, however, is that it is lightweight and easy to use.
With Grinder there are no licences to buy or large environments to set up.
You just write a simple test script and fire up the grinder.jar file.

The reason you, as a developer, will prefer Grinder is that you create your tests in code, not some GUI.
Although Grinder itself is written in Java, the test scripts are written in Jython or Closure, which means you can utilize the expressiveness of a dynamic or functional language while still tapping into the resources of Java and the JVM.
(Of course, should you be so unfortunate not to be a developer, then Grinder might not be the tool for you. But you still need to understand why your developers want and should use Grinder!)

So, lets have a closer look on the nuts and bolts of Grinder.


Grinder 101
-----------

The Grinder framework is comprised of three types of processes (or programs):

1. *Worker processes*: Interprets test scripts and performs the tests using a number of parallel *worker threads*.
1. *Agent processes*: Long running process that starts and stops worker processes as required.
1. *The Console*: Coordinates agent processes, and collates and displays statistics.

![Overview of the Grinder framework](https://raw.github.com/kvalle/grinder-bloggpost/master/images/grinder-overview.png)

In this tutorial we'll keep things simple, and focus on the worker and agent precesses.
We will start an agent process manually, providing it with a test script and configuration, leaving the console and distributed testing out for now.

The test script is simply a Python (or Clojure) source file.
Grinder expects to find a class called `TestRunner` which should implement two methods: `__init__` and `__call__`.
The init-method is called by Grinder initially to set up the test, and call-method is then called repeatedly for each iteration of the testing.

### A Simple Example

Consider the code below.
This is the Grinder-equivalent of a "Hello World" program.
It defines a test script which will print the thread number of the worker thread and the string "hello world" each time it is triggered.

```python
from net.grinder.script.Grinder import grinder
from net.grinder.script import Test

# defining a simple "hello world" function, in order to have something to test
def hello_world():
    thread = grinder.getThreadNumber()
    print '> worker thread %d: hello world!' % thread

class TestRunner:
            
    def __init__(self):
        # creating a Grinder test object
        test = Test(1, "saying hello")
        # creating a proxy, by wrapping the hello world function with our Test-object
        self.wrapped_hello = test.wrap(hello_world)

    def __call__(self):
        # calling "hello world" through the wrapped function
        self.wrapped_hello() 
```

The important part to note in the above code is the `Test` object.
This object represents a basic operation of testing with Grinder.
We wrap our `hello_world` function with the test object, which tells Grinder to start timing and recording it.
Notice also that we are calling Grinder's wrapped version, not the function itself.

Next we need a test configuration.

    grinder.script = hello.py

    grinder.processes = 1
    grinder.threads = 4
    grinder.runs = 5

    grinder.useConsole = false
    grinder.logDirectory = log

Here we first tells Grinder which test script to run.
Then we specify that we only want one worker process started, and that the worker process should initiate four threads, each making five runs, i.e. calls to our `__call__` method.
The final two lines tell Grinder not to expect us to use the console (thus avoiding some output warnings) and where to put the log files describing the test results.

Now we are ready to run the test.
Start Grinder using the following command:

    java -cp lib/grinder.jar net.grinder.Grinder hello.properties

Or, more conveniently by using the [startAgent script](https://github.com/kvalle/grinder-workshop):

    ./startAgent.sh hello.properties

This should result in the printing of "hello world" a number of times and produce some files in the `log` directory.
The `data_xyz.log` file contains a detailed summary of the test events, while the `out_xyz.log` file provides a summary of the results.

             Tests    Errors   Mean Test    Test Time    TPS
                               Time (ms)    Standard
                                            Deviation
                                            (ms)

    Test 1   20       0        0.90         3.05         625.00    "saying hello"

    Totals   20       0        0.90         3.05         625.00


Bootstrapping the Framework
---------------------------

*TODO: explain how to download the code from the workshop, and use it to follow along with the examples*


Example 1 - Testing GET Response Time
-------------------------------------

In the first example, we will start easy by writing a test which makes a HTTP GET request for a single URL, and measure the response time.

First, we need some setup.
Like in the "hello world" example, we start with a simple configuration file in `1.properties`.

    grinder.script = scripts/task1.py
    
    grinder.processes = 1
    grinder.threads = 1
    grinder.runs = 10
    
    grinder.useConsole = false
    grinder.logDirectory = log

There's not much new here.
Again, the first property informs Grinder which test script to run.
The second group of properties specifies how much load the test will utilize.
The defaults for all three properties are 1. 
Our setup will run the test 10 times sequentially in a single thread.
The last properties are identical to the previous example.

Next we'll need to write the test script we just referenced.
Our `scripts/task1.py` should look something like this:

```python
from net.grinder.script.Grinder import grinder
from net.grinder.script import Test
from net.grinder.plugin.http import HTTPRequest

class TestRunner:
    
    def __init__(self):
        test = Test(1, "GETing some webpage")
        self.request = test.wrap(HTTPRequest())
    
    def __call__(self):
        self.request.GET("http://foobar.example.com/page42")
```

In the init-method we start by crating a `Test` object and then use its `wrap` method to create a proxy object wrapping an instance of `HTTPRequest`.
This proxy is then stored as an instance variable `self.request`, ready for use in the test runs.

The reason we need to use the `Test` to create a proxy is in order for Grinder to be able to track what is happening.
Every method invoked on the proxy is recorded and timed by Grinder, before passing the call on to the wrapped object or function.

In this example, the call-method simply invoks the `GET` method on the proxy, which is then passed through to the `HTTPRequest` instance performing the actual request.

If you are following along with the [workshop materials](https://github.com/kvalle/grinder-workshop), you can now run the test by using the `startAgent` script.

    ./startAgent.sh tasks/1.properties

(Or, if you checked out the code but didn't bother to do the tasks, substitute `solutions` for `tasks` and do the same.)

This should generate a few files in the `log` directory specified in the test configuration, where the results of the test are recorded.


Example 2 - Testing multiple URLs
---------------------------------

Testing the response time of a single URL isn' really very useful, so the next step is naturally to time the requests of a bunch of different URLs.

Lets say we have a file with URLs that look something like this:

    http://example.com/
    http://example.com/foo.php
    http://example.com/bar.php
    http://example.com/baz.php
    http://example.com/unreliable-link.php
    http://example.com/bad-link.php
    http://example.com/404.php

In this example we'll read this file, create a test for each URL, and "GET" it each time the script is run.

The configuration in `2.properties` is very similar to the previous example.

    grinder.script = scripts/task2-extras.py

    grinder.runs = 10
    grinder.useConsole = false
    grinder.logDirectory = log

    task2.urls = solutions/scripts/urls.txt

We reference, of course, a new script file and also add one additional parameter.
The new parameter `task2.urls` is a custom parameter which holds the path to our text file with the URLs, since this is something we really don't want to hard code into the script.

Next we implement the script as follows.

```python
from net.grinder.script.Grinder import grinder
from net.grinder.script import Test
from net.grinder.plugin.http import HTTPRequest

url_file_path = grinder.getProperties().getProperty('task2.urls')

class TestRunner:
    
    def __init__(self):
        url_file = open(url_file_path)
        self.tests = []
        for num, url in enumerate(url_file):
            url = url.strip()
            test = Test(num, url)
            request = test.wrap(HTTPRequest())
            self.tests.append((request, url))
        url_file.close()
    
    def __call__(self):
        for request, url in self.tests:
            request.GET(url)
```

Notice first how we extract custom property value as the file path in the start of the script.
The rest of the script is familiar, but with some additional logic in the `__init__` and `__call__` methods.
The code should hopefully be pretty self explanatory, but lets walk through it.

The first thing we do in the `__init__` method is to open the file with the URLs.
We then iterate through the file, using `enumerate` to get the line numbers.
For each line we extract the URL, create a `Test` object, wrap a `HTTPRequest` object using the test object, and append the wrapped request together with the URL to our list of tests.

In `__call__` we simply walk through the list of tests, making a GET request for the URL using the the corresponding wrapped HTTPRequest.

The important thing to notice in this example is that we don't simply GET all the URLs using a single HTTPRequest.
We want each URL to be timed separately, and must therefore create a grinder-proxy for each one.

Now we are ready to try it out.
Run:

    ./startAgent.sh tasks/2.properties

Which should give you something like the following included at the end of the log file:

                 Tests        Errors       Mean Test    Test Time    TPS          Mean         Response     Response     Mean time to Mean time to Mean time to 
                                           Time (ms)    Standard                  response     bytes per    errors       resolve host establish    first byte   
                                                        Deviation                 length       second                                 connection                
                                                        (ms)                                                                                                    

    Test 0       10           0            453.70       105.15       1.09         483.00       528.16       0            15.20        51.40        451.00        "http://example.com/"
    Test 1       10           0            59.80        19.55        1.09         163.00       178.24       0            15.20        51.40        58.90         "http://example.com/foo.php"
    Test 2       10           0            131.20       21.48        1.09         18433.00     20156.37     0            15.20        51.40        66.80         "http://example.com/bar.php"
    Test 3       10           0            59.10        16.08        1.09         616.00       673.59       0            15.20        51.40        57.90         "http://example.com/baz.php"
    Test 4       10           0            57.60        25.24        1.09         71.00        77.64        4            15.20        51.40        56.60         "http://example.com/unreliable-link.php"
    Test 5       10           0            75.00        26.10        1.09         0.00         0.00         0            15.20        53.70        73.30         "http://example.com/bad-link.php"
    Test 6       10           0            75.00        69.34        1.09         169.00       184.80       10           15.20        53.70        74.10         "http://example.com/404.php"

    Totals       70           0            130.20       143.58       1.09         2847.86      3114.11      14           15.20        52.06        119.80       



Example 3 - Validating the responses
------------------------------------

If you looked carefully at the results from the previous example, you might have discovered a problem with the test scripts we have written so far.
The *errors* column reports that everything went OK although, as we can see, there where several errors in the *response errors* column!

In this example, we'll look at how to inspect the HTTP responses, and tell Grinder to fail a test if we find anything fishy.

Again we start with the test configuration:

    grinder.script = scripts/task3.py
    
    grinder.runs = 10
    grinder.useConsole = false
    grinder.logDirectory = log
    
    task3.urls = solutions/scripts/urls.txt

Not much is changed here, so lets move on to the test script.

```python
from net.grinder.script.Grinder import grinder
from net.grinder.script import Test
from net.grinder.plugin.http import HTTPRequest

url_file_path = grinder.getProperties().getProperty('task3.urls')

class TestRunner:
    
    def __init__(self):
        url_file = open(url_file_path)
        self.tests = []
        for num, url in enumerate(url_file):
            url = url.strip()
            test = Test(num, url)
            request = test.wrap(HTTPRequest())
            self.tests.append((request, url))
        url_file.close()
        grinder.statistics.setDelayReports(True)
    
    def __call__(self):
        for request, url in self.tests:
            response = request.GET(url)
            if not self.is_valid(response):
                self.fail()
            grinder.statistics.report()

    def fail(self):
        grinder.statistics.getForLastTest().setSuccess(False)
            
    def is_valid(self, response):
        if len(response.getData()) < 10: return False
        if response.getStatusCode() != 200: return False
        if "epic fail" in response.getText(): return False
        else: return True
```

There are a few differences here, comprared to the last example.
Most obviously there are two new methods, but we also do some new things in the old ones.

First off, we need to tell Grinder not to automatically assume everything is okay as long as the code executes and the `GET` method returns.
We do this with the call to `grinder.statistics.setDelayReports(True)` at the end of the `__init__` method.

Next, the `__call__` method has been extended to capture the HTTP response object.
We validate the response using our new `is_valid` method, and tell Grinder to `fail` the test if validation fails.
Lastly, `grinder.statistics.report()` makes Grinder record the result of the test and move on.

The new `is_valid` method is where most of the magic happens.
Here we can look at any aspect of the response we might like, and simply return `False` if we are not satisfied.

(It would of course also be possible to make different validation checks for different URLs.
We won't go into how to do that here, but you might have a look at [this example][task-3-extras] to see how it could be done.)

By running the script we get these new results:

                 Tests        Errors       Mean Test    Test Time    TPS          Mean         Response     Response     Mean time to Mean time to Mean time to 
                                           Time (ms)    Standard                  response     bytes per    errors       resolve host establish    first byte   
                                                        Deviation                 length       second                                 connection                
                                                        (ms)                                                                                                    

    Test 0       10           0            434.00       63.22        1.14         483.00       551.24       0            13.50        43.40        430.90        "http://example.com/"
    Test 1       10           0            48.00        5.59         1.14         163.00       186.03       0            13.50        43.40        46.80         "http://example.com/foo.php"
    Test 2       10           0            148.60       89.52        1.14         18433.00     21037.43     0            13.50        43.40        80.60         "http://example.com/bar.php"
    Test 3       10           0            63.50        23.10        1.14         616.00       703.04       0            13.50        43.40        62.30         "http://example.com/baz.php"
    Test 4       6            4            39.33        7.99         0.68         103.00       70.53        0            22.50        50.50        38.67         "http://example.com/unreliable-link.php"
    Test 5       0            10           �            0.00         0.00         �            0.00         0            �            �            �             "http://example.com/bad-link.php"
    Test 6       0            10           �            0.00         0.00         �            0.00         0            �            �            �             "http://example.com/404.php"

    Totals       46           24           156.02       160.39       0.75         4294.96      3221.18      0            14.67        44.33        139.96       

And indeed, the bad responses actually show up under *errors* this time.


[task-3-extras]: https://github.com/kvalle/grinder-workshop/blob/master/solutions/scripts/task3-extras.py


Example 4 - Testing of a typical JSON-API (REST API)
----------------------------------------------------

*TODO: Espen*


Example 5 - Using Grinder's TCPProxy to automatically generate tests
--------------------------------------------------------------------

*TODO: Espen*


Summary
-------

We have prestented The Grinder, as a simple tool for doing performance testing.
While there are many tools out there for testing performance, the strength of Grinder is that it is lightweight and easy to use.
We basically only needed two files and a single command to get going!

After taking you though five gradually more complex examples, we have hopefully given you some insight into how Grinder works and what it can be used for.
Now you should be ready to write some scripts of your own, and start testing *your* application!

---

[Espen Herseth Halvorsen](espen.herseth.halvorsen@bekk.no) / [Kjetil Valle](kjetil.valle@bekk.no)
