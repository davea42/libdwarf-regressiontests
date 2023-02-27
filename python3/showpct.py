#!/usr/bin/env python3
"""
We print an approximation of the
percentage of work done so far on each test.
"""
import sys

# Just a bit above the real total
realtotal = 19800.0
total = realtotal

if __name__ == "__main__":
    if len(sys.argv) == 2:
        v = float(sys.argv[1])
        v2 = (v / float(total)) * 100.0
        print("%3.0f" % (float(v2)))
    else:
        print("")
