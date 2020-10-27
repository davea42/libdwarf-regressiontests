#!/usr/bin/env python2
import os
import sys

def stripto(s,keep):
  news = s
  keepv = "xxx/"+keep

  wds = s.split()
  for w in wds:
    pos = w.find(keep)
    if pos == -1:
      continue
    # Now w is a full path we want to truncate.
    news = news.replace(w,keepv) 
  return news

if __name__ == '__main__':
  if len(sys.argv) < 2:
    print("filterpathto argument count wrong. Need argument")
    sys.exit(1)
  keepstr = sys.argv[1]
  f=sys.stdin
  while(1):  
    try:
      rec = f.readline().rstrip()
    except EOFError:
      break
    if len(rec) < 1:
      break
    pos = rec.find(keepstr)
    if (pos == -1):
      print rec
      continue
    newrec = stripto(rec,keepstr)
    print newrec
