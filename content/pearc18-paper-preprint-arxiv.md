Title: How to post a PEARC18 paper pre-print to Arxiv
Date: 2018-05-12 18:00
Author: Andrea Zonca
Tags: pearc18, openscience
Slug: pearc18-preprint-arxiv

## Quick version

* Make sure you have the DOI from ACM
* If you have Latex: create a zip with sources, figures and `.bbl` (not `.bib`), no output PDF
* If you have Word: export to PDF
* Go to <https://arxiv.org/submit>
* Choose the first option for license and "Computer Science" and "Distributed, Parallel, and Cluster Computing" for category
* In Metadata set Comments as: "7 pages, 3 figures, PEARC '18: Practice and Experience in Advanced Research Computing, July 22--26, 2018, Pittsburgh, PA, USA"
* **Make sure you set the DOI** or you violate ACM rules
* Follow instructions until you publish

Follows the step-by-step version:

## Why upload a pre-print to arXiv

Journals provide a Open Access option, but it is very expensive, however, they generally allow authors to upload manuscripts before copy-editing to non-profit pre-print servers like the `arXiv`.
This makes your paper accessible to anybody without the need of any Journal subscription, you can also upload your work months before the conference proceedings are available.

## License

Before publishing any pre-print, you need to check on the Journal or Conference website
if it is allowed and at what conditions.

PEARC18 in particular publishes with ACM, therefore we can look at the [author rights page on the ACM website](http://authors.acm.org/main.html).

Currently the requirements for posting a pre-print are:

* the paper needs to be accepted and peer-reviewed
* this is the version by the author, before copy-editing, if any, by the journal
* it needs a DOI pointing to the ACM version of the paper

## Get a DOI

A DOI is generated once the author chooses a license.
PEARC18 first authors should have received an email around May 10th with a link to the ACM
website to choose a license.
There are 3 choices, Open Access is quite expensive, but we do not need that, we are still allowed
to post the pre-print even with any of the other 2 licenses, I personally recommend the
"license" option, that does not transfer copyright to ACM.
After completing this you should receive a DOI, which is a set of numbers of the form `10.1145/xxxxx.xxxxxx`.
Also remember to add the license text you will receive via email to the paper before going on with the upload.

## Prepare your Latex submission

The arXiv requires the source for any Latex paper.
If you are using the online platform [Overleaf](https://overleaf.com), click on "Project" and then "Download as zip" at the bottom.
If you are using anything else, create a zip file with all the paper sources and figures, *not the output PDF*, also make sure that you include the `.bbl` file, not the `.bib`, so you need to compile your paper locally and add just the `.bbl` to the archive.
Also, the arXiv dislikes large figures, so if you already know you have them, better resize or lower their quality before submission. Anyway you can just submit it as it is and check if they are accepted.

## Prepare your Word submission

Export the paper as PDF.

## Upload to arXiv

* Go to <https://arxiv.org/submit>, either login or create a new account.
* At the submission page, fill the form, for license, the safest is to use the first option: "arXiv.org perpetual, non-exclusive license to distribute this article (Minimal rights required by arXiv.org)"
* For "Archive and Subject Class", choose "Computer Science" and "Distributed, Parallel, and Cluster Computing" unless in the list there is a more suitable field
* Then upload the Latex sources zip file or the conversion of the Word file to PDF.
* Once you have uploaded the zip file, it shows you a list of the archive content, you can delete extra files are not needed to build the paper, if you used the Overleaf ACM template, remove `sample-sigconf-authordraft.tex`
* If the paper doesn't build, the arXiv displays the log, check for missing files or unsupported packages in particular, you can click "Add files" to upload different files
* If the paper successfully builds, click on the "View" button to check that the PDF is fine
* In the Metadata, complete the form, in the Comments, add also the conference information, for example "7 pages, 3 figures, PEARC '18: Practice and Experience in Advanced Research Computing, July 22--26, 2018, Pittsburgh, PA, USA"
* Still in Metadata, **make sure you add the DOI** otherwise it is a violation of the conditions by ACM, the DOI is in the form  `10.1145/xxxxxx.xxxx`
* Finally check the preview and finalize your submission
* The submission is not available immediately, it will first be in "Processing" stage and it will be published in the next few days, you'll get an email with the publishing date and time.

## Update your submission

* Anytime before publication you can update (overwrite) your submission
* After your pre-print is published you can update it at will but all previous versions will always be available on the arXiv servers.

