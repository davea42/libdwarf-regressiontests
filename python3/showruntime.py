#!/usr/bin/env python3
"""
prints the dwarfdump runtime from the data in ALLdd.
Not normally used, but useful to find out
which instances have larger amounts of time
spent in dwarfdump.
"""

import sys
import os
import datetime


def isdateitem(rec):
    if rec.startswith("=====START"):
        return "st"
    if rec.startswith("old start "):
        return "os"
    if rec.startswith("new done "):
        return "nd"


def extracttime(s):
    wds = s.split()
    if len(wds) < 4:
        print("Malformed date", s)
        sys.exit(1)
    fy = wds[2].split("-")
    ft = wds[3].split(":")
    dt = datetime.datetime(
        int(fy[0]), int(fy[1]), int(fy[2]), int(ft[0]), int(ft[1]), int(ft[2])
    )
    return dt


if __name__ == "__main__":
    fn = "ALLdd"
    if len(sys.argv) > 1:
        fn = sys.argv[1]
    count = 0
    smallestinteresting = 5
    starttext = ""
    osd = False
    ndd = False
    biggestrun = False
    biggestitem = ""
    failcount = 0
    print("trimdate on file", fn)
    try:
        file = open(fn, "r")
    except IOError as message:
        print("FAIL open ", fn, "errormessage", message)
        sys.exit(1)
    while 1:
        try:
            rec = file.readline().strip()
        except EOFError:
            break
        if len(rec) < 1:
            # eof
            break
        typerec = isdateitem(rec)
        if typerec == "st":
            if osd and ndd:
                diff = ndd - osd
                if diff.total_seconds() > float(smallestinteresting):
                    print(rec)
                    print("dwarfdump secs", diff.total_seconds())
                    if not biggestrun or diff > biggestrun:
                        biggestrun = diff
                        biggestitem = starttext
            starttext = rec
            # print(rec)
        elif typerec == "os":
            osd = extracttime(rec)
            if ndd:
                diff = osd - ndd
                if diff.total_seconds() > float(smallestinteresting):
                    print(starttext)
                    print("shell secs   ", diff.total_seconds())
                    if not biggestrun or diff > biggestrun:
                        biggestrun = diff
        elif typerec == "nd":
            ndd = extracttime(rec)
        else:
            continue
    if osd and ndd:
        diff = ndd - osd
        print("dwarfdump run time secs", diff.total_seconds())
    print("biggest delta, seconds", biggestrun.total_seconds())
    print("biggest was           ", biggestitem)
