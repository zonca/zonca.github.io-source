Title: Code review for scientific computing
Date: 2014-08-28 17:00
Author: Andrea Zonca
Tags: github, git, openscience, software-carpentry
Slug: code-review-for-scientific-computing

Code review is the formal process where a programmer inspects in detail a piece of software developed by somebody else in order to improve code quality by catching bugs, improve readibility and usability.
It is used extensively in industry, not much in academia.

There has been some discussion about this lately, see:
* [A few thoughts on code review of scientific code](http://ivory.idyll.org/blog/on-code-review-of-scientific-code.html) by Titus Brown
* [Code review for science: What we learned](http://mozillascience.org/code-review-for-science-what-we-learned/) by Kaitlin Thaney

I participated in the [second code review pilot study of Software Carpentry](http://software-carpentry.org/blog/2014/01/code-review-round-2.html) where I was paired to a research group in Genomics and I reviewed some of their analysis code.
In this blog post I'd like to write about some guidelines and practical details on how to perform code review of scientific code.

Best use of code review is on libraries, prior to publication, because an improvement in code quality can help future users of the code. One-off analysis scripts benefit less from the process.

## How to do a code review of a large codebase

The code review process should be performed on ~200-400 lines of code at a time.
First thing is to ask the code author if she can identify different functionalities of the code that could be packaged and distributed separately. Modularity really helps maintaining software in the long term.

Then the author should follow these steps to get ready for the code review:

* For each of the packages identified previously, the code author should create a separate repository, generally on Github, possibly under an organization account (see [Github for research groups](http://zonca.github.io/2014/08/github-for-research-groups.html)).
* Create a blank project in the programming language of choice (hopefully Python!) using a pre-defined standard template, I recommend using [CookieCutter](https://github.com/audreyr/cookiecutter).
* Write a `README.md` file explaining exactly the functionality of the code in general
* Clone the repository locally, add, commit and push the blank project with `README.md` to the `master` branch on Github
* Identify a portion of the software of about ~200-400 lines that has a defined functionality and that could be reviewed together. It doesn't necessarily need to be in a runnable state, at the beginning we can start the code review without running the code.
* Create a new branch locally and copy, add, commit this file or this set of files to the repository and push to Github
* Access the web interface of Github, it should have detected that you just pushed a new branch and asked if you want to create a pull request. Create a pull request with a few details on the code under review.
* Point the reviewer to the pull request

## How to review an improvement to the software

The implementation of a feature should be performed on a separate branch, then it is straightforward to push it to Github, create a pull request and ask reviewers to look at the set of changes.

## How to perform the actual code review

Coding style should not be the main focus of the review, the most important feedback for the author are high-level comments on software organization. The reviewer should focus on what makes the software more usable and more maintenable.

A few examples:

* can some parts of the code be simplified?
* is there any functionality that could be replaced by an existing library?
* is it clear what each part of the software is doing?
* is there a more straightforward way of splitting the code into files?
* is documentation enough?
* are there some function arguments or function names that could be easily misinterpreted by a user?

The purpose is to improve the code, but also to help the code author to improve her coding skills.

On the Github pull requests interface, it is possible both to write general comments, and to click on a single line of code and write an inline comment.

## How to implement reviewer's recommendations

The author can improve the code locally on the same branch used in the pull request, then commit and push the changes to Github, the changes will be automatically added to the existing pull request, so the reviewer can start another iteration of the review process.