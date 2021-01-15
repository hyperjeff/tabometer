# tabometer ![Tabometer Screenshot](https://github.com/hyperjeff/tabometer/blob/main/95-20.png)
Menubar tab counter for Safari on macOS.

"T" = tabs, "W" = windows. Just a simple report of your Safari tab/window situation on your Mac. Sometimes things get out of control and you don't even realize the extent of the problem. Updates every 30 seconds.

Probably could just make a system service or Safari plugin to do this, but this continues to work even if Safari isn't running.

## Installation
There are binaries to download, or you can build and run via Xcode. Works back to macOS 10.14 (Catalina).

The only small inconvenience about running this app is that the user _must_ select their Safari `LastSession.plist` file for it to be used by this app. The app makes this as easy as I know how to do: An open file dialog is presented to the user on first launch, and it auto-selects the file it needs, and just asks the user to press the `[Select]` button. Once this is done, the user never has to do it again on that machine. (If you pick the wrong file because you don't like being told what or how to do things, then you'll just get a new dialog asking for the same thing until you comply.)

## Building
If you want to build from source, just make sure to put in your own bundle identifier and developer team and it should build just fine.

## Future directions
This is a super minimal project. ~100 lines of code. But it could go into a lot of decent directions without bloating too much. Here are some ideas, in case you'd like to contribute to the project:

* Talk to other instances living on the local network to give an overall measure of the tab counts.
* Figure out a way to find out the entire current tab situation across one's whole iCloud account.
* Think up some clever functionality to add to the menu.

If it's at all useful to you, great!

-jeff
