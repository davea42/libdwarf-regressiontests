rm -f ALLdd 
rm -f ALLdd2 
rm -f ALLddtodd2
start=`date`
./DWARFTEST.sh dd 2>ALLdd 1>&2
./DWARFTEST.sh dd2 2>ALLdd2 1>&2
#The following temporarily set aside.
#./DWARFTEST.sh ddtodd2 2>ALLddtodd2 1>&2
endt=`date`
echo "start $start"
echo "end   $endt"
