#!/usr/bin/env python3
# Copyright 2020 David Anderson.
# This code is hereby placed into the public domain.

#  Alters each full-path string in the named input file
#  so that the prefix such as 

#  test/canonicalpath.py in libdwarf test directory
#  scripts/dirtostd.py in regressiontests directory

import os
import sys

#An example path:
#/home/davea/dwarf/regressiontests/../code/test/.debug/dummyexecutable.debug
#desired value: /home/davea/dwarf/code/test/.debug/dummyexecutable.debug
#/home/davea/dwarf/regressiontests/../code/test/.debug/dummyexecutable.debug

#First change "/regressiontests/../code/" to /code/

# example codepath: /home/davea/..../something
# example codepath: /home/linux1/

wina="C:/msys64/davea/home/admin/dwarf/code"
winb="C:/msys64/davea/"
isnormal="...std..."

precanonic ="/regressiontests/../code/"
postcanonic="/code/"

def dowinb(s,codepath):
    # for Msys2,desired result
    w = s.replace(wina,isnormal)
    # for Msys2, ok result fixed by direct caller.
    w2 = w.replace(winb,"/")
    w4 = w2.replace(codepath,isnormal)
    return w4

def printfixedcontent(sname,codepath):
   for line in open(sname): 
       s = line.rstrip()
       w2 = s.replace(precanonic,postcanonic)
       #print("dadebug Post canonic ",w2)
       w=dowinb(w2,codepath)
       #print("Final line canonic ",w)
       #print("dadebug w post canonic",w)
       print(w)
   return

if __name__ == '__main__':
    if len(sys.argv) > 2:
       s = sys.argv[1] # name of file with text content
       codepath = sys.argv[2] # the path prefix to change to ...std...
    else:
       print("BAD arg count",len(sys.argv),"to dirtostd.py")
       sys.exit(1)
    printfixedcontent(s,codepath)
