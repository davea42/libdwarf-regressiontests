#
# Setting up /usr/bin/time recording.
bdir=.
otimeout=$bdir/junktimeouto
ntimeout=$bdir/junktimeoutn
wrtimeo="/usr/bin/time -o $otimeout -a -p "
wrtimen="/usr/bin/time -o $ntimeout -a -p "
/usr/bin/time -o /tmp/timeout echo x >/dev/null 2>/dev/null
if [ $? -ne 0 ]
then
  # Without the -o -a options we give up on this timing info
  wrtimeo=
  wrtimen=
  echo "/usr/bin/time data........: not being recorded"
else
  echo "/usr/bin/time data in.....: $otimeout and $ntimeout"
  echo "time command..............: $wrtimeo"
  echo "time command..............: $wrtimen"
fi
