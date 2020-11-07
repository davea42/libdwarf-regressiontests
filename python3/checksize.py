#!/usr/bin/env python3

import os
import sys


def getSize(name):
  try:
    file = open(name,"r")
  except IOError as message:
    print("FAIL open ",fn,"errormessage",message)
    sys.exit(1)
  file.seek(0,2) # move the cursor to the end of the file
  size = file.tell()
  file.close()
  return size

if __name__ == '__main__':
  fsz = sys.argv[1]
  if not fsz.isdigit():
    print("checksize.py first arg not a number")
    sys.exit(0)
  fname = sys.argv[2]
  sz1 = getSize(fname)
  fname2 = sys.argv[3]
  sz2 = getSize(fname2)
  if int(sz1) > int(fsz):
     sys.exit(1)
  if int(sz2) > int(fsz):
     sys.exit(1)
  sys.exit(0)
