
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
%token FUN RETURN
%token INT
%token LEFT_PAR RIGHT_PAR LEFT_CURLEY RIGHT_CURLEY
%token LEFT_BRAC RIGHT_BRAC
%token ASSIGNMENT
%token SEMICOLON COMMA
%token IF ELSE WHILE FOR ELIF
%token BREAK CONTINUE
%token LOGICAL_ADD LOGICAL_OR
%token READ PRINT
%token LEFT_BOX_BRAC RIGHT_BOX_BRAC

%left ADDING SUBTRACTING
%left MULTIPLYING DIVISION MODULE 
%token LEQ GEQ LE GE EQ

%nterm  statement add sub multi div mod statements quote assignment_stmt block_stmt while_stmt ifElse_stmt condition
%nterm greaterEqual greater smaller smallerEqual equal
%nterm loop_block for_stmt for_first_stmt
%nterm number_array function_arguments variable_declartion function_code_block

%type <tokenVal> statement add sub multi div mod
%type <tokenStr> expr
%start statements

%%

expr: LEFT_PAR expr RIGHT_PAR expr {cout<<"LEFT_PAR expr RIGHT_PAR expr"<<endl;}
    | NUMBER {cout<<"expr -> NUMBER -> "<<$1<<endl;}
    | IDENTIFIER {cout<<"expr -> IDENTIFIER -> "<<$1<<endl;}
    | arithmetic_expr {cout<<"expr -> arithmetic_expr"<<endl;}
    | condition_expr {cout << "expr -> condition_expr"<<endl;}
    | %empty {cout << "expr -> empty"<<endl;}
    ;

arithmetic_expr : | expr MULTIPLYING expr {cout << "expr -> expr MULTIPLYING expr"<<endl;}
    | expr DIVISION expr {cout << "expr -> expr DIVISION expr"<<endl;}
    | expr ADDING expr {cout << "expr -> expr ADDING expr"<<endl;}
    | expr SUBTRACTING expr {cout << "expr -> expr SUBTRACTING expr"<<endl;}
    | expr MODULE expr {cout << "expr -> expr MODULE expr"<<endl;}
    ;

condition_expr : expr GE expr {cout << "condition_expr -> expr GE expr"<<endl;}
              |expr GEQ expr {cout << "condition_expr -> expr GEQ expr"<<endl;}
              |expr LE expr {cout << "condition_expr -> expr LE expr"<<endl;}
              |expr LEQ expr {cout << "condition_expr -> expr LEQ expr"<<endl;}
              |expr EQ expr {cout << "condition_expr -> expr EQ expr"<<endl;}
              ;
number_array : number_array COMMA NUMBER  {cout << "number_array -> number_array COMMA NUMBER"<<endl;}
              | NUMBER {cout << "number_array ->  NUMBER"<<endl;}
              |%empty
              ;
variable_declartion: INT IDENTIFIER {cout << "variable_declartion -> INT IDENTIFIER"<<endl;}
          ;
assignment_stmt: INT IDENTIFIER ASSIGNMENT expr {cout << "assignment_stmt -> INT IDENTIFIER ASSIGNMENT IDENTIFIER"<<endl;}
          | INT IDENTIFIER ASSIGNMENT IDENTIFIER {cout << "assignment_stmt -> INT IDENTIFIER ASSIGNMENT IDENTIFIER"<<endl;}
          
          | IDENTIFIER ASSIGNMENT expr {cout << "assignment_stmt -> IDENTIFIER ASSIGNMENT expr "<<endl;}
          | INT IDENTIFIER LEFT_BOX_BRAC NUMBER RIGHT_BOX_BRAC {cout << "assignment_stmt -> INT IDENTIFIER LEFT_BOX_BRAC NUMBER RIGHT_BOX_BRAC"<<endl;}
          | INT IDENTIFIER LEFT_BOX_BRAC NUMBER RIGHT_BOX_BRAC ASSIGNMENT expr {cout << "assignment_stmt-> INT IDENTIFIER LEFT_BOX_BRAC NUMBER RIGHT_BOX_BRAC ASSIGNMENT expr"<<endl;}
          | INT IDENTIFIER LEFT_BOX_BRAC NUMBER RIGHT_BOX_BRAC ASSIGNMENT LEFT_CURLEY number_array RIGHT_CURLEY {cout << "assignment_stmt-> INT IDENTIFIER LEFT_BOX_BRAC NUMBER RIGHT_BOX_BRAC ASSIGNMENT LEFT_CURLEY number_array RIGHT_CURLEY"<<endl;}
          | INT IDENTIFIER LEFT_BOX_BRAC  RIGHT_BOX_BRAC ASSIGNMENT LEFT_CURLEY number_array RIGHT_CURLEY {cout << "assignment_stmt-> INT IDENTIFIER LEFT_BOX_BRAC NUMBER RIGHT_BOX_BRAC ASSIGNMENT expr"<<endl;}
          ;
    

