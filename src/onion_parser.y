
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

%token <tokenStr> IDENTIFIER 
%token VARTYPE
%token FUN
%token INT
%token LEFT_PAR RIGHT_PAR LEFT_CURLEY RIGHT_CURLEY
%token LEFT_BRAC RIGHT_BRAC
%token ASSIGNMENT
%token SEMICOLON COMMA
%token WHILE FOR
%left ADDING SUBTRACTING
%left MULTIPLYING DIVISION MODULE 


%nterm  statement add sub multi div mod statements quote assignment_stmt
%type <tokenVal> statement add sub multi div mod
%type <tokenStr> expr
%start statements

%%
start: expr {cout << "start -> expr\n";}

expr: LEFT_PAR expr RIGHT_PAR expr {cout<<"LEFT_PAR expr RIGHT_PAR expr"<<endl;}
    | NUMBER {cout<<"NUMBER -> "<<$1<<endl;}
    | expr MULTIPLYING expr {cout << "expr -> expr MULTIPLYING expr"<<endl;}
    | expr DIVISION expr {cout << "expr -> expr DIVISION expr"<<endl;}
    | expr ADDING expr {cout << "expr -> expr ADDING expr"<<endl;}
    | expr SUBTRACTING expr {cout << "expr -> expr SUBTRACTING expr"<<endl;}
    | expr MODULE expr {cout << "expr -> expr MODULE expr"<<endl;}
    | %empty {cout << "expr -> empty"<<endl;}
    ;

assignment_stmt: INT IDENTIFIER ASSIGNMENT expr {cout << "assignment_stmt: VARTYPE IDENTIFIER ASSIGNMENT expr"<<endl;}
          | INT IDENTIFIER ASSIGNMENT IDENTIFIER {cout << "assignment_stmt: VARTYPE IDENTIFIER ASSIGNMENT IDENTIFIER"<<endl;}
          | INT IDENTIFIER {cout << "assignment_stmt: VARTYPE IDENTIFIER"<<endl;}
          ;
while_stmt: WHILE LEFT_PAR expr RIGHT_BRAC LEFT_CURLEY statements  RIGHT_CURLEY
function : FUN LEFT_PAR INT IDENTIFIER RIGHT_PAR LEFT_BRAC statements RIGHT_BRAC



statements: statements  statement SEMICOLON  {cout << "statements -> statements SEMICOLON statement SEMICOLON" <<endl;}
          | statement SEMICOLON
          | %empty
          ;
statement: expr
          | assignment_stmt
          | %empty
          ;


quote:   LEFT_PAR statements RIGHT_PAR    {printf("quote");}  
add:     statement ADDING statement {printf("add\n");}

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


