#!/usr/bin/env python3
import sys
import os

#dadebug ALLOC ret 0x5672740 size 88 line 530 /home/davea/dwarf/code/libdwarf/dwarf_alloc.c
#dadebug DEALLOC ret 0x5672740 size 88 line 713 /home/davea/dwarf/code/libdwa

def trackallocs(fi,valdict):
  line = 0
  while True:
    line = int(line)+1
    try:
      recf = fi.readline()
    except EOFError:
      #print("dadebug stopping");
      break
    if len(recf) < 1:
      # eof
      break
    rec = recf.strip()
    if rec.find("ALLOC") != -1:
      print ("dadebug  rec:",rec)
    if rec.find("dadebug ALLOC ret 0x") != -1:
      wds = rec.split()
      off = wds[3]
      #print("dadebug off",off)
      if off in valdict:
         (allo,deallo) = valdict[off]
         if int(allo) == 0:
            r = (1,deallo)
            #print("dadebug 1",r)
            valdict[off] = r
         else:
            print("Duplicate use of ",off,"line",line)
            r =(int(allo)+1,deallo)
            #print("dadebug 2",r)
            valdict[off] = r
      else:
         allo = 1
         deallo = 0
         r=(allo,deallo)
         #print("dadebug 3",r)
         valdict[off] = r
      continue

    if rec.find("dadebug DEALLOC ret 0x") != -1:
      wds = rec.split()
      off = wds[3]
      #print("dadebug off",off)
      if off in valdict:
         (allo,deallo) = valdict[off]
         if int(deallo) == 0:
            r = (allo,1)
            #print("dadebug 10",r)
            valdict[off] = r
         else:
            print("Duplicate use of ",off,"line",line)
            r = (allo,int(deallo)+1)
            #print("dadebug 11",r)
            valdict[off] =  r
      else:
         allo = 0
         deallo = 1
         r=(allo,deallo)
         #print("dadebug 12",r)
         valdict[off] = r
      continue 

if __name__ == '__main__':
  if len(sys.argv) > 1:
    fname = sys.argv[1]
    #print("dadebug fname ",fname)
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
