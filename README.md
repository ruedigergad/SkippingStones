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


### License ###
SkippingStones is largely based on libpebble by Liam McLoughlin (https://github.com/Hexxeh/libpebble). 
SkippingStones is published under the same license as libpebble (as of 10-02-2014):
```
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```
