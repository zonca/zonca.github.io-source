Title: Create a Github account for your research group with free private repositories
Date: 2014-08-24 15:00
Author: Andrea Zonca
Tags: github, git, openscience
Slug: github-for-research-groups

[Github](https://github.com/) allows a research group to create their own webpage where they can host, share and develop their software using the `git` version control system and the powerful Github online issue-tracking interface.

Github offers unlimited private and public repositories to research groups and classrooms.
Private repositories are useful for early stages of development or if it is necessary to keep software secret before publication, at publication they can easily switched to public repositories and free up their slot.

They also provide free data packs for `git-lfs` which is useful to store large amount of binary data together with your software in the same repository, without actually committing the files into `git` but using a support server. Just go into "Settings" for your organization and under "Billing" add data packs, you will notice that the cost is $0.

Here the steps to set this up:

* Create a user account on Github and choose the free plan, use your `.edu` email address
* Create an organization account for your research group
* Go to https://education.github.com/ and click on "Get benefits"
* Choose what is your position, e.g. Researcher and select you want a discount for an organization
* Choose the organization you created earlier and confirm that it is a "Research group"
* Add details about your Research group
* Finally you need to upload a picture of your University ID card and write how you plan on using the repositories
* Within a week at most, but generally in less than 24 hours, you will be approved for unlimited private repositories.

Once the organization is created, you can add key team members to the "Owners" group, and then create another group for students and collaborators.

Consider also that is not necessary for every collaborator to have write access to your repositories. My recommendation is to ask a more experienced team member to administer the central repository, ask the students to fork the repository under their user accounts (forks of private repositories are always private, free and don't use any slot), and then [send a pull request](https://help.github.com/articles/using-pull-requests) to the central repository for the administrator to review, discuss and merge.

See for example the organization account of the ["The Lab for Data Intensive Biology" led by Dr. C. Titus Brown](https://github.com/dib-lab) where they share code, documentation and papers. Open Science!!

Other suggestions on the setup very welcome!
