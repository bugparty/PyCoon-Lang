
OBJS	= bison.o lex.o main.o

CC	= g++
CFLAGS	=-ansi -std=c++17 -g -Wall  -pedantic -fpermissive -Wno-register -Wno-unused-function

onion:		$(OBJS)
		$(CC) $(CFLAGS) $(OBJS) -o onion -lfl

lex.o:		lex.c
		$(CC) $(CFLAGS) -c lex.c -o lex.o

lex.c:		onion_lang.lex 
		flex onion_lang.lex
		cp lex.yy.c lex.c

bison.o:	bison.c
		$(CC) $(CFLAGS) -c bison.c -o bison.o


bison.c:	onion_parser.y
		bison -d -v onion_parser.y
		cp onion_parser.tab.c bison.c
		cmp -s onion_parser.tab.h tok.h || cp onion_parser.tab.h tok.h


main.o:		main.cc
		$(CC) $(CFLAGS) -c main.cc -o main.o

lex.o yac.o main.o	: heading.h

lex.o main.o		: tok.h
run: onion
	./onion
clean:
	rm -f *.o *~ lex.c lex.yy.c bison.c tok.h onion_parser.tab.c onion_parser.tab.h onion onion_parser.output