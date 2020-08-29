#!/usr/bin/python3
#

import sys
import os
import datetime

def isdateitem(rec):
  if rec.startswith("=====START"):
    return "st"
  if rec.startswith("old start "):
    return "os"
  if rec.startswith("new done "):
    return "nd"
  return "n"

def extracttime(s):
  # create a time record, return it or False.

if __name__ == '__main__':
  fn="ALLdd"
  if len(sys.argv) >1:
    fn = sys.argv[1]
  count=0
  starttext = ""
  osd = False
  ndd = False
  failcount = 0
  print("trimdate on file",fn)
  try:
    file = open(fn,"r")
  except IOError as message:
    print("FAIL open ",fn,"errormessage",message)
    sys.exit(1)
  while 1:
    try:
      rec = file.readline().strip()
    except EOFError:
        break
    if len(rec) < 1:
      # eof
      break
    typerec = istimeiten(rec)
    if  typerec == "st":
      if osd and ndd: 
      startext = rec
    elif typerec == "os":
      osd = extracttime(rec)
    elif typerec == "nd":
      ndd = extracttime(rec)
    else:
      continue
     
    


