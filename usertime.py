import sys
import os


def processfile():
  if len(sys.argv) != 2:
    print "Usage: python useritime.py <usagetimepath>"
    sys.exit(1)
  tfilename = sys.argv[1]
  try:
    file = open(tfilename,"r")
  except IOError, message:
    print >> sys.stderr , "File could not be opened: ", message
    sys.exit(1)
  linecount = 0
  usecs = 0.0
  ssecs = 0.0
  wsecs = 0.0
  nzcount = 0
  allthree = "n"
  tcount = 0
  intrec = "n"
  while 1:
    try:
      rec = file.readline()
    except EOFError:
        break
    if len(rec) < 1:
      # eof
      break
    linecount += 1
    if rec.startswith("====== ") == 1:
      inrec = "y"
      tcount = int(tcount) +1
      allthree = "n"
      continue
    if rec.startswith("Command exited with non-zero status") == 1:
      nzcount = int(nzcount) + 1
      continue
    wds = rec.split()
    if rec.startswith("real ") == 1:
      # %e  wall clock seconds and fraction.
      try:
        t = float(wds[1])
      except ValueError,message:
        print "Bad value, line ",linecount,"record: ",rec
        t = 0.0
      wsecs = float(wsecs) + t
      continue

    if rec.startswith("user ") == 1:
      # %U  user cpu seconds and fraction.
      try:
        t = float(wds[1])
      except ValueError,message:
        print "Bad value, line ",linecount,"record: ",rec
        t = 0.0
      usecs = float(usecs) + t
      continue

    if rec.startswith("sys ") == 1:
      # %S  system cpu seconds and fraction.
      try:
        t = float(wds[1])
      except ValueError,message:
        print "Bad value, line ",linecount,"record: ",rec
        t = 0.0
      allthree  = "y"
      inrec = "n"
      continue
    # Else continue    

  file.close()
  return (tcount,nzcount,usecs,ssecs,wsecs)
 






if __name__ == '__main__':
  (tcount,nzcount,usecs,ssecs,wsecs) = processfile()
  print "Appcount: %5d  usr %8.2f sys %8.2f wallclock %8.2f nzcount %d " % ( tcount,usecs,ssecs,wsecs,nzcount)
  

