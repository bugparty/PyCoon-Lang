
/* Mini Calculator */
/* calc.y */

%{
#include "heading.h"
#include "code_node.hpp"
int yyerror(char *s);
int yylex(void);
%}



%define parse.error verbose
%define parse.lac full

%union{
    int tokenVal;
    char *tokenStr; 
    struct CodeNode* codeNode;
};


%token arithmetic
%token <codeNode> NUMBER
%token <tokenVal> BINARY_NUMBER
%token <tokenVal> HEX_NUMBER
%token <codeNode> IDENTIFIER 
%token VARTYPE
%token FUN RETURN READ PRINT
%token <codeNode> INT
%token LEFT_PAR RIGHT_PAR LEFT_CURLEY RIGHT_CURLEY
%token LEFT_BRAC RIGHT_BRAC
%token ASSIGNMENT
%token SEMICOLON COMMA
%token IF ELSE WHILE FOR ELIF
%token BREAK CONTINUE
%token LOGICAL_ADD LOGICAL_OR
%token LEFT_BOX_BRAC RIGHT_BOX_BRAC

%left LOGICAL_ADD LOGICAL_OR
%left ADDING SUBTRACTING
%left MULTIPLYING DIVISION MODULE 
%left LEFT_PAR RIGHT_PAR
%token LEQ GEQ LE GE EQ NEQ

%nterm  statement add sub multi div mod statements quote assignment_stmt block_stmt while_stmt ifElse_stmt condition
%nterm greaterEqual greater smaller smallerEqual equal
%nterm loop_block for_stmt for_first_stmt
%nterm number_array function_arguments variable_declartion function_code_block
%nterm array_access_expr logical_op
%nterm loop_block_function number
%nterm function_declartion

%type <tokenVal> statement add sub multi div mod
%type <codeNode> expr
%type <codeNode> single_variable_declartion
%type <codeNode> identifier;
%type <codeNode> quote_op
%type <codeNode> read_stmt print_stmt
%start functions

%%
number: NUMBER {cout<<"number -> NUMBER -> "<<$1->val.i << endl;}
      | BINARY_NUMBER  {cout<<"number -> BINARY_NUMBER -> "<<$1 << endl;}
      | HEX_NUMBER  {cout<<"number -> HEX_NUMBER -> "<<$1 << endl;}
      ;
identifier: IDENTIFIER {cout<<"identifier -> IDENTIFIER -> "<<$1->sourceCode<<endl;
                    $$= $1;}
      ;
expr: quote_op {cout<<"LEFT_PAR expr RIGHT_PAR expr"<<endl; }
    | number {cout<<"expr -> number "<<endl;}
    | identifier {cout<<"expr -> identifier -> "<<endl;}
    | arithmetic_expr {cout<<"expr -> arithmetic_expr"<<endl;}
    | condition_expr {cout << "expr -> condition_expr"<<endl;}
    | array_access_expr {cout << "expr -> array_access_expr"<<endl;}
    | function_call_stmt {cout << "expr -> function_call_stmt"<<endl;}
    | %empty
    ;

quote_op: LEFT_PAR expr RIGHT_PAR expr {
        cout << "quote_op-> LEFT_PAR expr RIGHT_PAR expr" <<endl;
        CodeNode* quoteOpNode = new CodeNode(YYSYMBOL_quote_op);
        quoteOpNode->addChild($2);
        quoteOpNode->addChild($4);
        $$ = quoteOpNode;
}
arithmetic_op: MULTIPLYING
            | DIVISION
            | ADDING
            | SUBTRACTING
            | MODULE
            | logical_op
            ;
logical_op: LOGICAL_ADD
          | LOGICAL_OR
          ;
arithmetic_expr :  expr arithmetic_op expr {cout << "expr -> expr arithmetic_op expr"<<endl;}
    ;

condition_expr : expr GE expr {cout << "condition_expr -> expr GE expr"<<endl;}
              |expr GEQ expr {cout << "condition_expr -> expr GEQ expr"<<endl;}
              |expr LE expr {cout << "condition_expr -> expr LE expr"<<endl;}
              |expr LEQ expr {cout << "condition_expr -> expr LEQ expr"<<endl;}
              |expr EQ expr {cout << "condition_expr -> expr EQ expr"<<endl;}
              |expr NEQ expr {cout << "condition_expr -> expr NEQ expr"<<endl;}
              ;
number_array : number_array COMMA number  {cout << "number_array -> number_array COMMA number"<<endl;}
              | number {cout << "number_array ->  number"<<endl;}
              |%empty
              ;
