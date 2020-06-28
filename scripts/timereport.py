#!/usr/bin/env python3
#
#  Report on the timings in an ALLdd file
#  to try to figure out what is slow
# 

import sys
import os
#import datetime
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
    # These are all datetime objects
    self._firstostart = False
    self._lastnewdone = False
    self._curostart = False
    self._curndone = False
    self._curfile = "<none>"
    self._testcount = 0

    # code or shell runtime > this  will be called 'notable'
    self._notablekey = 20

mdict = { "Jan":1, "Feb":2, "Mar":3, "Apr":4, 
"May":5, "Jun":6, "Jul":7, "Aug":8,
"Sep":9, "Oct":10, "Nov":11, "Dec":12 }

def extractdate(rec):
  wds = rec.split()
  mt = wds[3]
  month = mdict[mt]
  day = wds[4]
  year = wds[7]
  tm = wds[5]
  tmwds = tm.split(":")
  dt = datetime(int(year),int(month),int(day),\
    int(tmwds[0]),int(tmwds[1]),int(tmwds[2]))
  return dt

def recordcurrent(rec,xt):
  if rec.startswith("=====START Pct "):
    wds = rec.split()
    n = ' '.join(wds[1:])
    xt._curfile = n
    return True
  if rec.startswith("old start "):
    #print("dadebug",rec);
    dt = extractdate(rec)
    if not xt._firstostart:
      xt._firstostart = dt 
    xt._curostart = dt
    xt._testcount = int(xt._testcount) +1
    if xt._curndone:
      td = dt - xt._curndone
      print("Shell tm",td,xt._curfile)
      if td.total_seconds() > xt._notablekey:
        print("=====shellt notable",td,xt._curfile)
    return True
  if rec.startswith("old done "):
    dt = extractdate(rec)
    return False
  if rec.startswith("new start "):
    dt = extractdate(rec)
    return False
  if rec.startswith("new done "):
    #print("dadebug",rec);
    dt = extractdate(rec)
    xt._lastnewdone = dt 
    xt._curndone = dt
    if xt._curostart:
      td = dt - xt._curostart
      print("Run time",td,xt._curfile)
      if td.total_seconds() > float(xt._notablekey):
        print("=====runtime notable",td,xt._curfile)
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
  if not xt._firstostart:
    print("Incomplete file")
    return
  if not xt._lastnewdone:
    print("Incomplete file")
    return
  td =  xt._lastnewdone -  xt._firstostart
  print("Overall run time",td)
  print("Test count      ",xt._testcount)
  print("Seconds per test",td.total_seconds()/float(xt._testcount))

if __name__ == '__main__':
  fn="ALLdd"
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
  maxreccount = 1000000
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
    if int(recordcount) > maxreccount:
      break
    #if not isdateitem(rec):
    #  continue 
    x = recordcurrent(rec,xt)
    if x:
      recordcount = int(recordcount) + 1
  printoverall(xt)  




