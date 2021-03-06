#!/usr/bin/python3
"""
Intended to strip uninteresting differences out
of the output of a test run.
What is uninteresting changes all the time,
so this should be considered a skeleton of an application,
not a just-use-it thing.
"""

import sys

# Thu Nov 26 14:01:10 PST 2015
# 175c175
# < .debug_string
# ---
# > .debug_str
# FAIL -a -R -v -x line5=std sparc/tcombined.o


# This gets two input files and produces
# A set of diffs, as output.
# It is to produce the changes in the email list.

# Copyright 2008-2014 Golden Gate Lotus Club
#

# file1:
# Find the email in each line, remember the email and the line.
# file2: For each line. find the email and see if the email
# exists from the first file.
import sys


def tailmatches(tail, windowlen):
    ct = len(tail)
    if len(tail) < int(windowlen):
        return "n"
    if tail[0].startswith("Wed ") == 0:
        return "n"
    wds = tail[1].strip().split("d")
    if len(wds) != 2:
        return "n"
    if wds[1].isdigit() == 0:
        return "n"
    if tail[2].startswith("< .debug_macinfo") == 0:
        return "n"
    if tail[3].startswith("<") == 0:
        return "n"
    if tail[4].startswith("FAIL") == 0:
        return "n"
    return "y"


def splitwin(win, taillen):
    if len(win) < int(taillen):
        return (win, [])
    i = 0
    head = []
    tail = []
    lasthead = len(win) - int(taillen) - 1
    for l in win:
        if i < int(lasthead):
            head += [l]
        else:
            tail += [l]
        i = i + 1
    return (head, tail)


def readaline(file):
    try:
        l = file.readline().strip()
    except EOFError:
        return ("y", "")
    if len(l) < 1:
        return ("y", "")
    return ("n", l)


def fillwindow(file, win, windowlen):
    donehere = "n"
    while donehere == "n":
        (donehere, l) = readaline(file)
        if donehere == "y":
            return (donehere, win)
        if l.startswith("FAIL") == 1:
            win += [l]
            break
        win += [l]
    # At FAIL line, end of a sequence.
    (head, tail) = splitwin(win, windowlen)
    if tailmatches(tail, windowlen) == "y":
        for l in head:
            print(l)
    else:
        for l in head:
            print(l)
        for l in tail:
            print(l)
    return (donehere, [])


def readinfile(fname):
    try:
        file = open(fname, "r")
    except IOError as message:
        print("File could not be opened: ", fname, " ", message, file=sys.stderr)
        sys.exit(1)

    windowlen = 4
    curwindow = []
    done = "n"
    while done == "n":
        (done, curwindow) = fillwindow(file, curwindow, windowlen)
        for l in curwindow:
            print(l)
    # done


if __name__ == "__main__":
    readinfile("testALLdd")
    # readinfile("ALLdd")