multi_demension_number_array:  multi_demension_number_array COMMA  LEFT_CURLEY number_array RIGHT_CURLEY {cout << "multi_demension_number_array -> multi_demension_number_array COMMA  LEFT_CURLEY number_array RIGHT_CURLEY"<<endl;}
                          | LEFT_CURLEY number_array RIGHT_CURLEY {cout << "multi_demension_number_array -> LEFT_CURLEY number_array RIGHT_CURLEY"<<endl;}
                          ;
single_variable_declartion: INT identifier {cout << "variable_declartion -> INT identifier"<<endl;
           CodeNode *node = new CodeNode(YYSYMBOL_single_variable_declartion);
           node->IRCode = std::string(". ") + ($2->sourceCode);
           $$ = node;
           }
          ;
variable_declartion: array_declartion_stmt {cout << "variable_declartion -> array_declartion_stmt"<<endl;}
                  | single_variable_declartion {cout << "variable_declartion -> single_variable_declartion"<<endl;}
                  ;
array_declartion_stmt: INT IDENTIFIER  LEFT_BOX_BRAC number RIGHT_BOX_BRAC {cout << "array_declartion_stmt -> INT IDENTIFIER  LEFT_BOX_BRAC number RIGHT_BOX_BRAC"<<endl;}
                    | array_declartion_stmt  LEFT_BOX_BRAC number RIGHT_BOX_BRAC {cout << "array_declartion_stmt -> array_declartion_stmt  LEFT_BOX_BRAC number RIGHT_BOX_BRAC"<<endl;}
                    ;
array_access_expr: IDENTIFIER LEFT_BOX_BRAC expr RIGHT_BOX_BRAC {cout << "array_access_expr -> IDENTIFIER LEFT_BOX_BRAC expr RIGHT_BOX_BRAC"<<endl;}
            | array_access_expr LEFT_BOX_BRAC expr RIGHT_BOX_BRAC {cout << "array_access_expr -> array_access_expr LEFT_BOX_BRAC expr RIGHT_BOX_BRAC"<<endl;}
            ;

array_block_assignment_stmt: array_declartion_stmt ASSIGNMENT LEFT_CURLEY multi_demension_number_array  RIGHT_CURLEY {cout << "array_block_assignment_stmt -> array_declartion_stmt ASSIGNMENT LEFT_CURLEY multi_demension_number_array  RIGHT_CURLEY"<<endl;}
                    ;
array_assignment_stmt: array_access_expr ASSIGNMENT expr  {cout << "array_assignment_stmt -> array_access_expr ASSIGNMENT expr"<<endl;}
                    | array_block_assignment_stmt {cout << "array_assignment_stmt -> array_block_assignment_stmt"<<endl;}
                    ;
assignment_stmt: INT IDENTIFIER ASSIGNMENT expr {cout << "assignment_stmt -> INT IDENTIFIER ASSIGNMENT expr"<<endl;}
          | INT IDENTIFIER ASSIGNMENT IDENTIFIER {cout << "assignment_stmt -> INT IDENTIFIER ASSIGNMENT IDENTIFIER"<<endl;}
          | array_assignment_stmt {cout << "assignment_stmt -> array_assignment_stmt"<<endl;}
          | IDENTIFIER ASSIGNMENT expr {cout << "assignment_stmt -> IDENTIFIER ASSIGNMENT expr "<<endl;}
          | INT IDENTIFIER LEFT_BOX_BRAC number RIGHT_BOX_BRAC {cout << "assignment_stmt -> INT IDENTIFIER LEFT_BOX_BRAC number RIGHT_BOX_BRAC"<<endl;}
          | INT IDENTIFIER LEFT_BOX_BRAC number RIGHT_BOX_BRAC ASSIGNMENT expr {cout << "assignment_stmt-> INT IDENTIFIER LEFT_BOX_BRAC number RIGHT_BOX_BRAC ASSIGNMENT expr"<<endl;}
          | INT IDENTIFIER LEFT_BOX_BRAC number RIGHT_BOX_BRAC ASSIGNMENT LEFT_CURLEY number_array RIGHT_CURLEY {cout << "assignment_stmt-> INT IDENTIFIER LEFT_BOX_BRAC number RIGHT_BOX_BRAC ASSIGNMENT LEFT_CURLEY number_array RIGHT_CURLEY"<<endl;}
          | INT IDENTIFIER LEFT_BOX_BRAC  RIGHT_BOX_BRAC ASSIGNMENT LEFT_CURLEY number_array RIGHT_CURLEY {cout << "assignment_stmt-> INT IDENTIFIER LEFT_BOX_BRAC  RIGHT_BOX_BRAC ASSIGNMENT LEFT_CURLEY number_array RIGHT_CURLEY"<<endl;}
          ;
    

