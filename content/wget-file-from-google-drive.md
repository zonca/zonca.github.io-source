Title: wget file from google drive
Date: 2014-01-31 18:00
Author: Andrea Zonca
Tags: bash
slug: wget-file-from-google-drive

Sometimes it is useful, even more if you have a chromebook, to upload a file to Google Drive and then use `wget` to retrieve it from a server remotely.

In order to do this you need to make the file available to "Anyone with the link", then click on that link from your local machine and get to the download page that displays a Download button.
Now right-click and select "Show page source" (in Chrome), and search for "downloadUrl", copy the url that starts with `https://docs.google.com`, for example:

    https://docs.google.com/uc?id\u003d0ByPZe438mUkZVkNfTHZLejFLcnc\u0026export\u003ddownload\u0026revid\u003d0ByPZe438mUkZbUIxRkYvM2dwbVduRUxSVXNERm0zZFFiU2c0PQ

This is unicode, so open `Python` and do:

    download_url = "PASTE HERE"
    print download_url.decode("unicode_escape")
    u'https://docs.google.com/uc?id=0ByPZe438mUkZVkNfTHZLejFLcnc&export=download&revid=0ByPZe438mUkZbUIxRkYvM2dwbVduRUxSVXNERm0zZFFiU2c0PQ'
    
The last url can be pasted into a terminal and used with `wget`.
    