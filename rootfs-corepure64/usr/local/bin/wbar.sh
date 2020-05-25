#!/bin/sh
. /etc/init.d/tc-functions
WORK=/tmp/work$$
cd "$HOME"
[ -n "$ICONS" ] || ICONS=`cat /etc/sysconfig/icons`
if [ "$ICONS" == "wbar" ]; then
   WBARPID=$(pidof wbar)
   [ -n "$WBARPID" ] && killall wbar
   if [ -e .wbarconf ]; then
      replace .wbarconf /usr/local/tce.icons 'c: wbar' > "$WORK"
      sudo mv "$WORK" /usr/local/tce.icons
   fi
   nohup wbar >/dev/null &

   # It has to be fully started, or it would get killed by the parent dying
   for i in `seq 100`; do
      pidof wbar > /dev/null && break
      sleep 0.02
   done
fi
