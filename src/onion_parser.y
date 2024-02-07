/* Mini Calculator */
/* calc.y */

%{
#include "heading.h"
int yyerror(char *s);
int yylex(void);
%}


%define parse.error verbose
%define parse.lac full

%union{
    int tokenVal;
    char *tokenStr; 
};


%token arithmetic
%token <tokenVal> NUMBER
%token IDENTIFIER 
%token VARTYPE
%token FUN
%token INT
%token LEFT_PAR RIGHT_PAR
%token LEFT_BRAC RIGHT_BRAC
%left ADDING SUBTRACTING
%left MULTIPLYING DIVISION MODULE 

%nterm  statement add sub multi div mod statements
%type <tokenVal> statement add sub multi div mod
%start function

%%


function : FUN LEFT_PAR INT IDENTIFIER RIGHT_PAR LEFT_BRAC statements RIGHT_BRAC



statements: statements statement {printf("%s expression" ,$2);}
          | %empty
          ;

statement: add
         | sub
         | multi
         | div
         | mod
         | NUMBER
         ;
        
add:    LEFT_PAR statement ADDING statement RIGHT_PAR {$$ = $2 + $4;}

sub:    LEFT_PAR statement SUBTRACTING statement RIGHT_PAR {$$ = $2 - $4;}

multi:  LEFT_PAR statement MULTIPLYING statement RIGHT_PAR {$$ = $2 * $4;}

div: LEFT_PAR statement DIVISION statement RIGHT_PAR {$$ = $2 / $4;}

mod: LEFT_PAR statement MODULE statement RIGHT_PAR {$$ = $2 % $4;}

%%

int yyerror(string s)
{
  extern int yylineno;	// defined and maintained in lex.c
  extern char *yytext;	// defined and maintained in lex.c
  
  cerr << "ERROR: " << s << " at symbol \"" << yytext;
  cerr << "\" on line " << yylineno << endl;
  exit(1);
}

int yyerror(char *s)
{
  return yyerror(string(s));
}

