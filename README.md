# dualscreen-mouse-tools

# Version:    1.2.6
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/dualscreen-mouse-tools
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

### DESCRIPTION
This bash script uses xdotool to easly enable\disable crossing the mousepointer between two "really separated" xscreens (screen 0 and screen 1) when it reach a side edge of screen, it can even teleport the mouse pointer from one screen to the other.
This script is based and mimics the operation of the (sadly unmaintained) good old dualscreen-mouse-utils, so thanks to it's developers.

In order for this tool to work, screens must be configured in xorg.conf (usually in /etc/X11/xorg.conf) to be independent and separated. Let's say that Screen 0 is 1920x1080 and Screen 1 is 1280x1024, Screen 1 is on the left of Screen 0. To "separate" the screens, Screen 0 MUST be far from Screen 1 AT LEAST the value of Screen 1 width+1 (1281), so 3000 is fine:
```
Section "ServerLayout"
    Identifier     "Layout0"
    Screen      0  "Screen0" 3000 0
    Screen      1  "Screen1" 0 0
EndSection
```
The example below shows the same setup as before but Screen 1 is on the right of Screen 0. Screen 1 is far from Screen 0 the value of Screen 0 width+1 (1921, but 3000 would still be fine yet):
```
Section "ServerLayout"
    Identifier     "Layout0"
    Screen      0  "Screen0" 0 0
    Screen      1  "Screen1" 1921 0
EndSection
```
This configuration is necessary to be able to lock the mouse pointer inside one screen, which would otherwise be free to travel to the other one.
For just the "teleport" feature, there is no need to do any configuration in xorg.conf.

### INSTALL
Install git:
```sh
sudo apt-get install git
```
Then:
```sh
git clone -b master https://github.com/KeyofBlueS/dualscreen-mouse-tools /tmp/dualscreen-mouse-tools
sudo mkdir -p /opt/dualscreen-mouse-tools/
sudo mv /tmp/dualscreen-mouse-tools/dualscreen_mouse_tools.sh /opt/dualscreen-mouse-tools/
sudo chown root:root /opt/dualscreen-mouse-tools/dualscreen_mouse_tools.sh
sudo chmod 755 /opt/dualscreen-mouse-tools/dualscreen_mouse_tools.sh
sudo chmod +x /opt/dualscreen-mouse-tools/dualscreen_mouse_tools.sh
sudo ln -s /opt/dualscreen-mouse-tools/dualscreen_mouse_tools.sh /usr/local/bin/dualscreenmouse
rm -rf /tmp/dualscreen-mouse-tools
```
### USAGE

From terminal:
```sh
$ dualscreenmouse
```
You can create a launcher or bind it to a keyboard key.
```
Options for crossing edges:
You can define the relation of the screens, if you want the cursor to only pass one edge:
--left -l	    	Screen 1 is left of screen 0

--right -r  		Screen 1 is rigt of screen 0

--both -b		Pass cursor on both the left and the right edge (default)

--resistance n -d n	Mouse pointer has an edge resistance of <n> milliseconds when crossing from one screen to the other (default 0)


Options for switching screens:
--switch -s		Teleport the mouse pointer from one screen to the center of the other screen

--switch-remember -w	Teleport the mouse pointer from one screen to the other screen, remembering last position if exist


Other options:
--update -u		Check for updates

--help -h		Show description and help of dualscreen-mouse-tools
```
