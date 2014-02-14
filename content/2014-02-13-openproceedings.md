Title: openproceedings: Github/FigShare based publishing platform for conference proceedings
Date: 2014-02-13 23:30
Author: Andrea Zonca
Tags: python, pelican, openscience
Slug: openproceedings-github-figshare-pelican-conference-proceedings

Github provides a great interface for gathering, peer reviewing and accepting papers for conference proceedings, the second step is to publish them on a website either in HTML or PDF form or both.
The Scipy conference is at the forefront on this and did great work in peer reviewing on Github, see: <https://github.com/scipy-conference/scipy_proceedings/pull/61>.

I wanted to develop a system to make it easier to continously publish updated versions of the papers and also leverage FigShare to provide a long term repository, a sharing interface and a [DOI](http://en.wikipedia.org/wiki/Digital_object_identifier).

I based it on the blog engine [`Pelican`](http://getpelican.com), developed a plugin [`figshare_pdf`](http://github.com/openproceedings/pelican_figshare_pdf) to upload a PDF of an article via API and configured [Travis-ci](http://travis-ci.org) as building platform.

See more details on the project page on Github:
<https://github.com/openproceedings/openproceedings-buildbot>