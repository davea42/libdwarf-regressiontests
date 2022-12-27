#!/usr/bin/env python3
#
#  Report on the timings in an ALLdd file
#  to try to figure out what is slow
#

import sys
import os

# import datetime
from datetime import timedelta
from datetime import datetime


# =====START Pct   0  -a  kapus/bad.obj
# old start  Fri Jun 26 16:51:29 PDT 2020
# old done  Fri Jun 26 16:51:29 PDT 2020
# new start  Fri Jun 26 16:51:29 PDT 2020
# new done  Fri Jun 26 16:51:29 PDT 2020
# Fri Jun 26 16:51:29 PDT 2020
# =====START Pct   0 --print_raw_rnglists  moya2/filecheck.dwo
# old start  Fri Jun 26 16:51:29 PDT 2020
# old done  Fri Jun 26 16:51:29 PDT 2020
# new start  Fri Jun 26 16:51:29 PDT 2020
# new done  Fri Jun 26 16:51:29 PDT 2020
# Fri Jun 26 16:51:29 PDT 2020
# =====START Pct   0  -ka --print_raw_rnglists  moya2/filecheck.dwo
# Compute the seconds from old start to new done
# Compute the seconds from new done to old start.
# Compute the seconds from the very first old start
# to the very last new done.


class xtime:
    def __init__(self):
        # These are all datetime objects
        self.reset()

    def reset(self):
        self._command = False
        self._newstart = False
        self._newdone = False
        self._newduration = False
        self._oldstart = False
        self._olddone = False
        self._testnum = False
        self._oldduration = False

    def repr(self, which):
        txt = "{dur:03d} {num:n} {com}"
        if which == "old":
            return txt.format(
                dur=self._oldduration, num=int(self._testnum), com=self._command
            )
        else:
            return txt.format(
                dur=self._newduration, num=int(self._testnum), com=self._command
            )

        # code or shell runtime > this  will be called 'notable'
        self._notablekey = 20


mdict = {
    "Jan": 1,
    "Feb": 2,
    "Mar": 3,
    "Apr": 4,
    "May": 5,
    "Jun": 6,
    "Jul": 7,
    "Aug": 8,
    "Sep": 9,
    "Oct": 10,
    "Nov": 11,
    "Dec": 12,
}


def extractdate(rec):
    wds = rec.split()
    dt = wds[2]
    dtwds = dt.split("-")
    #print("dtwds", dtwds)
    y = dtwds[0]
    m = dtwds[1]
    d = dtwds[2]

    tm = wds[3]
    tmwds = tm.split(":")
    #print("tmwds", tmwds)
    h = tmwds[0]
    min = tmwds[1]
    s = tmwds[2]

    dt = datetime(int(y), int(m), int(d), int(h), int(min), int(s))
    return dt


def recordcurrent(rec, xt):
    if rec.startswith("=====START Pct "):
        xt.reset()
        wds = rec.split()
        n = " ".join(wds[3:])
        xt._command = n
        return False, False
    if rec.startswith("=====STATS Pct "):
        wds = rec.split()
        n = wds[4]
        xt._testnum = n
        return False, False
    if rec.startswith("old start "):
        # print("dadebug",rec);
        dt = extractdate(rec)
        xt._oldstart = dt
        return False, False

    if rec.startswith("old done "):
        dt = extractdate(rec)
        xt._olddone = dt
        df = xt._olddone - xt._oldstart
        xt._oldduration = int(df.total_seconds())
        return True, "old"

    if rec.startswith("new start "):
        dt = extractdate(rec)
        xt._newstart = dt
        return False, "new"

    if rec.startswith("new done "):
        dt = extractdate(rec)
        xt._newdone = dt
        df = xt._newdone - xt._newstart
        xt._newduration = int(df.total_seconds())
        return True, "new"
    return False, False


def isdateitem(rec):
    if rec.startswith("old start "):
        return True
    if rec.startswith("old done "):
        return True
    if rec.startswith("new start "):
        return True
    if rec.startswith("new done "):
        return True
    if rec.startswith("Mon "):
        return True
    if rec.startswith("Tue "):
        return True
    if rec.startswith("Wed "):
        return True
    if rec.startswith("Thu "):
        return True
    if rec.startswith("Fri "):
        return True
    if rec.startswith("Sat "):
        return True
    if rec.startswith("Sun "):
        return True
    return False


def printoverall(xt):
    return


if __name__ == "__main__":
    newduration = []
    oldduration = []
    fn = "ALLdd"
    if len(sys.argv) > 1:
        fn = sys.argv[1]
    count = 0
    failcount = 0
    print("Running timereport on file", fn)
    try:
        file = open(fn, "r")
    except IOError as message:
        print("FAIL open ", fn, "errormessage", message)
        sys.exit(1)
    maxreccount = 1000000
    recordcount = 0
    xt = xtime()
    while 1:
        try:
            rec = file.readline().strip()
        except EOFError:
            break
        if len(rec) < 1:
            # eof
            break
        if int(recordcount) > maxreccount:
            break
        # if not isdateitem(rec):
        #  continue
        x, onx = recordcurrent(rec, xt)
        if x:
            # end time.

            #print(xt.repr(onx))
            if onx == "old":
                oldduration += [xt.repr(onx)]
            elif onx == "new":
                newduration += [xt.repr(onx)]
            else:
                pass

        else:
            # start time time.
            if onx == "old":
                pass
            elif onx == "new":
                pass
            else:
                pass
    nsum = 0
    osum = 0
    for n in newduration:
      wds = n.split()
      osum += int(wds[0])
    print("old len", len(oldduration), "old time summed:",osum)
    for n in oldduration:
      wds = n.split()
      nsum += int(wds[0])
    print("new len", len(newduration), "new time summed:",nsum)
    newduration.sort()
    newduration.reverse()
    print("New list")
    for n in newduration:
      print(n)
    oldduration.sort()
    oldduration.reverse()
    print("Old list")
    for n in oldduration:
      wds = n.split()
      osum += int(wds[0])
      print(n)
