Title: Software Carpentry setup for Chromebook
Date: 2015-02-10 20:00
Author: Andrea Zonca
Tags: software-carpentry, chromebook, ipython
Slug: software-carpentry-setup-chromebook

In this post I'll provide instructions on how to install the main requirements of a [Software Carpentry workshop](http://software-carpentry.org) on
a Chromebook.
Bash, git and IPython notebook.

## Switch the Chromebook to Developer mode

ChromeOS is very restrictive on what users can install on the machine.
The only way to get around this is to switch to developer mode.

Switching to Developer mode **wipes** all the data on the local disk and 
may void warranty, do it at your own risk.

Instructions are available on the [ChromeOS wiki](http://www.chromium.org/chromium-os/developer-information-for-chrome-os-devices), you need
to click on your device name and follow instructions.
For most devices you need to switch the device off, then hold down``ESC` and `Refresh` and poke the `Power` button, then press `Ctrl-D` at the
Recovery screen (there is no prompt, you have to know to do it).
This will wipe the device and activate Developer mode.

Once you reboot and enter your Google credentials, the Chromebook will copy back from Google servers all of your settings.

Now you are in Developer mode, the main feature is that you have a `root` (superuser) shell you can activate using `Ctrl-Alt-t`.

The worst issue of Developer mode is that at each boot the system will display a scary screen warning that OS verification is off and asks you if you would like to leave Developer
mode. If you either press `Ctrl-D` or wait 30 seconds, it will boot ChromeOS in Developer mode, if you instead hit the Space, it will wipe
everything and switch back to Normal mode.

## Install Ubuntu with crouton

You can now install Ubuntu using [crouton](https://github.com/dnschneid/crouton), you can read the instructions on the page, in summary:

* First you need to install the [Crouton Chrome extension](https://goo.gl/OVQOEt) on ChromeOS
* Download the last release from <https://goo.gl/fd3zc>
* Open the ChromeOS shell using `Ctrl-Alt-t`, digit `shell` at the prompt and hit enter
* Run `sudo sh ~/Downloads/crouton -t xfce -r trusty,xiwi`, this instlls Ubuntu Trutyty with xfce desktop and uses `kiwi` to be able to run in a window.

Now you can have Ubuntu running in a window of the Chromebook browser by:

* Press `Ctrl-Alt-T`
* digit `shell` at the prompt and hit enter
* digit `sudo startxfce4`

## Install scientific computing stack

You can now follow the instructions for linux at <http://software-carpentry.org/v5/setup.html>, summary of commands to run in a terminal:

* `sudo apt install nano`
* `sudo apt install git`
* In order to install R `sudo apt install r-base`
* Download Anaconda Python 2.7 64bit for Linux from <http://continuum.io/downloads> and execute it

Anaconda will run under Ubuntu but when you open an IPython notebook, it will automatically open a new tab in the main browser of ChromeOS, not
inside the Ubuntu window.

## Final note

I admit it looks scary, I prsonally followed this procedure osuccessfully on 2 chromebooks: Samsung Chromebook 1 and Toshiba Chromebook 2. 

It is also possible to switch the Chromebook to Developer mode and install Anaconda and git directly there, however I think that in order to have
a complete platform for scientific computing is a lot better to have all of the packages provided by Ubuntu.
