#!/usr/bin/python
import sys

# An approximation of the actual full count.
# We just see half the total for the pct figurel
realtotal= 51000.0
# adjust the true total so we don't see 100 pct
# too early...or maybe at all. 99 is good :-)
# The count we see input is *half* the true total.
total = (realtotal*1.01) / 2.0

if __name__ == '__main__':
  if len(sys.argv) == 2:
      v = float(sys.argv[1])
      v2 =  (v/float(total)) *100.0
      print "%3.0f"%(float(v2)) 
  else:
     print ""
  
