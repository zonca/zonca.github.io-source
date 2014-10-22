Title: Zero based indexing
Date: 2014-10-22 10:00
Author: Andrea Zonca
Tags: python
Slug: zero-based-indexing

## Reads

* Dijkstra: <https://www.cs.utexas.edu/~EWD/transcriptions/EWD08xx/EWD831.html>
* Guido van Rossum: <https://plus.google.com/115212051037621986145/posts/YTUxbXYZyfi>

## Comment

For Europeans zero based indexing feels sensible if we think of floors in a house,
the lowest floor is ground floor, then 1st floor and so on.

A house with 2 stories has ground and 1st floor. It is natural in this way to index
zero-based and to count 1-based.

What about **slicing** instead? This is a separate issue from indexing.
The main problem here is that if you include the upper bound then you cannot express
the empty slice.
Also it is elegant to print the first `n` elements as `a[:n]`. Slicing `a[i:j]` excludes
the upper bound, so it probably easier to understand if we express it as `a[i:i+n]`.