while_stmt: WHILE LEFT_PAR expr RIGHT_PAR LEFT_CURLEY loop_block  RIGHT_CURLEY {cout << "while_stmt -> WHILE LEFT_PAR expr RIGHT_PAR LEFT_CURLEY loop_block  RIGHT_CURLEY"<<endl;}
          ;
for_stmt: FOR LEFT_PAR statement SEMICOLON statement SEMICOLON statement RIGHT_PAR LEFT_CURLEY loop_block  RIGHT_CURLEY {cout << "for_stmt -> FOR LEFT_PAR statement SEMICOLON statement SEMICOLON statement RIGHT_PAR LEFT_CURLEY loop_block  RIGHT_CURLEY"<<endl;}
          ;
function_arguments_declartion  : function_arguments_declartion COMMA variable_declartion {cout << "function_arguments_declartion -> function_arguments_declartion COMMA variable_declartion"<<endl;}
                  | variable_declartion {cout << "function_arguments_declartion -> variable_declartion"<<endl;}
                  | %empty
                  ;
function_declartion : FUN IDENTIFIER LEFT_PAR function_arguments_declartion RIGHT_PAR LEFT_CURLEY function_code_block RIGHT_CURLEY {cout << "function -> FUN IDENTIFIER LEFT_PAR function_arguments_declartion RIGHT_PAR LEFT_CURLEY function_code_block RIGHT_CURLEY"<<endl;}
          ;

function_code_block: function_code_block  statement SEMICOLON {cout << "function_code_block -> function_code_block  statement SEMICOLON"<<endl;}
          | function_code_block control_flow_stmt_function {cout << "function_code_block -> function_code_block control_flow_stmt_function"<<endl;}
          | function_code_block RETURN expr SEMICOLON {cout << "function_code_block -> function_code_block RETURN expr SEMICOLON"<<endl;}
          | %empty
          ;

control_flow_stmt_function:  while_stmt {cout << "block_stmt -> while_stmt" <<endl;}
        | for_stmt {cout << "block_stmt -> for_stmt" <<endl;}
        | ifElse_stmt_function {cout << "block_stmt -> ifElse_stmt_function" <<endl;}
        ;

ifElse_stmt_function: if_stmt_function multi_elif_stmt_function else_stmt_function {cout << "ifElse_stmt_function -> if_stmt_function multi_elif_stmt_function"<<endl;}
                    | %empty
                    ;
if_stmt_function: IF LEFT_PAR expr RIGHT_PAR LEFT_CURLEY loop_block_function RIGHT_CURLEY {cout << "if_stmt_function -> IF LEFT_PAR expr RIGHT_PAR LEFT_CURLEY loop_block_function RIGHT_CURLEY"<<endl;}
                 ;
elif_stmt_function: ELIF LEFT_PAR expr RIGHT_PAR LEFT_CURLEY loop_block_function RIGHT_CURLEY {cout << "elif_stmt: ELIF LEFT_PAR expr RIGHT_PAR LEFT_CURLEY code_block RIGHT_CURLEY" <<endl;}
          ;
multi_elif_stmt_function: multi_elif_stmt_function elif_stmt_function {cout << "multi_elif_stmt_function -> multi_elif_stmt_function else_stmt_function"<<endl;}
                        |elif_stmt_function {cout << "multi_elif_stmt_function -> else_stmt_function"<<endl;}
                        |%empty
                        ;

else_stmt_function: ELSE LEFT_CURLEY loop_block_function RIGHT_CURLEY {cout << "else_stmt_function -> ELSE LEFT_CURLEY loop_block RIGHT_CURLEY"<<endl;}
          | %empty
          ;
elif_stmt: ELIF LEFT_PAR expr RIGHT_PAR LEFT_CURLEY code_block RIGHT_CURLEY {cout << "elif_stmt: ELIF LEFT_PAR expr RIGHT_PAR LEFT_CURLEY code_block RIGHT_CURLEY" <<endl;}
          ;

multi_elif_stmt: multi_elif_stmt elif_stmt {cout << "multi_elif_stmt -> multi_elif_stmt elif_stmt"<<endl;}
          | elif_stmt {cout << "multi_elif_stmt -> elif_stmt"<<endl;}
          | %empty
          ;

else_stmt: ELSE LEFT_CURLEY loop_block RIGHT_CURLEY {cout << "else_stmt -> ELSE LEFT_CURLEY loop_block RIGHT_CURLEY"<<endl;}
          | %empty
          ;
        
if_stmt:  IF LEFT_PAR expr RIGHT_PAR LEFT_CURLEY loop_block RIGHT_CURLEY {cout << "if_stmt -> IF LEFT_PAR expr RIGHT_PAR LEFT_CURLEY loop_block RIGHT_CURLEY" <<endl;}
          ;


