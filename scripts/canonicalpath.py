#!/usr/bin/env python3
# Copyright 2020 David Anderson.
# This code is hereby placed into the public domain.

# try:
#  canonicalname.py /a/b/../c/d/./e/

import os
import sys

if __name__ == '__main__':
  #print(len(sys.argv))
  if len(sys.argv) > 1:
     s = sys.argv[1]
     w = os.path.abspath(s)
     print(w)
  else:
     p1="/a/b/c/d/../.././e/"
     print(p1,os.path.abspath(p1))
     p2="/a/b/../c//d/./e/"
     print(p2,os.path.abspath(p2))
     p3="/a/b/../../d/./e/"
     print(p3,os.path.abspath(p3))
     print("no-name-given")
