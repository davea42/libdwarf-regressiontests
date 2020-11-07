#!/usr/bin/env python2
import sys

# just a bit above the real total
realtotal= 29400.0
total=realtotal

if __name__ == '__main__':
  if len(sys.argv) == 2:
      v = float(sys.argv[1])
      v2 =  (v/float(total)) *100.0
      print "%3.0f"%(float(v2)) 
  else:
     print ""
  
