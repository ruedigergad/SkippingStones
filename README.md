## SkippingStones ##

tldr: SkippingStones can be seen as an app for using Pebble smart watches, e.g., on the Jolla smartphones.

To be more precise, SkippingStones is an attempt on creating a QML implementation of the protocol as used by the Pebble smart watches.

For the implementation of the Pebble protocol in QML, the great Python implementation of the Pebble protocol by Hexxeh is used as reference: https://github.com/Hexxeh/libpebble/blob/master/pebble/pebble.py

### More Information and "Support" ###

You can get a little more information about SkippingStones in my blog: http://ruedigergad.com/category/my-applications/skippingstones/

For "support", there is a discussion thread at talk.maemo.org about Pebble and SkippingStones: http://talk.maemo.org/showthread.php?t=92976

### Download/Installation ###

Readily build RPMs for SailfishOS/Jolla are available at two locations:

https://github.com/ruedigergad/SkippingStones/tree/master/dist

https://openrepos.net/content/ruedigergad/skippingstones


### Why QML? ###

One important goal of SkippingStones is to provide good and easy "hackability"; i.e., offer very easy possibilities to hack and experiment with the code and the protocol etc.
As QML does not need to be recompiled and thus it is even possible to play with the implementation on the smartphone while commuting the choice was to implement most parts of SkippingStones in QML.


### "Architecture" ###

Essentially, SkippingStones can be divided into two parts: on the one hand a Pebble protocol implementation and on the other hand everything else.
Everything else besides the protocol implementation would be usually a platform specific backend for interacting with notifications systems and other apps and a GUI for the user interaction.

Right now, there is only a SailfishOS/Jolla app that combines the protocol implementation, the platform specific backend, and the GUI in one single app.


