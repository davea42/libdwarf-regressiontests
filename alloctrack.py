#!/usr/bin/env python3
# Copyright 2020 David Anderson
# This python code is hereby placed into the public domain
# for use by anyone for any purpose.

# Useful for finding the needle of
# a single leaking allocation
# in the haystack of all the libdwarfdetector
# lines libdwarf can emit if compiled -DDEBUG=1
import sys
import os

def trackallocs(fi,valdict):
  line = 0
  while True:
    line = int(line)+1
    try:
      recf = fi.readline()
    except EOFError:
      break
    if len(recf) < 1:
      # eof
      break
    rec = recf.strip()
    if rec.find("libdwarfdetector ALLOC ret 0x") != -1:
      wds = rec.split()
      off = wds[3]
      if off in valdict:
         (allo,deallo) = valdict[off]
         if int(allo) == 0:
            r = (1,deallo)
            valdict[off] = r
         else:
            print("Duplicate use of ",off,"line",line)
            r =(int(allo)+1,deallo)
            valdict[off] = r
      else:
         allo = 1
         deallo = 0
         r=(allo,deallo)
         valdict[off] = r
      continue

    if rec.find("libdwarfdetector DEALLOC ret 0x") != -1:
      wds = rec.split()
      off = wds[3]
      if off in valdict:
         (allo,deallo) = valdict[off]
         if int(deallo) == 0:
            r = (allo,1)
            valdict[off] = r
         else:
            print("Duplicate use of ",off,"line",line)
            r = (allo,int(deallo)+1)
            valdict[off] =  r
      else:
         allo = 0
         deallo = 1
         r=(allo,deallo)
         valdict[off] = r
      continue 

if __name__ == '__main__':
  if len(sys.argv) > 1:
    fname = sys.argv[1]
    try:
      file = open(fname,"r")
    except IOError as message:
      print("File could not be opened: ", fname, " ", message)
      sys.exit(1)
  else:
    file = sys.stdin

  vals = {}
  trackallocs(file,vals)
  for s in vals:
    (allo,deallo) = vals[s]
    if int(allo) != int(deallo):
       print("Mismatch on ",s," a vs d: ",allo,deallo)
    if int(allo) >  1:
       print("Reuse of ",s," a vs d: ",allo,deallo)
