Title: Ship large files with Python packages
Date: 2019-08-21 18:00
Author: Andrea Zonca
Tags: python
Slug: large-files-python-packages

It is often useful to ship large data files together with a Python package,
a couple of scenarios are:

* data necessary to the functionality provided by the package, for example images, any binary or large text dataset, they could be either required just for a subset of the functionalities of the package or for all of it
* data necessary for unit or integration testing, both example inputs and expected outputs

If data files are individually less than 10 MB and collectively less than 100 MB you can directly add them into the Python package. This is the easier and most convenient option, for example the [`astropy package template`](https://github.com/astropy/package-template) automatically adds to the package any file inside the `packagename/data` folder.

For larger datasets I recommend to host the files externally and use the [`astropy.utils.data` module](http://docs.astropy.org/en/stable/utils/#module-astropy.utils.data).
This module automates the process of retrieving a file from a remote server and caching it locally (in the users home folder), next time the user needs it, it is automatically retrieved from the cache:

```python
    dataurl = "https://my-web-server.ucsd.edu/test-data/"
    with data.conf.set_temp("dataurl", dataurl), data.conf.set_temp(
        "remote_timeout", 30
    ):
        filename = data.get_pkg_data_filename("myfile.jpg)
```

Now we need to host there files publicly, I have a few options.

### Host on a dedicated GitHub repository

If files are individually less than 100MB and collectively a few GB, you can create a dedicated repository on GitHub and push there your files.
Then [activate GitHub Pages](https://help.github.com/en/articles/what-is-github-pages) so that those files are published at `https://your-organization.github.io/your-repository/`.
Then use this URL as `dataurl` in the above script.

### Host on a Supercomputer or own server

Some Supercomputers offer the feature of providing public web access from specific folders, for example NERSC allows user to publish webpages publicly, see [their documentation](https://www.nersc.gov/users/computational-systems/pdsf/software-and-tools/hosting-webpages/).

This is very useful for huge datasets because you can automatically detect if the package is being run at NERSC and then automatically access the files with their path instead of downloading them.

For example:

```python

def get_data_from_url(filename):
    """Retrieves input templates from remote server,
    in case data is available in one of the PREDEFINED_DATA_FOLDERS defined above,
    e.g. at NERSC, those are directly returned."""

    for folder in PREDEFINED_DATA_FOLDERS:
        full_path = os.path.join(folder, filename)
        if os.path.exists(full_path):
            warnings.warn(f"Access data from {full_path}")
            return full_path
    with data.conf.set_temp("dataurl", DATAURL), data.conf.set_temp(
        "remote_timeout", 30
    ):
        warnings.warn(f"Retrieve data for {filename} (if not cached already)")
        map_out = data.get_pkg_data_filename(filename, show_progress=True)
    return map_out
```

Similar setup can be achieved on a GNU/Linux server, for example a powerful machine used by all members of a scientific team, where a folder is dedicated to host these data and is also published online with Apache or NGINX.

The main downside of this approach is that there is no built-in version control. One possibility is to enforce a policy where no files are ever overwritten and version control is automatically achieved with filenames. Otherwise, use [`git lfs`](https://git-lfs.github.com/) in that folder to track any change in a dedicated local `git` repository, e.g.:

```bash

git init
git lfs track "*.fits"
git add "*.fits"
git commit -m "initial version of all FITS files"

```

This method tracks the checksum of all the binary files and helps managing the history, even if only locally (make sure the folder is also regularly backed up). You could push it to GitHub, that would cost $5/month for each 50GB of storage.

### Host on Amazon S3 or other object store

A public bucket on Amazon S3 or other object store provides cheap storage and built-in version control.
First login to the AWS console and create a new bucket, set it public by turning of "Block all public access" and under "Access Control List" set "List objects" to Yes for "Public access".
