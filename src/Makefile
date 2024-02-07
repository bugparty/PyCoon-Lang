.DEFAULT_GOAL := all
CXX = g++
CXXFLAGS =  -lfl  -Wno-register -fpermissive
CC	= g++
CFLAGS	= -g -Wall -ansi -pedantic  -fpermissive

OBJS	= bison.o lex.o main.o

main: $(OBJS)
		$(CXX) $(CXXFLAGS) $(OBJS) -o calc -lfl
lex.o:		lex.cc
		$(CXX) $(CXXFLAGS) -c lex.cc -o lex.o

lex.cc: onion_lang.lex
	flex onion_lang.lex
	cp lex.yy.c lex.cc

bison.o:	bison.c
		$(CC) $(CFLAGS) -c bison.c -o bison.o
bison.c:	onion_parser.y
		bison -d -v onion_parser.y
		cp onion_parser.tab.c bison.c
		cmp -s onion_parser.tab.h tok.h || cp onion_parser.tab.h tok.h
main.o:		main.cc
		$(CXX) $(CXXFLAGS) -c main.cc -o main.o
# lex.o yac.o main.o	: heading.h
lex.o main.o		: tok.h
run: main
	./onion
all: main
clean:
	rm -f *.o lex.yy.c lex.yy.cc
.PHONY: clean