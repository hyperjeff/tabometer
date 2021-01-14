# tabometer ![Tabometer Screenshot](https://github.com/hyperjeff/tabometer/blob/main/95-20.png)
Menubar tab counter for macOS.

"T" = tabs, "W" = windows. Just a simple report of the situation on your Mac. Sometimes things get out of control and you don't even realize the extent of the problem. Updates every 30 seconds.

## Installation
There are binaries to download, or you can build and run via Xcode. Works back to macOS 10.14 (Catalina).

_BUT_, because of sandboxing, currently there is a hack to make this all work. There is a `tabometer.sh` script that needs to be installed somewhere (`/usr/local/bin/` or `~/bin` etc) and make it executable (`chmod +x tabometer.sh`) and then run it in the background via Terminal (`tabometer &`). This copies the key file from Safari so that it can be inspected by the Tabometer menu bar app.

## Future directions
This is a super minimal project. ~100 lines of code. But it could go into a lot of decent directions without bloating too much. Here are some ideas, in case you'd like to contribute to the project:

* Add some better instructions in this readme or the wiki.
* Have it start/stop the background helper script on its own.
* Find a way to get around the sandbox limitation and directly examine the Safari session file.
* Talk to other instances living on the local network to give an overall measure of the tab counts.
* Figure out a way to find out the entire current tab situation across one's whole iCloud account.
* Think up some clever functionality to add to the menu.

If it's at all useful to you, great!
-jeff
