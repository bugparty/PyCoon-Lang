
OBJS	= bison.o lex.o main.o symbol_table.o

CC	= g++
CFLAGS	=-ansi -std=c++20 -g -Wall  -pedantic -fpermissive -Wno-register -Wno-unused-function  -Wno-write-strings

onion:		$(OBJS)
		$(CC) $(CFLAGS) $(OBJS) -o onion -lfl

lex.o:	lex.c onion_lang.lex
		$(CC) $(CFLAGS) -c lex.c -o lex.o

lex.c:	onion_lang.lex  code_node.hpp
		flex onion_lang.lex
		cp lex.yy.c lex.c

bison.o:	bison.c
		$(CC) $(CFLAGS) -c bison.c -o bison.o


bison.c onion_parser.tab.h onion_parser.tab.c:	onion_parser.y code_node.hpp
		bison -d -v onion_parser.y
		cp onion_parser.tab.c bison.c
tok.h: onion_parser.tab.h
	cmp -s onion_parser.tab.h tok.h || cp onion_parser.tab.h tok.h


main.o:		main.cc
		$(CC) $(CFLAGS) -c main.cc -o main.o

lex.o yac.o main.o	: heading.h

lex.o main.o		: tok.h

symbol_table.o: symbol_table.cpp symbol_table.hpp tok.h
		$(CC) $(CFLAGS) -c symbol_table.cpp -o symbol_table.o

symbol_table_tests.o: symbol_table_tests.cpp
		$(CC) $(CFLAGS) -c symbol_table_tests.cpp -o symbol_table_tests.o
		
symbol_tests: symbol_table.o symbol_table_tests.o
		$(CC) $(CFLAGS) symbol_table.o symbol_table_tests.o -o symbol_tests
mil_run:
	wget -O mil_run https://www.cs.ucr.edu/~dtan004/prac3/mil_run
	chmod +x mil_run
run: onion
	./onion
clean:
	rm -f *.o *~ lex.c lex.yy.c bison.c tok.h onion_parser.tab.c onion_parser.tab.h onion onion_parser.output a.mil