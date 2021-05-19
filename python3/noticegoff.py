#!/usr/bin/env  python3
"""
A rarely used script to help connect far-flung
instances of dies/attributes/operators
Not used in the testsuite.
"""
import os
import sys


if __name__ == "__main__":
    count = 0
    failcount = 0
    try:
        # file = open(fn,"r")
        file = sys.stdin
    except IOError as message:
        print("FAIL open ", fn, "errormessage", message)
        sys.exit(1)
    block = []
    while 1:
        try:
            rec = file.readline()
        except EOFError:
            break
        if len(rec) < 1:
            # eof
            break
        count = int(count) + 1
        # print(count,rec)
        if rec.find("DW_TAG") == -1:
            continue
        if rec.find(" GOFF=") != -1:
            # print(count,rec)
            wds = rec.split()
            for w in wds:
                if w.find("GOFF=") != -1:
                    print(count, w)
                    break
