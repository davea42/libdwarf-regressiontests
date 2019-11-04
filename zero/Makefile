# Copyright 2019 David Anderson.
# This trivial Makefile is hereby placed into the public domain.

CXXFLAGS = -g -Wall
all: zero
zero: zero.cc
	$(CXX) $(CXXFLAGS) zero.cc -o zero
clean:
	-rm -f zero
	-rm -f *.o
	-rm -f testdata

test:
	sh TEST
