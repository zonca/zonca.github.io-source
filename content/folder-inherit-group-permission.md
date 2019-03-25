Title: Inherit group permission in folder
Date: 2019-03-24 18:00
Author: Andrea Zonca
Tags: jupyter, jetstream, zarr
Slug: folder-inherit-group-permission

I have googled this so many times...

On shared systems, like Supercomputers, you often belong to many different Unix
groups, and that membership allows you to access data from specific projects you
are working on and you can share data with your collaborators.

If you set SGID on a folder, any folder of file created in that folder will automatically
belong to the Unix group of that folder, and not your default group.
You first set the right group on the folder, recursively so that older files will get
the right permissions:

    chown -R somegroup sharedfolder

Then you set the SGID so future files will automatically belong to `somegroup`:

    chmod g+s sharedfolder

This is very useful for example in the `/project` filesystem at NERSC, you can set
the SGID so that every file that is copied to the shared `/project` filesystem is
accessible by other collaborators.

Related to this is also the default `umask`, most systems by default give "read" permission
for the group, so setting SGID is enough, otherwise it is also necessary to configure `umask` properly.
