# dualscreen-mouse-tools

# Version:    1.0.0
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/dualscreen-mouse-tools
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

### DESCRIPTION
This bash script uses xdotool to make possible to easly enable\disable crossing the mousepointer between two "really separated" xscreens (screen 0 and screen 1) when it reach a side edge of screen. In order for this tool to work, screens must be configured to something like this in xorg.conf:
```
Section "ServerLayout"
        Identifier      "Default Layout"
        Screen          0 "Screen 0" 3000 0
        Screen          1 "Screen 1" 0 0 #leftOf "Screen 0"
EndSection
```
This script is based and mimics the operation of the (sadly unmaintained) good old dualscreen-mouse-utils, so thanks to it's developers.

### INSTALL
```sh
curl -o /tmp/dualscreen_mouse_tools.sh 'https://raw.githubusercontent.com/KeyofBlueS/dualscreen-mouse-tools/master/dualscreen_mouse_tools.sh'
sudo mkdir -p /opt/dualscreen-mouse-tools/
sudo mv /tmp/dualscreen_mouse_tools.sh /opt/dualscreen-mouse-tools/
sudo chown root:root /opt/dualscreen-mouse-tools/dualscreen_mouse_tools.sh
sudo chmod 755 /opt/dualscreen-mouse-tools/dualscreen_mouse_tools.sh
sudo chmod +x /opt/dualscreen-mouse-tools/dualscreen_mouse_tools.sh
sudo ln -s /opt/dualscreen-mouse-tools/flash_update.sh /usr/local/bin/dualscreenmouse
```
### USAGE
From terminal:
```sh
$ flashupdate
```
You can create a launcher or bind to a keyboard key.

Options:
```
--resistance <n>	Mouse pointer has an edge resistance of <n> when crossing from one screen to the other (default 10)

--switch		Teleport the mouse pointer from one screen to the other

--help			Show description and help of dualscreen-mouse-tools

--update		Check for updates

You can define the relation of the screens, if you want the cursor to only pass one edge:
--left			Screen 1 is left of screen 0

--right			Screen 1 is rigt of screen 0

--both			Pass cursor on both the left and the right edge (default)
```