while_stmt: WHILE LEFT_PAR expr RIGHT_PAR LEFT_CURLEY loop_block  RIGHT_CURLEY {cout << "while_stmt -> WHILE LEFT_PAR expr RIGHT_PAR LEFT_CURLEY loop_block  RIGHT_CURLEY"<<endl;}
          ;
for_stmt: FOR LEFT_PAR statement SEMICOLON statement SEMICOLON statement RIGHT_PAR LEFT_CURLEY loop_block  RIGHT_CURLEY {cout << "for_stmt -> FOR LEFT_PAR expr SEMICOLON expr SEMICOLON RIGHT_PAR LEFT_CURLEY loop_block RIGHT_CURLEY"<<endl;}
          ;
function_arguments : function_arguments COMMA variable_declartion
                  | variable_declartion
                  | %empty
                  ;
function_declartion : FUN IDENTIFIER LEFT_PAR variable_declartion RIGHT_PAR LEFT_CURLEY function_code_block RIGHT_CURLEY {cout << "function -> FUN LEFT_PAR INT IDENTIFIER RIGHT_PAR LEFT_BRAC statements RIGHT_BRAC"<<endl;}
          ;

function_code_block: function_code_block statement SEMICOLON 
          | function_code_block control_flow_stmt
          | function_code_block RETURN expr SEMICOLON
          | %empty
          ;

loop_block: loop_block code_block {cout << "loop_block -> loop_block statement SEMICOLON" <<endl;}
          | loop_block BREAK SEMICOLON {cout << "loop_block -> loop_block BREAK SEMICOLON" <<endl;}
          | %empty
          ;


code_block: code_block statement SEMICOLON { cout << "code_block -> code_block statement SEMICOLON "<<endl;}
          | code_block control_flow_stmt { cout << "code_block -> code_block control_flow_stmt "<<endl;}
          | %empty
          ;


control_flow_stmt: while_stmt {cout << "block_stmt -> while_stmt" <<endl;}
        | for_stmt {cout << "block_stmt -> for_stmt" <<endl;}
        | ifElse_stmt {cout << "block_stmt -> ifElse_stmt" <<endl;}
        ;

elif_stmt: ELIF LEFT_PAR expr RIGHT_PAR LEFT_CURLEY code_block RIGHT_CURLEY {cout << "elif_stmt: ELIF LEFT_PAR expr RIGHT_PAR LEFT_CURLEY code_block RIGHT_CURLEY" <<endl;}
          ;

multi_elif_stmt: multi_elif_stmt elif_stmt
          | elif_stmt
          | %empty
          ;

else_stmt: ELSE LEFT_CURLEY loop_block RIGHT_CURLEY
          | %empty
          ;
        
if_stmt:  IF LEFT_PAR expr RIGHT_PAR LEFT_CURLEY loop_block RIGHT_CURLEY {cout << "if_stmt -> IF LEFT_PAR expr RIGHT_PAR LEFT_CURLEY loop_block RIGHT_CURLEY" <<endl;}
          ;


ifElse_stmt: if_stmt multi_elif_stmt else_stmt {cout<<"ifElse_stmt -> if_stmt multi_elif_stmt else_stmt"<<endl;}
          ;

statements: statements  statement SEMICOLON  {cout << "statements -> statements SEMICOLON statement SEMICOLON" <<endl;}
          | statements control_flow_stmt {cout << "statements -> statements control_flow_stmt" <<endl;}
          | statement SEMICOLON {cout << "statements -> statements SEMICOLON" <<endl;}
          | statements function_declartion {cout << "statements -> statements function_declartion" <<endl;}
          | %empty
          ;

statement: expr {cout << "statement -> expr" <<endl;}
          | assignment_stmt expr {cout << "statement -> assignment_stmt" <<endl;}
          | variable_declartion
          | %empty
          ;


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


