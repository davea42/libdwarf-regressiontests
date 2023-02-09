# Some sh functions for the runtest.sh use

cpifmissing() {
  s=$1
  t=$2
  if [ ! -f  $2 ]
  then
    cp $s $t
    if [ $? -ne 0 ]
    then
       echo "BASEFUNCS.sh: cp $s $t failed. Give up on this test"
       exit 1
    fi
  fi
}

# We want the names of dwarfdump to look alike
# whereever the dwarfdump is.
unifyddname () {
  nstart=$1
  nend=$2
  t1=junku1
  sed -e 'sx\/tmp.*\/dwarfdumpxdwarfdumpx' < $nstart >$t1 
  sed -e 'sx\..*\/dwarfdumpxdwarfdumpx' < $t1 >$nend
  rm -f $t1
}

setpythondirs() {
  p3=`which python3`
  if [ $? -eq 0 ]
  then
    mypydir=python3
    mypycom=$p3
  else
    p2=`which python2`
    if [ $? -eq 0 ]
    then
      mypydir=python2
      mypycom=$p2
    else
      echo "Cannot find python2 or python3"
      echo "give up"
      exit 1
    fi
  fi
}

checkargs () {
  nli=
  echo "void t(void) {int  x = 3; }" >sancheck.c
  for a in $*
  do
    if [ "x$CC" = "x" ]
    then
      CC=cc
    fi
    $CC $a -c sancheck.c -o junksancheck.o 2>/dev/null
    if [ $? -eq 0 ]
    then
      nli="$nli $a"
    fi
    rm -f junksancheck.o
  done
  rm -f sancheck.c
  rm -f junksancheck.o
  echo $nli
}

