Title: How to create pull requests on Github
Date: 2017-06-30 11:00
Author: Andrea Zonca
Tags: git, github
Slug: quick-github-pull-requests

Pull Requests are the web-based version of sending software patches via email to code maintainers.
They allow a person that has no access to a code repository to submit a code change to the repository administrator for review and 1-click merging.

## Preparation

* Create a free Github account at <https://github.com>
* Login on Github with your credentials
* Go to the homepage of the repository, for example <https://github.com/sdsc/sdsc-summer-institute-2017>

## Small changes via Github.com

For small changes, like create a folder and upload a few files, or a quick fix on a previous file, you don't even need to use the `git` command line client.

* If you need to **create a folder**
    * click on "Create new file"
    * in the "Name your file..." box, insert: "yourfolder/README.md"
    * in the README.md write a description of the content of the folder, you can use markdown syntax, (see [the Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet) )
    * create a bullet list with description of the files you will be uploading next
    * Click on "Propose new file"
    * this will ask you to create a Pull Request, follow the prompts and make sure to confirm at the end that you want to create a Pull Request, you have to click twice on "Create Pull Request" buttons
* If you want to upload files in the folder you just created, you need an additional step, if you want to upload to a folder already existing in the original repo, skip this:
    * Go to the fork of the original repository that was created automatically under your account, for example: <https://github.com/YOURUSERNAME/sdsc-summer-institute-2017>
    * Click on the dropdown "Branch" menu and look for the branch named `patch-1`, or `patch-n` if you have more.
* Click on the "Upload files" button, select and upload all files, a few notes:
    * do not upload zip archives
    * do not upload large data files, Github is for code
    * if you are uploading binary files like images, downgrade them to a small size
    * this will ask you to create a Pull Request, follow the prompts and make sure to confirm at the end that you want to create a Pull Request, you have to click twice on "Create Pull Request" buttons
* Check that your pull request appeared in the Pull Requests area of the repository, for example <https://github.com/sdsc/sdsc-summer-institute-2017/pulls>

## Update a previously create Pull Request via Github.com

If the repository maintainer has some feedback on your Pull Request, you can update it to accomodate any requested change.

* Go to the fork of the original repository that was created automatically under your account, for example: <https://github.com/YOURUSERNAME/sdsc-summer-institute-2017>
* Click on the dropdown "Branch" menu and look for the branch named `patch-1`, or `patch-n` if you have more.
* Now make changes to files or upload new files, then confirm and write a commit message from the web interface
* Check that your changes appear as updates inside the Pull Request you created before, for example  <https://github.com/sdsc/sdsc-summer-institute-2017/pull/N> where N is the number assigned to your Pull Request
    
## Use the command line client

For more control and especially if you expect the repository maintainer to make changes to your Pull Request before merging it, better use `git`.

* Click on the "Fork" button on the top right of the repository
* Now you should be on the copy of the repository under your own account, for example <https://github.com/YOURUSERNAME/sdsc-summer-institute-2017>
* Now open your terminal, if you never used `git` before, set it up with:

        $ git config --global user.name "Your Name"
        $ git config --global user.email "your@email.edu"

* Now open your terminal and clone the repository with:

        git clone https://github.com/YOURUSERNAME/sdsc-summer-institute-2017
       
* Enter in the repository folder
* Create a branch to isolate your changes with:

        git checkout -b "add_XXXX_material"
        
* Now create folders, modify files, you can use any text editor
* Once you are done doing modifications, you can prepare them to be committed with, this adds everything inside the folder:

        git add my_folder
        
* Generally better instead to add each file to make sure you don't accidentally commit wrong files

        git add my_folder/aaa.txt my_folder/README.md
        
* Then write this changes to history with a commit

        git commit -m "Added material about XXXX"
        
* Push changes to Github

        git push -u origin add_XXXX_material
        
* Now go to the homepage of the original repository, for example <https://github.com/sdsc/sdsc-summer-institute-2017>
* There should be a yellow notice saying that it detected a recently pushed branch, click on "Compare and Pull Request"
* Add a description
* Confirm with the green "Create Pull Request" button

In case you want to update your Pull Request, repeat the steps of `git add`, `git commit` and `git push`, any changes will be reflected inside the pull request.
        


   