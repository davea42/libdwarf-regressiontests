#!/usr/bin/python
import sys

# An approximation of the actual full count.
total= 51000

if __name__ == '__main__':
  if len(sys.argv) == 2:
      v = float(sys.argv[1])
      v2 =  (v/float(total)) *100.0
      print "%3.0f"% float(v2) 
  else:
     print ""
  
