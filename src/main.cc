/* main.cc */

#include "heading.h"
#include <cstring>
extern CodeNode* root;
// prototype of bison-generated parser function
int yyparse();

// Global flag to control whether to stop on first error (default: true)
bool stop_on_error = true;

int main(int argc, char **argv)
{
  //initialize the symbol manager and the states
  pushFunction("__global__");
  SymbolManager::getInstance();
  
  int file_arg_index = 1;
  
  /* Parse command line options */
  for (int i = 1; i < argc; i++) {
    if (strcmp(argv[i], "-p") == 0) {
      yydebug = 1;
      file_arg_index = i + 1;
    }
    else if (strcmp(argv[i], "-e") == 0 || strcmp(argv[i], "--stop-on-error") == 0) {
      stop_on_error = true;
      file_arg_index = i + 1;
    }
    else if (strcmp(argv[i], "-c") == 0 || strcmp(argv[i], "--continue-on-error") == 0) {
      stop_on_error = false;
      file_arg_index = i + 1;
    }
    else {
      // This should be the input file
      file_arg_index = i;
      break;
    }
  }
  
  /* Open input file if provided */
  if (file_arg_index < argc && freopen(argv[file_arg_index], "r", stdin) == NULL)
  {
    cerr << argv[0] << ": File " << argv[file_arg_index] << " cannot be opened.\n";
    exit( 1 );
  }
  
  yyparse();
  if(root!=nullptr){
    delete root;
  }

  return 0;
}
