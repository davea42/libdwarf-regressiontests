rm -f ALLdd 
rm -f ALLdd2 
rm -f ALLddtodd2
sh DWARFTEST.sh dd 2>ALLdd 1>&2
sh DWARFTEST.sh dd2 2>ALLdd2 1>&2
sh DWARFTEST.sh ddtodd2 2>ALLddtodd2 1>&2
