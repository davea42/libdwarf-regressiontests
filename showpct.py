#!/usr/bin/python3
import sys

total= 18249.0

if __name__ == '__main__':
  if len(sys.argv) == 2:
      v = float(sys.argv[1])
      v2 =  (v/float(total)) *100.0
      print("%3.0f"% float(v2))
  else:
     print("")
  