ifElse_stmt: if_stmt multi_elif_stmt else_stmt {cout<<"ifElse_stmt -> if_stmt multi_elif_stmt else_stmt"<<endl;}
          ;

function_argument: IDENTIFIER {cout << "function_argument -> IDENTIFIER"<<endl;}
                  | number {cout << "function_argument -> number"<<endl;}
                  | arithmetic_expr {cout << "function_argument -> arithmetic_expr"<<endl;}
                  | condition_expr {cout << "function_argument -> condition_expr"<<endl;}
                  | array_access_expr {cout << "function_argument -> array_access_expr"<<endl;}
                  | function_call_stmt {cout << "function_argument -> function_call_stmt"<<endl;}
                  ;
function_arguments  : function_arguments COMMA function_argument {cout << "function_arguments -> function_arguments COMMA function_argument"<<endl;}
                  | function_argument {cout << "function_arguments -> function_argument "<<endl;}
                  | %empty
                  ;

function_call_stmt : IDENTIFIER LEFT_PAR function_arguments RIGHT_PAR {cout << "function_call_stmt -> IDENTIFIER LEFT_PAR function_arguments RIGHT_PAR"<<endl;}
                  | IDENTIFIER LEFT_PAR RIGHT_PAR  {cout << "function_call_stmt -> IDENTIFIER LEFT_PAR RIGHT_PAR"<<endl;}
                  ;

loop_block_function: loop_block_function code_block {cout << "loop_block_function -> loop_block code_block" <<endl;}
                  | loop_block_function BREAK SEMICOLON {cout << "loop_block_function -> loop_block BREAK SEMICOLON" <<endl;}
                  | loop_block_function RETURN expr {cout << "loop_block_function -> loop_block_function RETURN expr" <<endl;}
                  | %empty
                  ;

loop_block: loop_block code_block {cout << "loop_block -> loop_block code_block" <<endl;}
          | loop_block BREAK SEMICOLON {cout << "loop_block -> loop_block BREAK SEMICOLON" <<endl;}
          | %empty
          ;

code_block: code_block statement SEMICOLON { cout << "code_block -> code_block statement SEMICOLON "<<endl;}
          | code_block control_flow_stmt { cout << "code_block -> code_block control_flow_stmt "<<endl;}
          | code_block RETURN expr { cout << "code_block -> code_block RETURN expr"<<endl;}
          | %empty
          ;

control_flow_stmt: while_stmt {cout << "block_stmt -> while_stmt" <<endl;}
        | for_stmt {cout << "block_stmt -> for_stmt" <<endl;}
        | ifElse_stmt {cout << "block_stmt -> ifElse_stmt" <<endl;}
        ;
read_stmt: IDENTIFIER ASSIGNMENT READ LEFT_PAR RIGHT_PAR {
          cout << "read_stmt -> IDENTIFIER ASSIGNMENT READ LEFT_PAR RIGHT_PAR"<<endl;
          CodeNode *node = new CodeNode(0xffff0001);
          node->IRCode = std::string(".< ") + ($1->sourceCode);
          $$ = node; 
        }
        ;
print_stmt: PRINT LEFT_PAR expr RIGHT_PAR {
          cout <<"print_stmt-> PRINT LEFT_PAR expr RIGHT_PAR"<<endl; 
          //CodeNode *node = new CodeNode(0xffff0001);
          //node->IRCode = std::string(".> ") + ($2->sourceCode);
          //$$ = node; 
        }
        | PRINT LEFT_PAR identifier RIGHT_PAR {
          cout <<"print_stmt-> PRINT LEFT_PAR identifier RIGHT_PAR"<<endl; 
          CodeNode *node = new CodeNode(0xffff0001);
          node->IRCode = std::string(".> ") + ($3->sourceCode);
          $$ = node; 
        }
        ;

statements: statements  statement SEMICOLON  {cout << "statements -> statements  statement SEMICOLON" <<endl;}
          | statements control_flow_stmt {cout << "statements -> statements control_flow_stmt" <<endl;}
          | statement SEMICOLON {cout << "statements -> statement SEMICOLON" <<endl;}
          | statements function_declartion {cout << "statements -> statements function_declartion" <<endl;}
          | %empty
          ;

statement: expr {cout << "statement -> expr" <<endl;}
          | assignment_stmt expr {cout << "statement -> assignment_stmt expr" <<endl;}
          | variable_declartion {cout << "statement -> variable_declartion" <<endl;}
          | function_call_stmt {cout << "statement -> function_call_stmt" <<endl;}
          | read_stmt
          | print_stmt
          | %empty
          ;

functions: functions function_declartion
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


