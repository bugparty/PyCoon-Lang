.DEFAULT_GOAL := all
CXX = g++
CXXFLAGS =  -lfl
lex: onion_lang.lex
	flex onion_lang.lex
	mv lex.yy.c lex.yy.cc

main: lex  
	g++ lex.yy.cc  main.cc -lfl -o onion
  
all: main
clean:
	rm -f *.o lex.yy.c lex.yy.cc
.PHONY: clean