#!/usr/bin/env python3

#This is of limited use when debugging
#allocation/deallocation issues.
# Assumes libdwarf instrumented with print statements
# so this can track alloc/dealloc over time for missing
# or duplicate dealloc.
#Any use will require some changes.


def readlog(filename):
  try:
    file = open(filename,"r")
  except IOError as message:
    print("File could not be opened: ", message,file=sys.stderr)
    sys.exit(1)
  lines = file.read().splitlines()
  file.close()
  return lines

def check_typelist(addr,types):
  typeslen = len(types)
  if typeslen == 1:
    print("Error ",addr,typeslen,types)
  elif typeslen ==2:
    if types[0] == "alloc" and types[1] == "dealloc":
      return
    if types[0] == "alloc" and types[1] == "dealloc_all_final":
      return
    else:
      print("erroneous types list values ",addr,typeslen,types)
  elif typeslen ==3:
    if types[0] == "alloc" and types[1] == "dealloc" and types[2] == "dealloc_all":
      return
    else:
      print("erroneous types list values ",addr,typeslen,types)
  else:
    print("Impossible types list len ",addr,typeslen,types)


if __name__ == '__main__':
  lst = readlog("junk2")
  lastaddr = 0
  typelist = []

  
  ct = 0
  for l in lst:
    ct = int(ct) +1
    wds = l.split()
    addr = wds[2]
    typ  = wds[3]
    if ( addr != lastaddr):
       check_typelist(lastaddr,typelist)
       typelist = [typ]
       #print("typelist now a",typelist)
       lastaddr = addr
    else:
       typelist += [typ]
       #print("typelist now b",typelist)
    #if  int(ct) == 8:
    #   break;
  check_typelist(lastaddr,typelist)



