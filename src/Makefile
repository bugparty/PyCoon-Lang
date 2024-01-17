lex: onion_lang.lex
	flex  onion_lang.lex
all: lex
	g++ lex.yy.c -lfl
run: all
	./a.out
clean:
	rm -f *.o lex.yy.c lex.yy.cc
.PHONY: clean