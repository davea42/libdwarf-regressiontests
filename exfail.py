#!/usr/bin/env python3
#
#  Split ALLdd into groups of lines
#   with '====' at beginning of line, as head line.
#
#  If the word FAIL in caps appears, write the group to stdout.
# else move to next group.


import sys



def printblock(b,failcount_in):
  suppress = "y"
  failcount = failcount_in
  for l in b:
    if l.rfind("FAIL") != -1:
      failcount = int(failcount) +1
      suppress = "n"
      failcount = int(failcount) +1
      break
  if suppress == "n":
    for l in b:
      print(l)
  return failcount

if __name__ == '__main__':
  fn="ALLdd"
  if len(sys.argv) > 1:
    fn = sys.argv[1]
  count=0
  rcount = 1
  failcount = 0
  try:
    file = open(fn,"r")
  except IOError as message:
    print("FAIL open ",fn,"errormessage",message)
    sys.exit(1)
  block = []
  while 1:
    try:
      reci = file.readline()
    except EOFError:
      print("Hit EOF ")
      break
    #print(rcount,reci,end="")
    rcount = int(rcount) +1
    if len(reci) < 1:
      print("Rec len 0, stop");
      break
    rec = reci.strip()
    if rec.startswith("=====START") == 1:
      failcount = printblock(block,failcount)
      count = int(count) +1
      block = []
      block += [rec]
    else:
      block += [rec]
  if len(block) > 0:
    failcount = printblock(block,failcount)

  print("testcount:",count)
  print("failcount:",failcount)
  





