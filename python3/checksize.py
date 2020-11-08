#!/usr/bin/env python3

import os
import sys


def getSize(name):
  try:
    file = open(name,"r")
  except IOError as message:
    print("FAIL open ",name,"errormessage",message)
    return 0
  file.seek(0,2) # move the cursor to the end of the file
  size = file.tell()
  file.close()
  return size

if __name__ == '__main__':
  if len(sys.argv) < 3:
    print("Too few args to checksize.py:",len(sys.argv))
    sys.exit(0)
  maxsz = sys.argv[1]
  if not maxsz.isdigit():
    print("checksize.py first arg not a number, is",maxsz)
    sys.exit(0)
  fname = sys.argv[2]
  sz1 = getSize(fname)
  fname2 = sys.argv[3]
  sz2 = getSize(fname2)
  if int(sz1) > int(maxsz):
     sys.exit(1)
  if int(sz2) > int(maxsz):
     sys.exit(1)
  sys.exit(0)
