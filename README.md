# tabometer ![Tabometer Screenshot](https://github.com/hyperjeff/tabometer/blob/main/95-20.png)
Menubar tab counter for Safari on macOS.

## _IMPORTANT:_
As of Safari 15.0, the `LastSession.plist` file, which is the entire basis of this little app, stopped being used by Safari. (You may have noticed that many people lost all the tabs that were previously opened when they updated it.) So this app currently only works for Macs on Safari 14.x and lower.

---

"T" = tabs, "W" = windows. Just a simple report of your Safari tab/window situation on your Mac. Sometimes things get out of control and you don't even realize the extent of the problem. Updates every 30 seconds.

Probably could just make a system service or Safari plugin to do this, but this continues to work even if Safari isn't running.

## Demo Code
Even if you have no interest in this app per se, it does demo a few things in a very simple way so that you can carve up the code to make your own menubar app. In particular it shows how to:

* Construct a simple menu bar app with a custom view on top
* Access and use an otherwise off-limits file in a sandboxed app
* Basic parsing of the Safari LastSession.plist file
* Use CloudKit's key-value stores for coordinating info among several Macs

Could the code be better? I'm sure! Be my guest. But it's not bad, and only involves 3 simple objects.

## Installation
There are binaries to download, or you can build and run via Xcode. Works from macOS 10.14 (Catalina) to macOS 11.x (Big Sur).

The only small inconvenience about running this app is that the user _must_ select their Safari `LastSession.plist` file for it to be used by this app. The app makes this as easy as I know how to do: An open file dialog is presented to the user on first launch, and it auto-selects the file it needs, and just asks the user to press the `[Select]` button. Once this is done, the user never has to do it again on that machine. (If you pick the wrong file because you don't like being told what or how to do things, then you'll just get a new dialog asking for the same thing until you comply.)

## Building
If you want to build from source, just make sure to put in a bundle identifier and developer team and from there it should build and run just fine. You may also have to enable your Mac for development signing (just a press of a button).

## Future directions
This is a fairly minimal project, weighing in at ~400 lines of code. It could go into a lot of decent directions. Here are some ideas, in case you'd like to contribute:

* Figure out a way to find out the entire current tab situation across one's whole iCloud account
* Parse the url, title info about the tabs to some ends (that isn't already done well by Safari)
* Offline download and/or process the webpages to some ends

If it's at all useful to you, great!

-jeff
