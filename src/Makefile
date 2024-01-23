.DEFAULT_GOAL := all
CXX = g++
CXXFLAGS =  -lfl  -Wno-error=register
lex: onion_lang.lex
	flex onion_lang.lex
	mv lex.yy.c lex.yy.cc

main: lex  
	g++ lex.yy.cc  main.cc -lfl -Wno-register -o onion
run: main
	./onion
all: main
clean:
	rm -f *.o lex.yy.c lex.yy.cc
.PHONY: clean