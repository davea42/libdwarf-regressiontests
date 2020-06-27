#!/usr/bin/python3
#
#  Report on the timings in an ALLdd file
#  to try to figure out what is slow
# 

import sys
import os
import datetime
from datetime import timedelta
from datetime import datetime


#=====START Pct   0  -a  kapus/bad.obj
#old start  Fri Jun 26 16:51:29 PDT 2020
#old done  Fri Jun 26 16:51:29 PDT 2020
#new start  Fri Jun 26 16:51:29 PDT 2020
#new done  Fri Jun 26 16:51:29 PDT 2020
#Fri Jun 26 16:51:29 PDT 2020
#=====START Pct   0 --print_raw_rnglists  moya2/filecheck.dwo
#old start  Fri Jun 26 16:51:29 PDT 2020
#old done  Fri Jun 26 16:51:29 PDT 2020
#new start  Fri Jun 26 16:51:29 PDT 2020
#new done  Fri Jun 26 16:51:29 PDT 2020
#Fri Jun 26 16:51:29 PDT 2020
#=====START Pct   0  -ka --print_raw_rnglists  moya2/filecheck.dwo
# Compute the seconds from old start to new done
# Compute the seconds from new done to old start.
# Compute the seconds from the very first old start
# to the very last new done.


class xtime:
  def __init__(self):
    self._firstostart = False
    self._lastnewdone = False
    self._curostart = False
    self._curndone = False

mdict = { "Jan":"01", "Feb":"02", "Mar":"03", "Apr":"04", 
"May":"05", "Jun":"06", "Jul":"07", "Aug":"08",
"Sep":"09", "Oct":"10", "Nov":"11", "Dec":"12" }

def twodigday(d):
  ds = str(d)
  if len(ds) < 2:
    ds = " "+ds
  return ds

def extractdate(rec):
  wds = rec.split()
  mt = wds[3]
  month = mdict[mt]
  day = twodigday(wds[4])
  year = wds[7]
  tm = wds[5]
  ds = str(year) + '-' + month + day 
  return ds + ' ' +tm


def recordcurrent(rec,xt):
  if rec.startswith("old start "):
    dtxt = extractdate(rec)
    #dt = datetime.fromisoformat(dtxt)
    return True
  if rec.startswith("old done "):
    dtxt = extractdate(rec)
    #dt = datetime.fromisoformat(dtxt)
    return True
  if rec.startswith("new start "):
    dtxt = extractdate(rec)
    #dt = datetime.fromisoformat(dtxt)
    return True
  if rec.startswith("new done "):
    dtxt = extractdate(rec)
    #dt = datetime.fromisoformat(dtxt)
    return True
  return False


def isdateitem(rec):
  if rec.startswith("old start "):
    return True
  if rec.startswith("old done "):
    return True
  if rec.startswith("new start "):
    return True
  if rec.startswith("new done "):
    return True
  if rec.startswith("Mon "):
    return True
  if rec.startswith("Tue "):
    return True
  if rec.startswith("Wed "):
    return True
  if rec.startswith("Thu "):
    return True
  if rec.startswith("Fri "):
    return True
  if rec.startswith("Sat "):
    return True
  if rec.startswith("Sun "):
    return True
  return False

def printoverall(xt):
  print("FIXME")

if __name__ == '__main__':
  fn="ALLdd"
  fn="timereport.txt"
  if len(sys.argv) >1:
    fn = sys.argv[1]
  count=0
  failcount = 0
  print("Running timereport on file",fn)
  try:
    file = open(fn,"r")
  except IOError as message:
    print("FAIL open ",fn,"errormessage",message)
    sys.exit(1)
  maxreccount = 10
  recordcount = 0
  xt = xtime()
  while 1:
    try:
      rec = file.readline().strip()
    except EOFError:
        break
    if len(rec) < 1:
      # eof
      break
    recordcount = int(recordcount) + 1
    if int(recordcount) > maxreccount:
      break
    #if not isdateitem(rec):
    #  continue 
    recordcurrent(rec,xt)

  printoverall(xt)  




