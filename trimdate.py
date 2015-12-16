#!/usr/bin/python
#
# Any line starting with a day number (as abbrev)
# gets 'DATE' substitutied. Makes comparisons
# of some kinds easier.

import sys



def printblock(b,failcount_in):
  suppress = "y"
  failcount = failcount_in
  for l in b:
    if l.rfind("FAIL") != -1:
      failcount = int(failcount) +1
      suppress = "n"
      break
  if suppress == "n":
    for l in b:
      print l
  return failcount

if __name__ == '__main__':
  fn="ALLdd"
  count=0
  failcount = 0
  try:
    file = open(fn,"r")
  except IOError,message:
    print "FAIL open ",fn,"errormessage",message
    sys.exit(1)
  print "Start stripping dates"
  while 1:
    try:
      rec = file.readline().strip()
    except EOFError:
        break
    if len(rec) < 1:
      # eof
      break
    if rec.startswith("Mon ") == 1:
       print "DATE:xxx"
    elif  rec.startswith("Tue ") == 1:
       print "DATE:xxx"
    elif  rec.startswith("Wed ") == 1:
       print "DATE:xxx"
    elif  rec.startswith("Thu ") == 1:
       print "DATE:xxx"
    elif  rec.startswith("Fri ") == 1:
       print "DATE:xxx"
    elif  rec.startswith("Sat ") == 1:
       print "DATE:xxx"
    elif  rec.startswith("Sun ") == 1:
       print "DATE:xxx"
    else:
       print rec
  print "Done stripping dates"




