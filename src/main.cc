/* main.cc */

#include "heading.h"
#include <cstring>
extern CodeNode* root;
// prototype of bison-generated parser function
int yyparse();

int main(int argc, char **argv)
{
  //initialize the symbol manager and the states
  pushFunction("__global__");
  SymbolManager::getInstance();
  /* Enable parse traces on option -p. */
  if (argc == 2 && strcmp(argv[1], "-p") == 0)
    yydebug = 1;
  else if ((argc > 1) && (freopen(argv[1], "r", stdin) == NULL))
  {
    cerr << argv[0] << ": File " << argv[1] << " cannot be opened.\n";
    exit( 1 );
  }
  
  yyparse();
  if(root!=nullptr){
    root->debug();
    delete root;
  }

  return 0;
}
