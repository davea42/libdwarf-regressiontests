#!/bin/bash
# Run from the main regressiontests directory
for f in * */*
do
  file $f >/tmp/findobjb.tmp 2>/dev/null
  if [ $? -ne 0 ]
  then
    continue
  fi
  grep 'ELF.*relocatable' /tmp/findobjb.tmp >/dev/null 
  if [ $? -eq 0 ]
  then
    echo $f
  else
  grep 'ELF.*executable' /tmp/findobjb.tmp  >/dev/null
  if [ $? -eq 0 ]
  then
    echo $f
  else
  grep 'ELF.*shared object' /tmp/findobjb.tmp  >/dev/null
  if [ $? -eq 0 ]
  then
    echo $f
  fi
  fi
  fi
done

