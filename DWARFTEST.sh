#!/bin/bash
#
echo 'tests are  "dd"   "dd2"  "ddtodd2", and no options means dd'  
goodcount=0
failcount=0
. BASEFILES
cbase=$libdw
if [ $# -eq 0 ]
then
  d1=./dwarfdump.O
  d2=./dwarfdump
else
case $1 in
  dd ) d1=./dwarfdump.O ;  d2=./dwarfdump ; type=dd ;;
  dd2 ) d1=./dwarfdump2.O ; d2=./dwarfdump2 ; type=dd2 ;;
  ddtodd2 ) d1=./dwarfdump ; d2=./dwarfdump2 ; type=ddtodd2 ;;
  * )  echo BAD OPTION NO TEST RUN ; exit 1 ;;
esac
fi
echo "old is $d1"
echo "new is $d2"
dwlib=$cbase/libdwarf/libdwarf.a
dwinc=$cbase/libdwarf

o='-F'
o='-b -c  -f -F  -h -i -l -m -o -p -r -s -ta -tf -tv -y -w  -N'

# -e use elipsis for some names.
# -g use old loclist stuff, must use other option to select section.
# -d dense, show DIE info on one line
#                -v      verbose: show more information
#f='x86/dwarfdumpv4.3'
#ia32/libpt_linux_x86_r.so.1  -f -F runs too long.
f='moshe/hello
moshe/a.out.t
dwarf4/dd2g4.5dwarf-4	
dwarf4/ddg4.5dwarf-4
x86/dwarfdumpv4.3 
allen1/todd-allen-gcc-4.4.4-bin.exe
wynn/unoptimised.axf
shihhuangti/tcombined.o
kartashev/combined.o
macinfo/a.out3.4 
macinfo/a.out4.3 
arm/armcc-test-dwarf2  
arm/armcc-test-dwarf3 
sun/sunelf1 
val_expr/libpthread-2.5.so 
ia64/hxdump.ia64 
ia64/mytry.ia64 
ia32/mytry.ia32  
ia32/libc.so.6 
x86-64/x86_64testcase.o 
irix64/libc.so 
irixn32/libc.so 
irixn32/dwarfdump 
testcase/testcase 
Test-eh/eh-frame.386 
test-eh/test-eh.386 
mutatee/test1.mutatee_gcc.exe 
cristi2/libpthread-2.4.so 
ia32/preloadable_libintl.so 
ia32/libpfm.so.3 
cristi3/cristibadobj'

# Avoid spurious differences because of the names of the
# various dwarfdump versions being tested.
unifyddname () {
  nstart=$1
  nend=$2
  t1=tmpuerr1
  t2=tmpuerr2
  sed -e 'sx.\/dwarfdump.Ox.\/dwarfdumpx' < $nstart >$t1
  sed -e 'sx.\/dwarfdump2.Ox.\/dwarfdumpx' <$t1 >$t2
  sed -e 'sx.\/dwarfdump2x.\/dwarfdumpx' <$t2 >$nend
  rm -f $t1 $t2
}

runtest () {
	olddw=$1
	newdw=$2
	targ=$3
	shift
	shift
	shift
	
        echo "=====  $*  $targ"
        rm -f core
        rm -f tmp1 tmp2 tmp3
        rm -f tmp1err tmp2err tmp3err 
        rm -f tmp1errb tem1errc
        rm -f tmp1berr tmp2berr

        # Running an old one till baselines established.
        echo "old start " `date`
        $olddw $*  $targ 1>tmp1 2>tmp1erra
        echo "old done " `date`
        unifyddname tmp1erra tmp1err
        if [ -f core ]
        then
           echo corefile in  $olddw '(old dwarfdump)'
           rm core
        fi

        echo "new start " `date`
        $newdw  $* $targ  1>tmp2 2>tmp2erra
        echo "new done " `date`
        unifyddname tmp2erra tmp2err
        date
        if [ -f core ]
        then
           echo corefile in  $newdw
           exit 1
        fi
        grep -v dadebug tmp2  >tmp3
        # 
        diff tmp1 tmp3
        if [ $? = 0 ]
        then
          goodcount=`expr $goodcount + 1`
        else
          echo FAIL  $* $targ
          failcount=`expr $failcount + 1`
        fi
        grep -v Usage   tmp1err >tmp1berr
        grep -v Usage   tmp2err >tmp2berr
        diff tmp1berr tmp2berr
        if [ $? = 0 ]
        then
          goodcount=`expr $goodcount + 1`
        else
          echo FAIL Usage  $* $targ
          failcount=`expr $failcount + 1`
        fi
        rm -f core
        rm -f tmp1 tmp2 tmp3
        rm -f tmp1err tmp2err tmp3err 
        rm -f tmp1errb tem1errc
        rm -f tmp1berr tmp2berr

}
# end 'runtest'


