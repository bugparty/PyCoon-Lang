lex: test.lex
	flex test.lex
all: lex
	gcc lex.yy.c -lfl
run: all
	./a.out
clean:
	rm -f *.o lex.yy.c
.PHONY: clean