.DEFAULT_GOAL := all
CXX = g++
CXXFLAGS = -g  -lfl

lex: onion_lang.lex
	flex  onion_lang.lex
	mv lex.yy.c lex.yy.cc
main: lex  
	$(CXX)  $(CXXFLAGS) lex.yy.cc -o onion
  
all: main
clean:
	rm -f *.o lex.yy.c lex.yy.cc
.PHONY: clean