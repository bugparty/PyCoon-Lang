.DEFAULT_GOAL := all
CXX = g++
CXXFLAGS = -g -lgtest -lgtest_main -lpthread -lgmock -lfl
INCS = -I./ -I../../src -I/usr/local/include -I/usr/include 
GTEST_DIR=/usr/local/include/gtest
GTEST_HEADERS = $(GTEST_DIR)/include/gtest/*.h \
                $(GTEST_DIR)/include/gtest/internal/*.h

lex: onion_lang.lex
	flex  onion_lang.lex
	mv lex.yy.c lex.yy.cc
main: lex  
	g++  main.cc  -lfl -o onion
gtest_install:
	./setup_gtest
tests: lex 
	$(CXX) $(CXXFLAGS)   -o tests tests.cc
    
all: main
clean:
	rm -f *.o lex.yy.c lex.yy.cc
.PHONY: clean