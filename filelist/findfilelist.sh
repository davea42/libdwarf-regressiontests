#!/bin/sh
cd ..
find . -type f -print >filelist/filelista
sed '/...git/d' filelist/filelista  >filelist/filelistb
rm filelist/filelistc
touch filelist/filelistc
while read fname
do
   object_detector $fname >>filelist/filelistc
done <filelist/filelistb

grep ', type ' < filelist/filelistc  > filelist/filelistd

cut -d ' ' -f 1 <filelist/filelistd     >filelist/fileliste

# Now fileist/fileliste is a set of object files.
wc filelist/fileliste
exit 1
