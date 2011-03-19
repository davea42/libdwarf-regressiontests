
../dwarfdump2 -a *.elf >junk.base
grep 'path/c:/programs/' <junk.base >junk.hasout
r=$?
if [ $r -ne 0 ]
then
   echo "FAIL sandnes2 missing path concat"
fi
../dwarfdump2W -a *.elf >junk.W
grep 'path/c:/programs/' <junk.W >junk.noout
r=$?
if [ $r -eq 0 ]
then
   echo "FAIL sandnes2 Failed to recognize windows file"
fi
# success!
exit 0


