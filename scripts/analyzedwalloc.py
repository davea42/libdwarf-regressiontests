#!/usr/bin/env python3

import os
import sys

def mykey(l):
  return int(l[0])

def scancontent(path):
  try:
    # the errors='replace' ensures any non-unicode
    # is sensibly replaced Otherwise bad stuff gets
    # UnicodeDecodeError.
    # To search for bad stuff (chars >= 'ff) use
    # byteread.c
    fx = open(path,"r",errors='replace')
  except IOError as  message:
    print("File",path,"could not be opened: ", message)
    sys.exit(1)
  out = []
  tmp = []
  iline = 0
  lastline = ''
  saveword = ""
  name = ''
  while 1:
    try:
      line = fx.readline()
    except UnicodeDecodeError as message:
      print("read decode fails, line ",iline,message)
      print("Pref line",lastline);
      sys.exit(1)
    except IOError as message:
      print("read fails, line ",iline,message)
      sys.exit(1)
    if line == '':
      break
    lastline = line
    #print("dadebug ",iline,line)

    iline = int(iline) + 1
    l2 = line.strip()
    if l2.startswith("===="):
       wds = l2.split()
       name = ' '.join(wds[1:])
       continue
    wds = l2.split()
    if len(wds) < 2:
       print("dadebug ignore short",l2)
       continue
    #print("dadebug ",l2,name)
    entry = [wds[1],name,":",l2] 
    #print("dadebug entr ",entry)
    out += [entry]
    #print("dadebug",lastwd,out)
    #sys.exit(1)
  fx.close()
  
  tmp = sorted(out,key=mykey,reverse=True)
  return tmp




if __name__ == '__main__':
  #print(len(sys.argv))
  if len(sys.argv) > 1:
     path = sys.argv[1]
  else:
     path = "../stdlibdwallocs"
  lasts = scancontent(path)
  max = 20
  count=0
  for l in lasts:
     if int(count) > int(max):
        break;
     print(l)
     count = int(count) +1

