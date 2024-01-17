.DEFAULT_GOAL := all
CXX = g++
CXXFLAGS = -g  -lfl
PROJECT_ROOT=src
lex: $(PROJECT_ROOT)/onion_lang.lex
	flex  $(PROJECT_ROOT)/onion_lang.lex
	mv $(PROJECT_ROOT)/lex.yy.c $(PROJECT_ROOT)/lex.yy.cc
main: lex  
	$(CXX)  $(CXXFLAGS) $(PROJECT_ROOT)/lex.yy.cc -o onion
  
all: main
clean:
	rm -f $(PROJECT_ROOT)/*.o $(PROJECT_ROOT)/lex.yy.c $(PROJECT_ROOT)/lex.yy.cc
.PHONY: clean