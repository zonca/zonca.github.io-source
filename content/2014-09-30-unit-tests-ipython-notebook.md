Title: Write unit tests as cells of IPython notebooks
Date: 2014-09-30 14:00
Author: Andrea Zonca
Tags: unit-test, ipython, ipython-notebook
Slug: unit-tests-ipython-notebook

## What?

Plugin for `py.test` to write unit tests as cells in IPython notebooks:

* Homepage on Github: <https://github.com/zonca/pytest-ipynb>
* PyPi : <https://pypi.python.org/pypi/pytest-ipynb/>
* Install with `pip install pytest-ipynb`

## Why?

Many unit testing fromeworks in Python, first of all the `unittest` package in the standard library, work very well for automating unit tests, but make it very difficult to debug interactively any failed test.

[`py.test`](http://pytest.org) alleviates this problem by allowing to write just plain Python functions with `assert` statements (no boilerplate code), discover them automatically in any file that starts with `test` and write a useful report.

I wrote a plugin for `py.test`, [`pytest-ipynb`](https://pypi.python.org/pypi/pytest-ipynb), that goes a step further and runs unit tests written as cells of any IPython notebook named `test*.ipynb`.

The advantage is that it is easy to create and debug interactively any issue by opening the testing notebook interactively, then clean the notebook outputs and add it to the software repository.

More details on Github: <https://github.com/zonca/pytest-ipynb>

Suggestions welcome as comments or github issues.

(Yes, works with Python 3)