chkres () {
  if [ $1 = 0 ]
  then
	goodcount=`expr $goodcount + 1`
  else
          echo FAIL  $2
          failcount=`expr $failcount + 1`
  fi
}
runtest $d1 $d2  moshe/hello -a -vvv -R -M
runtest $d1 $d2  moshe/hello -ka -vvv -R -M
runtest $d1 $d2  moshe/a.out.t -a -vvv -R -M
runtest $d1 $d2  moshe/a.out.t -ka -vvv -R -M
runtest $d1 $d2  dwarf4/dd2g4.5dwarf-4 -a  -vvv -R -M
runtest $d1 $d2  dwarf4/dd2g4.5dwarf-4 -ka -vvv -R -M
runtest $d1 $d2  dwarf4/ddg4.5dwarf-4 -a  -vvv -R -M
runtest $d1 $d2  dwarf4/ddg4.5dwarf-4 -ka -vvv -R -M

# The following 3 print the lines  differently.
# The first prints a shorthand for file path.
# The second a filepath for each line
# The third prints details on the line operators.
# In these 3 the name is long, so -l and -l -v print differently.
runtest $d1 $d2  wynn/unoptimised.axf -l 
runtest $d1 $d2  wynn/unoptimised.axf -l -v
runtest $d1 $d2  wynn/unoptimised.axf -l -vvv
# These have short names, so -l -v prints like -l  prints.
runtest $d1 $d2  mucci/stream.o -l 
runtest $d1 $d2  mucci/stream.o -l  -v
runtest $d1 $d2  mucci/stream.o -l  -vvv

# currently generates DW_DLE_LINE_FILE_NUM_BAD
# due to gcc bug in line output.
runtest $d1 $d2  moore/djpeg.v850 -l -R

runtest $d1 $d2  enciso2/template.elf -a -vvv -R -M
runtest $d1 $d2  enciso2/template.elf -a -R -M
runtest $d1 $d2  enciso2/template.elf -ka -R -M
runtest $d1 $d2  enciso2/test_templates.o  -a -R -M
runtest $d1 $d2  enciso2/test_templates.o  -a -R 
runtest $d1 $d2  x86/dwarfdumpv4.3 -S match=main 
runtest $d1 $d2  x86/dwarfdumpv4.3 -S any=leb 
runtest $d1 $d2  x86/dwarfdumpv4.3 -S 'regex=u.*leb' 
runtest $d1 $d2  wynn/unoptimised.axf  -f   -x abi=arm
runtest $d1 $d2  wynn/unoptimised.axf  -kf  -x abi=arm
runtest $d1 $d2  arm/armcc-test-dwarf2 -f   -x abi=arm 
runtest $d1 $d2  arm/armcc-test-dwarf2 -ka  -x abi=arm 
runtest $d1 $d2  arm/armcc-test-dwarf3 -f  -x abi=arm
runtest $d1 $d2  arm/armcc-test-dwarf3 -ka  -x abi=arm
runtest $d1 $d2  lloyd/arange.elf  -r
runtest $d1 $d2  lloyd/arange.elf  -kr

# With mips abi and C dwarfdump we get error 
# DW_DLE_FRAME_REGISTER_UNREPRESENTABLE.  That is normal, expected.
# It is not MIPS and MIPS is just wrong here.  Testing it anyway!
if [ ! $type = "ddtodd2" ]
then
 runtest $d1 $d2  val_expr/libpthread-2.5.so -x abi=mips -F -v -v -v
fi

cd findcu 
sh RUNTEST $cbase >testoutput
chkres $? 'findcu/cutest-of-a-libdwarf-interface'
cd ..


cc -Wall -I  $cbase/libdwarf test_harmless.c  -o test_harmless $cbase/libdwarf/libdwarf.a -lelf
./test_harmless >testoutput
chkres $? 'check harmless-error functionality'


