#!/bin/sh

../dwarfdump -a libdwarf_crash.elf >junkn
diff junkn crash.base
if [ $? -ne 0 ]
then
  echo "FAIL dwarfdump -a -v -M guilfanov/libdwarf_crash.elf"
  echo "To update baseline: mv junkn crash.base"
  return 1
fi
return 0
