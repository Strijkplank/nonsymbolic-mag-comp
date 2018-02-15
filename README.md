# Installation instructions 

Before you install the task script please ensure that PsychToolBox is installed. The PsychToolBox installation instructions are available on the [PsychToolBox website](http://psychtoolbox.org). However, I have also written an easy installation script available at [http://git.colling.net.nz/ptb/](http://git.colling.net.nz/ptb/).

Make sure you're connected to the internet

In `MATLAB` select the folder where you want to store your script e.g.
`c:\USER\Documents\MATLAB\scripts` on `WINDOWS` or
`/Users/USER/Documents/Matlab/scripts` on `MAC OS` or `LINUX`

There are now two versions of the task. The commands you type will be different depending on the version you want (you can also get both versions if you want).

## Long version

At the matlab prompt type
> `unzip('https://github.com/ljcolling/nonsymbolic-mag-comp/archive/Long-version.zip')`

This will download the files to a new folder called `nonsymbolic-mag-comp-Long-version` inside your scripts folder.

Navigate to this folder with the command
> `cd nonsymbolic-mag-comp-Long-version`

## Short version

At the matlab prompt type
> `unzip('https://github.com/ljcolling/nonsymbolic-mag-comp/archive/Short-version.zip')`

This will download the files to a new folder called `nonsymbolic-mag-comp-Short-version` inside your scripts folder.

Navigate to this folder with the command
> `cd nonsymbolic-mag-comp-Short-version`


## Setup instructions

Before you can run the experiment there are two set up stages. For stage 2 you'll need a tape measure. You'll only need to do the setup once on each computer you use. 

1. To setup the keyboard type
> `DoKeyboardSetup`

2. To do the monitor setup type
> `DoMonitorSetup`

# Running the script

After you've done the setup you can run the experiment by typing:
> `DoNonsymExpt`