# Testing that gennames -t and -s generate the same results.
./gennames -s  -i $cbase/libdwarf -o .
mv dwarf_names.c dwarfnames-s.c
cc -Wall -I $cbase/libdwarf test_dwarfnames.c dwarfnames-s.c -o dwarfnames-s
./dwarfnames-s > dwn_s_out
./gennames -t  -i $cbase/libdwarf -o .
mv dwarf_names.c dwarfnames-t.c
cc -Wall -I  $cbase/libdwarf test_dwarfnames.c dwarfnames-t.c -o dwarfnames-t
./dwarfnames-t > dwn_t_out

diff dwn_s_out dwn_t_out
chkres $?  dwarfnames-switch-table-check
rm -f dwarf_names.c dwarfnames-s.c
rm -f  dwarfnames-t.c
rm -f dwarf-names-s dwarfnames-t dwn_s_out dwn_t_out
rm -f dwarf_names_enum.h dwarf_names.h  dwarf_names_new.h 

cd frame1
sh runtest.sh $cbase
chkres $? frame1
cd ..

cd dwarfextract
rm dwarfextract
sh runtests.sh $cbase
chkres $?  dwarfextract
cd ..

cd sandnes2
sh RUNTEST.sh
chkres $?  sandnes2
cd ..

cd legendre
sh RUNTEST.sh $cbase
chkres $?  sandnes2
cd ..


runtest $d1 $d2 irixn32/dwarfdump -u  dwconf.c -x name=dwarfdump.conf  -x abi=mips-simple
runtest $d1 $d2 irixn32/dwarfdump -u  /xlv44/6.5.15m/work/irix/lib/libc/libc_n32_M3/csu/crt1text.s  -x name=dwarfdump.conf -x abi=mips-simple

runtest $d1 $d2  sparc/tcombined.o -a -R  -v -v -v -v -v -v
runtest $d1 $d2  sparc/tcombined.o -ka -R  -v -v -v -v -v -v
runtest $d1 $d2  kartashev2/combined.o -a -R  -v -v -v -v -v -v
runtest $d1 $d2  kartashev2/combined.o -ka -R  -v -v -v -v -v -v
runtest $d1 $d2  x86/dwarfdumpv4.3 -a -R  -v -v -v -v -v -v
runtest $d1 $d2  x86/dwarfdumpv4.3 -ka -R -v -v -v -v -v -v
runtest $d1 $d2  mucci/stream.o -a -R   -v -v -v -v -v -v
runtest $d1 $d2  mucci/stream.o -ka -R   -v -v -v -v -v -v
runtest $d1 $d2  mucci/stream.o -c -R -ka  
runtest $d1 $d2  mucci/stream.o -c -R -ka  -v -v -v -v -v -v
runtest $d1 $d2  mucci/main.o -a -R   -v -v -v -v -v -v
runtest $d1 $d2  mucci/main.o -ka -R   -v -v -v -v -v -v
runtest $d1 $d2  mucci/main.o -c -R -ka  -v -v -v -v -v -v
runtest $d1 $d2  mucci/main.o -c -R -ka  
runtest $d1 $d2 mucci/stream.o -a -R -M
runtest $d1 $d2 mucci/stream.o -i -e
runtest $d1 $d2 legendre/libmpich.so.1.0 -f -F 
runtest $d1 $d2 legendre/libmpich.so.1.0 -ka 



if [  $type = "dd2" ]
then
  # Running dd on this file is too slow. Only dd2 ok.
  # The issue is the number of registers and which
  # frame reg access interface is used for -f and -F.
  runtest $d1 $d2  ia32/libpt_linux_x86_r.so.1 -a -vvv -R -F
  runtest $d1 $d2  ia32/libpt_linux_x86_r.so.1 -c -vvv -R -F
fi

cd test-alex1
sh RUNTEST $dwlib $dwinc
chkres $?  test-alex1
cd ..
cd test-alex2
sh RUNTEST $dwlib $dwinc
chkres $?  test-alex1
cd ..


#Following 2 show some DW_AT_MIPS_fde difference. So -C works.
runtest $d1 $d2  irix64/libc.so -ka   -x name=dwarfdump.conf -x abi=mips-simple3
runtest $d1 $d2  irix64/libc.so -i    -x name=dwarfdump.conf -x abi=mips-simple3
#Following shows -C differences, see ia64/README. So -C works.
runtest $d1 $d2  ia64/mytry.ia64 -i
runtest $d1 $d2  ia64/mytry.ia64 -ka 
runtest $d1 $d2  ia64/mytry.ia64 -i -C
runtest $d1 $d2  ia64/mytry.ia64 -ka  -C

