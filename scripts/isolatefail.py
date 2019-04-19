#!/usr/bin/env python3
# Copyright 2019 David Anderson.
# This code is hereby placed into the public domain.

# Isolate the last word on each FAIL line.
# which last word is the object file name.
# When lots of fails this can be useful.

import os
import sys

def scancontent(path):
  try:
    fx = open(path,"r")
  except IOError as  message:
    print("File",path,"could not be opened: ", message)
    sys.exit(1)
  out = []
  tmp = []
  iline = 0
  saveword = ""
  while 1:
    try:
      line = fx.readline()
    except UnicodeDecodeError as message:
      print("read decode fails, line ",iline,message)
      sys.exit(1)
    except IOError as message:
      print("read fails, line ",iline,message)
      sys.exit(1)
    if line == '':
      break
    #print("dadebug ",iline,line)
    iline = int(iline) + 1
    l2 = line.strip()
    if l2.startswith("FAIL") == 0:
       #print("dadebug ignore",l2)
       continue
    wds = l2.split()
    if len(wds) < 2:
       #print("dadebug ignore short",l2)
       continue
    #print("dadebug FAILLINE:",line)
    lastwd = len(wds)-1
    out += [wds[int(lastwd)]]
    #print("dadebug",lastwd,out)
    #sys.exit(1)
  fx.close()
  return out




if __name__ == '__main__':
  #print(len(sys.argv))
  if len(sys.argv) > 1:
     path = sys.argv[1]
  else:
     path = "ALLdd"
  lasts = scancontent(path)
  for l in lasts:
     print(l)
