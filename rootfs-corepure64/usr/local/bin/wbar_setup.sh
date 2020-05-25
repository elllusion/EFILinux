#!/bin/sh
#(c) Robert Shingledecker 2009-2012
. /etc/init.d/tc-functions

TCEDIR=/etc/sysconfig/tcedir
[ -L "$TCEDIR" ] || exit 1

TCEWBAR="/usr/local/tce.icons"

read USER < /etc/sysconfig/tcuser
WBARICONS=/home/"$USER"/.wbar
[ -L "$WBARICONS" ] || ln -s "$TCEWBAR" "$WBARICONS"

[ -e "$TCEWBAR" ] && sudo rm -rf "$TCEWBAR"
sudo cp /usr/local/share/wbar/dot.wbar "$TCEWBAR"
sudo chown root.staff "$TCEWBAR"
sudo chmod g+w "$TCEWBAR"

XWBAR=${TCEDIR}/xwbar.lst
if [ ! -e "$XWBAR" ]; then
	touch "$XWBAR"
	chown "$USER".staff "$XWBAR"
	chmod 664 "$XWBAR"
fi

for F in "exittc" "xterm" "editor" "cpanel" "apps" "scmapps" "flrun" "mnttool"
do
	wbar_update.sh "tinycore-$F"
done	

SYSWBAR=/usr/local/share/wbar/dot.wbar
if [ -s "$XWBAR" ]; then
  for F in `awk '/t: /{print $2}' < ${SYSWBAR}` ; do
    if grep -qw "$F" ${XWBAR}; then
      wbar_rm_icon "$F"
    fi
  done
fi

if [ ! -e /etc/sysconfig/noondemandicons ]; then
INSTALLED=/usr/local/tce.installed
ONDEMAND="$TCEDIR"/ondemand
for F in `ls -1 "$ONDEMAND"/*.img 2>/dev/null`; do
  IMG="${F##/*/}"
  APPNAME="${IMG%.img}"
  if [ ! -e "$INSTALLED"/"$APPNAME" ]; then
    if ! grep -qw "^t: *${APPNAME}$" "${TCEDIR}"/xwbar.lst 2>/dev/null; then
      echo "i: $ONDEMAND/$IMG" >> "$TCEWBAR"
      echo "t: $APPNAME" >> "$TCEWBAR"
      echo "c: $ONDEMAND/$APPNAME" >> "$TCEWBAR"
    fi
  fi
done
fi
