#!/usr/bin/env python3
"""
Reading time reports from /usr/bin/time, sum up
the user and systime if timing is being done
(it is by default if /usr/bin/time exists)
"""
import sys
import os


class Urec:
    def __init__(self, title):
        self.title = title
        self.usecs = 0.0
        self.wsecs = 0.0
        self.ssecs = 0.0

    def uprint(self, h):
        print(
            "%s u%6.2f s%6.2f w%6.2f %s "
            % (h, self.usecs, self.ssecs, self.wsecs, self.title)
        )


class Counts:
    def __init__(self):
        self.timereccount = 0
        self.notimepresent = 0
        self.usecs = 0.0
        self.ssecs = 0.0
        self.wsecs = 0.0
        self.highestusecs = 0.0
        self.highestwsecs = 0.0


def getfloat(s, linecount, rec):
    try:
        t = float(s)
    except ValueError:
        print("Bad value, line ", linecount, "record: ", rec)
        t = 0.0
    return t


def processfile(path):
    tfilename = path
    try:
        file = open(tfilename, "r")
    except IOError as message:
        print("File could not be opened: ", message, file=sys.stderr)
        sys.exit(1)
    counts = Counts()
    linecount = 0
    allthree = "n"
    inrec = "n"
    title = ""
    crec = ""
    reclist = []
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
            # Start a new record.
            inrec = "y"
            counts.timereccount += 1
            wds = rec.strip().split()
            title = " ".join((wds[1:]))
            allthree = "n"
            if crec != "":
                reclist += [crec]
            crec = Urec(title)
            continue
        if inrec == "n":
            continue
        if rec.startswith("Command exited with non-zero status") == 1:
            counts.notimepresent += 1
            continue
        wds = rec.split()
        if rec.startswith("real ") == 1:
            # %e  wall clock seconds and fraction.
            crec.wsecs = getfloat(wds[1], linecount, rec)
            counts.wsecs += crec.wsecs
            if float(crec.wsecs) > float(counts.highestwsecs):
                counts.highestwsecs = crec.wsecs
            continue

        if rec.startswith("user ") == 1:
            # %U  user cpu seconds and fraction.
            crec.usecs = getfloat(wds[1], linecount, rec)
            counts.usecs += float(crec.usecs)
            if float(crec.usecs) > float(counts.highestusecs):
                counts.highestusecs = float(crec.usecs)
            continue

        if rec.startswith("sys ") == 1:
            # %S  system cpu seconds and fraction.
            crec.ssecs = getfloat(wds[1], linecount, rec)
            counts.ssecs += crec.ssecs
            allthree = "y"
            inrec = "n"
            continue
        # Else continue
    if crec != "":
        reclist += [crec]
    file.close()
    return counts, reclist


def printtop(recs, max):
    for i, r in enumerate(recs):
        r.uprint("")
        if i >= max:
            return


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python useritime.py whichisit" +\
            " <usagetimepath>")
        sys.exit(1)
    region = sys.argv[1]
    tfilename = sys.argv[2]
    counts, recs = processfile(tfilename)
    recs.sort(key=lambda x: float(x.wsecs))
    recs.reverse()
    printtop(recs, 10)
    print(
        region,
        "Count %5d  Seconds: usr %6.2f " % \
        (counts.timereccount, counts.usecs),
        end="",
    )
    print(region, "sys %6.2f wallclock %6.2f " % \
        (counts.ssecs, counts.wsecs))
    print(
        region,
        "Count Non zero status %d maxu %6.2f "
        % (counts.notimepresent, counts.highestusecs),
        end="",
    )
    print(region, "maxw %6.2f " % (counts.highestwsecs))
