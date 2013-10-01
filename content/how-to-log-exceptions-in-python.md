Title: How to log exceptions in Python
Date: 2013-10-01 10:30
Author: Andrea Zonca
Tags: python, exceptions
slug: how-to-log-exceptions-in-python

Sometimes it is useful to just catch any exception, write details to a log file and continue execution.

In the `Python` standard library, it is possible to use the `logging` and `exceptions` modules to achieve this.
First of all, we want to catch any exception, but also being able to access all information about it:

```python
try:
    my_function_1()
except exception.Exception as e:
    print e.__class__, e.__doc__, e.message
```

Then we want to write those to a logging file, so we need to setup the logging module:

```python
import logging
logging.basicConfig( filename="main.log",
                     filemode='w',
                     level=logging.DEBUG,
                     format= '%(asctime)s - %(levelname)s - %(message)s',
                   )
```

[In the following gist](https://gist.github.com/zonca/6782980) everything together, with also [function name detection from Alex Martelli](http://stackoverflow.com/questions/2380073/how-to-identify-what-function-call-raise-an-exception-in-python):

<script src="https://gist.github.com/zonca/6782980.js"></script>

Here the output log:

```text
2013-10-01 11:32:56,466 - ERROR - Function my_function_1() raised <type 'exceptions.IndexError'> (Sequence index out of range.): Some indexing error
2013-10-01 11:32:56,466 - ERROR - Function my_function_2() raised <class 'my_module.MyException'> (This is my own Exception): Something went quite wrong
2013-10-01 11:32:56,466 - ERROR - Function my_function_1_wrapper() raised <type 'exceptions.IndexError'> (Sequence index out of range.): Some indexing error
```