runtest $d1 $d2  ref_addr/ELF3.elf -R -a -v -v -v -v -v -v 
runtest $d1 $d2  ref_addr/ELF3.elf -R -a -M  -v -v -v -v -v -v 
runtest $d1 $d2  ref_addr/ELF3.elf -R -ka -M -v -v -v -v -v -v 

# This one fails,return add reg num 108.
runtest $d1 $d2  ppc2/powerpc-750-linux-gnu-hello-static -a  -v -v -v -v -v -v 
runtest $d1 $d2  ppc2/powerpc-750-linux-gnu-hello-static -ka  -v -v -v -v -v -v 
# This one works, return address reg 108 allowed.
runtest $d1 $d2  ppc2/powerpc-750-linux-gnu-hello-static -a   -R -v -v -v -v -v -v 
runtest $d1 $d2  ppc2/powerpc-750-linux-gnu-hello-static -c   -R -v -v -v -v -v -v 
# This one works, return address reg 108 allowed.
runtest $d1 $d2  ppc2/powerpc-750-linux-gnu-hello-static -a -R -v -v -v -v -v -v -x name=./dwarfdump.conf  -x abi=ppc 
runtest $d1 $d2  ppc2/powerpc-750-linux-gnu-hello-static -c -R -v -v -v -v -v -v -x name=./dwarfdump.conf  -x abi=ppc 

runtest $d1 $d2  louzon/ppcobj.o -a  -v -v -v -v -v -v -x name=./dwarfdump.conf  -x abi=ppc
runtest $d1 $d2  louzon/ppcobj.o -ka -v -v -v -v -v -v -x name=./dwarfdump.conf  -x abi=ppc
runtest $d1 $d2  linkonce/comdattest.o -ka -v -v -v -v -v -v -x name=./dwarfdump.conf  -x abi=ppc
runtest $d1 $d2  linkonce/comdattest.o -a -v -v -v -v -v -v -x name=./dwarfdump.conf  -x abi=ppc
runtest $d1 $d2 atefail/ig_server -kt 
runtest $d1 $d2 irixn32/dwarfdump -f -x name=./dwarfdump.conf -x abi=mips-simple3  
runtest $d1 $d2 ia32/mytry.ia32 -F -x name=dwarfdump.conf -x abi=x86
runtest $d1 $d2 ia64/mytry.ia64 -F -x name=dwarfdump.conf -x abi=ia64 
runtest $d1 $d2  irixn32/dwarfdump -f -x name=./dwarfdump.conf -x abi=mips-simple 
runtest $d1 $d2 irixn32/dwarfdump -f -x name=./dwarfdump.conferr1 -x abi=mips
runtest $d1 $d2 val_expr/libpthread-2.5.so -f -v -v -x name=dwarfdump.conf -x abi=x86_64 
runtest $d1 $d2 irixn32/dwarfdump -i -G  -ka
runtest $d1 $d2 irixn32/dwarfdump -i -G -d  
runtest $d1 $d2 ia32/mytry.ia32 -i -G  
runtest $d1 $d2 ia32/mytry.ia32 -i -G -d  
runtest $d1 $d2 ia32/mytry.ia32 -ka -G -d 
runtest $d1 $d2 cristi2/libc-2.5.so -F -x name=dwarfdump.conf -x abi=x86
runtest $d1 $d2 ia32/libc.so.6 -F -f -x name=dwarfdump.conf -x abi=x86
runtest $d1 $d2 cristi2/libpthread-2.4.so -F -v -v -v -x name=dwarfdump.conf -x abi=x86
runtest $d1 $d2 cristi2/libpthread-2.4.so -R -F  -v -v -v
runtest $d1 $d2 cristi2/libpthread-2.4.so -R -ka  -v -v -v
runtest $d1 $d2 cristi3/cristibadobj -m 
runtest $d1 $d2 cristi3/cristibadobj -m  -v -v -v

echo PASS  $goodcount
echo FAIL  $failcount

for i in $f
do
   echo ===== $i all options
   for xtra in "" "-v" "-v -v"
   do
     for k in  $o
     do
	runtest $d1 $d2 $i $k $xtra
     done
   done
done

echo PASS  $goodcount
echo FAIL  $failcount
