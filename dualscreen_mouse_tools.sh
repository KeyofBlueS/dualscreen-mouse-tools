#!/bin/bash

# Version:    1.1.2
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/dualscreen-mouse-tools
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

#echo -n "Checking dependencies... "
for name in awk perl xdotool xdpyinfo
do
  [[ $(which $name 2>/dev/null) ]] || { echo -e "\n$name is required by this script. Use 'sudo apt-get install $name'
Install the requested dependencies and restart this script"; exit 1; }
done

for name in curl
do
  [[ $(which $name 2>/dev/null) ]] || { echo -e "\n$name it's recommended in order to perform updates. Use 'sudo apt-get install $name'
If you prefer, install the requested dependencies and restart this script"; }
done

echo $@ | grep -Poq '\d+'
if [ $? = 0 ]; then
	DELAY="$(echo $@ | grep -Po '\d+')"
else
	DELAY=10
fi

start(){
for pid in $(pgrep "dualscreenmouse"); do
    if [ $pid != $$ ]; then
        kill -15 $pid
	pkill -15 -f "xdotool behave_screen_edge*"
	exit 0
    fi 
done

SLEEPTIME="$(perl -e "print $DELAY / 1000 + 0.255")"

SCREEN0_RESOLUTION="$(xdpyinfo | grep -A2 '^screen #0' | grep 'dimensions:' | awk -F: '{print $2}' | awk -F' ' '{print $1}')"
SCREEN0_XRESOLUTION="$(echo $SCREEN0_RESOLUTION | awk -Fx '{print $1}')"
SCREEN0_YRESOLUTION="$(echo $SCREEN0_RESOLUTION | awk -Fx '{print $2}')"
SCREEN0_XCENTER="$(perl -e "print $SCREEN0_XRESOLUTION / 2")"
#SCREEN0_YCENTER="$(perl -e "print $SCREEN0_YRESOLUTION / 2")"
#SCREEN0_XRESOLUTION_PERCENT="$(perl -e "print $SCREEN0_XRESOLUTION / 100")"
SCREEN0_YRESOLUTION_PERCENT="$(perl -e "print $SCREEN0_YRESOLUTION / 100")"

SCREEN1_RESOLUTION="$(xdpyinfo | grep -A2 '^screen #1' | grep 'dimensions:' | awk -F: '{print $2}' | awk -F' ' '{print $1}')"
SCREEN1_XRESOLUTION="$(echo $SCREEN1_RESOLUTION | awk -Fx '{print $1}')"
SCREEN1_YRESOLUTION="$(echo $SCREEN1_RESOLUTION | awk -Fx '{print $2}')"
SCREEN1_XCENTER="$(perl -e "print $SCREEN1_XRESOLUTION / 2")"
#SCREEN1_YCENTER="$(perl -e "print $SCREEN1_YRESOLUTION / 2")"
#SCREEN1_XRESOLUTION_PERCENT="$(perl -e "print $SCREEN1_XRESOLUTION / 100")"
SCREEN1_YRESOLUTION_PERCENT="$(perl -e "print $SCREEN1_YRESOLUTION / 100")"
chekscreen
}

chekscreen(){
eval $(xdotool getmouselocation --shell)
if [ $SCREEN -eq 0 ]; then
	CURRENTSCREEN_YRESOLUTION=$SCREEN0_YRESOLUTION
	CURRENTSCREEN_XCENTER=$SCREEN0_XCENTER
	NEXTSCREEN_XRESOLUTION=$SCREEN1_XRESOLUTION
	NEXTSCREEN_YRESOLUTION_PERCENT=$SCREEN1_YRESOLUTION_PERCENT
	NEXTSCREEN=1
else
	CURRENTSCREEN_YRESOLUTION=$SCREEN1_YRESOLUTION
	CURRENTSCREEN_XCENTER=$SCREEN1_XCENTER
	NEXTSCREEN_XRESOLUTION=$SCREEN0_XRESOLUTION
	NEXTSCREEN_YRESOLUTION_PERCENT=$SCREEN0_YRESOLUTION_PERCENT
	NEXTSCREEN=0
fi
$CROSSTYPE
}

crossedge_side(){
NEXTSCREEN_YMOUSECOORDINATE="$(perl -e "print $Y * 100 / $CURRENTSCREEN_YRESOLUTION * $NEXTSCREEN_YRESOLUTION_PERCENT")"
if [ $SCREEN -ne $SIDE ]; then
	NEXTSCREEN_XMOUSECOORDINATE=0
	pkill -15 -f "xdotool behave_screen_edge*"
	xdotool behave_screen_edge --delay $DELAY right mousemove --screen $NEXTSCREEN $NEXTSCREEN_XMOUSECOORDINATE $NEXTSCREEN_YMOUSECOORDINATE > /dev/null &
else
	NEXTSCREEN_XMOUSECOORDINATE=$NEXTSCREEN_XRESOLUTION
	pkill -15 -f "xdotool behave_screen_edge*"
	xdotool behave_screen_edge --delay $DELAY left mousemove --screen $NEXTSCREEN $NEXTSCREEN_XMOUSECOORDINATE $NEXTSCREEN_YMOUSECOORDINATE > /dev/null &
fi
sleep $SLEEPTIME
chekscreen
}

crossedge_both(){
NEXTSCREEN_YMOUSECOORDINATE="$(perl -e "print $Y * 100 / $CURRENTSCREEN_YRESOLUTION * $NEXTSCREEN_YRESOLUTION_PERCENT")"
if [ $X -gt $CURRENTSCREEN_XCENTER ]; then
	NEXTSCREEN_XMOUSECOORDINATE=0
	pkill -15 -f "xdotool behave_screen_edge*"
	xdotool behave_screen_edge --delay $DELAY right mousemove --screen $NEXTSCREEN $NEXTSCREEN_XMOUSECOORDINATE $NEXTSCREEN_YMOUSECOORDINATE > /dev/null &
else
	NEXTSCREEN_XMOUSECOORDINATE=$NEXTSCREEN_XRESOLUTION
	pkill -15 -f "xdotool behave_screen_edge*"
	xdotool behave_screen_edge --delay $DELAY left mousemove --screen $NEXTSCREEN $NEXTSCREEN_XMOUSECOORDINATE $NEXTSCREEN_YMOUSECOORDINATE > /dev/null &
fi
sleep $SLEEPTIME
chekscreen
}

teleport(){
eval $(xdotool getmouselocation --shell)
echo "X=$X
Y=$Y" > /tmp/dualscreen_mouse_tools_coordinates_$SCREEN &
if [ $SCREEN -eq 0 ]; then
	NEXTSCREEN=1
else
	NEXTSCREEN=0
fi
if echo $REMEMBER | grep -q 'no'; then
	xdotool mousemove --screen $NEXTSCREEN --polar 0 0 > /dev/null
else
	if grep -Poq '\d+' /tmp/dualscreen_mouse_tools_coordinates_$NEXTSCREEN; then
		OLDX="$(grep "X" /tmp/dualscreen_mouse_tools_coordinates_$NEXTSCREEN | grep -Po '\d+')"
		OLDY="$(grep "Y" /tmp/dualscreen_mouse_tools_coordinates_$NEXTSCREEN | grep -Po '\d+')"
		xdotool mousemove --screen $NEXTSCREEN $OLDX $OLDY > /dev/null
	else
		xdotool mousemove --screen $NEXTSCREEN --polar 0 0 > /dev/null
	fi
fi
#if pgrep -x "compiz" > /dev/null; then
#	xdotool key "super+k" && sleep 0.8 && xdotool key "super+k"
#fi
exit 0
}

exitstep(){
kill $$ & pkill -15 -f "xdotool behave_screen_edge*"
exit 0
}

update(){
echo -e "\e[1;34mCheck for updates...\e[0m"
if curl -s github.com > /dev/null; then
	SCRIPT_LINK="https://raw.githubusercontent.com/KeyofBlueS/dualscreen-mouse-tools/master/dualscreen_mouse_tools.sh"
	UPSTREAM_VERSION="$(timeout -s SIGTERM 15 curl -L "$SCRIPT_LINK" 2> /dev/null | grep "# Version:" | head -n 1)"
	LOCAL_VERSION="$(cat "${0}" | grep "# Version:" | head -n 1)"
	REPOSITORY_LINK="$(cat "${0}" | grep "# Repository:" | head -n 1)"
	if echo "$LOCAL_VERSION" | grep -q "$UPSTREAM_VERSION"; then
		echo -e "\e[1;32m
## This script is synced with upstream version
\e[0m
"
	else
		echo -e "\e[1;33m-----------------------------------------------------------------------------------	
## WARNING: this script is not synced with upstream version, visit:
\e[1;32m$REPOSITORY_LINK

\e[1;33m$LOCAL_VERSION (locale)
\e[1;32m$UPSTREAM_VERSION (upstream)
\e[1;33m-----------------------------------------------------------------------------------

\e[1;35mHit ENTER to update this script or wait 10 seconds to exit
\e[1;31m## WARNING: any custom changes will be lost!!!
\e[0m
"
		if read -t 10 _e; then
			echo -e "\e[1;34m	Updating...\e[0m"
			if [[ -L "${0}" ]]; then
				scriptpath="$(readlink -f "${0}")"
			else
				scriptpath="${0}"
			fi
			if [ -z "${scriptfolder}" ]; then
				scriptfolder="${scriptpath}"
				if ! [[ "${scriptpath}" =~ ^/.*$ ]]; then
					if ! [[ "${scriptpath}" =~ ^.*/.*$ ]]; then
					scriptfolder="./"
					fi
				fi
				scriptfolder="${scriptfolder%/*}/"
				scriptname="${scriptpath##*/}"
			fi
			if timeout -s SIGTERM 15 curl -s -o /tmp/"${scriptname}" "$SCRIPT_LINK"; then
				if [[ -w "${scriptfolder}${scriptname}" ]] && [[ -w "${scriptfolder}" ]]; then
					mv /tmp/"${scriptname}" "${scriptfolder}"
					chown root:root "${scriptfolder}${scriptname}" > /dev/null 2>&1
					chmod 755 "${scriptfolder}${scriptname}" > /dev/null 2>&1
					chmod +x "${scriptfolder}${scriptname}" > /dev/null 2>&1
				elif which sudo > /dev/null 2>&1; then
					echo -e "\e[1;33mIn order to update you must grant root permissions\e[0m"
					sudo mv /tmp/"${scriptname}" "${scriptfolder}"
					sudo chown root:root "${scriptfolder}${scriptname}" > /dev/null 2>&1
					sudo chmod 755 "${scriptfolder}${scriptname}" > /dev/null 2>&1
					sudo chmod +x "${scriptfolder}${scriptname}" > /dev/null 2>&1
				else
					echo -e "\e[1;31m	Error during update!
Permission denied!
\e[0m"
				fi
			else
				echo -e "\e[1;31m	Download error!
\e[0m"
			fi
			LOCAL_VERSION="$(cat "${0}" | grep "# Version:" | head -n 1)"
			if echo "$LOCAL_VERSION" | grep -q "$UPSTREAM_VERSION"; then
				echo -e "\e[1;34m	Fatto!
\e[0m"
				exec "${scriptfolder}${scriptname}"
			else
				echo -e "\e[1;31m	Error during update!
\e[0m"
			fi
		fi
	fi
fi
exit 0
}

givemehelp(){
echo '
# dualscreen-mouse-tools

# Version:    1.1.2
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/dualscreen-mouse-tools
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

### DESCRIPTION
This bash script uses xdotool to easly enable\disable crossing the mousepointer between two "really separated" xscreens (screen 0 and screen 1) when it reach a side edge of screen, it can even teleport the mouse pointer from one screen to the other.
This script is based and mimics the operation of the (sadly unmaintained) good old dualscreen-mouse-utils, so thanks to it`s developers.

In order for this tool to work, screens must be configured in xorg.conf (usually in /etc/X11/xorg.conf) to be independent and separated. Let`s say that Screen 0 is 1920x1080 and Screen 1 is 1280x1024, Screen 1 is on the left of Screen 0. To "separate" the screens, Screen 0 MUST be far from Screen 1 AT LEAST the value of Screen 1 width+1 (1281), so 3000 is fine:

Section "ServerLayout"
    Identifier     "Layout0"
    Screen      0  "Screen0" 3000 0
    Screen      1  "Screen1" 0 0
EndSection

The example below shows the same setup as before but Screen 1 is on the right of Screen 0. Screen 1 is far from Screen 0 the value of Screen 0 width+1 (1921, but 3000 would still be fine yet):

Section "ServerLayout"
    Identifier     "Layout0"
    Screen      0  "Screen0" 0 0
    Screen      1  "Screen1" 1921 0
EndSection

This configuration is necessary to be able to lock the mouse pointer inside one screen, which would otherwise be free to travel to the other one.
For just the "teleport" feature, there is no need to do any configuration in xorg.conf.


### USAGE

From terminal:

$ dualscreenmouse

You can create a launcher or bind to a keyboard key.

Options for crossing edges:
You can define the relation of the screens, if you want the cursor to only pass one edge:
--left			Screen 1 is left of screen 0

--right			Screen 1 is rigt of screen 0

--both			Pass cursor on both the left and the right edge (default)

--resistance <n>	Mouse pointer has an edge resistance of <n> milliseconds when crossing from one screen to the other (default 10)


Options for switching screens:
--switch		Teleport the mouse pointer from the center of one screen to the center of the other screen

--switch-remember	Teleport the mouse pointer from one screen to the other screen, remembering last position if exist


Other options:
--update		Check for updates

--help			Show description and help of dualscreen-mouse-tools
'
exit 0
}

trap exitstep INT


if [ "$1" = "--left" ]; then
	SIDE=0
	CROSSTYPE=crossedge_side
	start
elif [ "$1" = "--right" ]; then
	SIDE=1
	CROSSTYPE=crossedge_side
	start
elif [ "$1" = "--both" ]; then
	CROSSTYPE=crossedge_both
	start
elif [ "$1" = "--switch" ]; then
	REMEMBER=no
	teleport
elif [ "$1" = "--switch-remember" ]; then
	teleport
elif [ "$1" = "--help" ]; then
	givemehelp
elif [ "$1" = "--update" ]; then
	update
elif [ "$1" = "--exit" ]; then
	exitstep
else
	CROSSTYPE=crossedge_both
	start
fi
