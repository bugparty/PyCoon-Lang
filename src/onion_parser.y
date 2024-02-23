
/* Mini Calculator */
/* calc.y */

%{
#include "heading.h"
#include "code_node.hpp"
#include <sstream>
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
%nterm condition_op

%type <tokenVal> statement add sub multi div mod
%type <codeNode> expr  arithmetic_expr condition_expr
%type <codeNode> single_variable_declartion
%type <codeNode> identifier;
%type <codeNode> quote_op arithmetic_op condition_op
%type <codeNode> read_stmt print_stmt
%type <codeNode> array_declartion_stmt
%type <codeNode> number

%type <codeNode> array_access_expr assignment_stmt array_access_stmt
%type <codeNode> function_call_stmt function_declartion function_arguments_declartion


%start functions

%%
number: NUMBER {cout<<"number -> NUMBER -> "<<$1->val.i << endl;}
      | BINARY_NUMBER  {cout<<"number -> BINARY_NUMBER -> "<<$1 << endl;}
      | HEX_NUMBER  {cout<<"number -> HEX_NUMBER -> "<<$1 << endl;}
      ;
identifier: IDENTIFIER {cout<<"identifier -> IDENTIFIER -> "<<$1->sourceCode<<endl;
                    $$= $1;}
      ;
expr: quote_op {cout<<"LEFT_PAR expr RIGHT_PAR expr"<<endl;}
    | number {cout<<"expr -> number "<<endl;}
    | identifier {cout<<"expr -> identifier -> "<<endl;}
    | arithmetic_expr {cout<<"expr -> arithmetic_expr"<<endl;}
    | condition_expr {cout << "expr -> condition_expr"<<endl;}
    | array_access_stmt {cout << "expr -> array_access_stmt"<<endl;}
    | function_call_stmt {cout << "expr -> function_call_stmt"<<endl;}
    | %empty
    ;

quote_op: LEFT_PAR expr RIGHT_PAR {
        cout << "quote_op-> LEFT_PAR expr RIGHT_PAR expr" <<endl;
        $$ = $2;
}
arithmetic_op: MULTIPLYING {cout << "arithmetic_op-> MULTIPLYING"<<endl;}
            | DIVISION     {cout << "arithmetic_op-> DIVISION"<<endl;}
            | ADDING       {cout << "arithmetic_op-> ADDING"<<endl;}
            | SUBTRACTING  {cout << "arithmetic_op-> SUBTRACTING"<<endl;}
            | MODULE       {cout << "arithmetic_op-> MODULE"<<endl;}
            | logical_op   {cout << "arithmetic_op-> logical_op"<<endl;}
            ;
logical_op: LOGICAL_ADD
          | LOGICAL_OR
          ;
arithmetic_expr :  expr arithmetic_op expr {cout << "expr -> expr arithmetic_op expr"<<endl;
                CodeNode* addNode = new CodeNode(YYSYMBOL_arithmetic_op);
                string ariOP="WTF!!!!";
                switch($2->type){
                        case ADDING:
                                addNode->subType = ADDING;
                                ariOP = "+";
                                break;
                        case SUBTRACTING:
                                addNode->subType = SUBTRACTING;
                                ariOP = "-";
                                break;
                        case DIVISION:
                                addNode->subType = DIVISION;
                                ariOP = "/";
                                break;
                        case MULTIPLYING:
                                addNode->subType = DIVISION;
                                ariOP = "*";
                                break;
                        
                        case MODULE:
                                addNode->subType = MODULE;
                                ariOP = "\%";
                                break;
                        case LOGICAL_ADD:
                                addNode->subType = LOGICAL_ADD;
                                ariOP = "&&";
                                break;
                        case LOGICAL_OR:
                                addNode->subType = LOGICAL_OR;
                                ariOP = "||";
                                break;
                        default:
                           cout << "unknown type "+$2->type<<endl;
                           yyerror("unknown type "+$2->type);
                }
                        addNode->addChild($1);
                        addNode->addChild($3);
                        $$=addNode;
                        string tempVar = SymbolManager::getInstance().allocate_temp(SymbolType::SYM_VAR_INT);
                        stringstream ss;
                        ss<< $1->IRCode <<$3->IRCode;

                        ss << ". " << tempVar<<endl<<ariOP<< " "<<tempVar<<", ";
                        if($1->type == NUMBER){
                                ss << $1->val.i;
                        }else if ($1->type == YYSYMBOL_arithmetic_op){
                                ss << *($1->val.str);
                        }
                        ss <<", ";
                        if($3->type == NUMBER){
                                ss << $3->val.i;
                        }else if ($3->type == YYSYMBOL_arithmetic_op){
                                ss << *($3->val.str);
                        }
                        ss << endl;
                        addNode->IRCode = ss.str();
                        addNode->val.str = new string(tempVar);
                        addNode->printIR();
                }
    ;
condition_op: GE {cout << "condition_op-> GE"<<endl;}
           | GEQ {cout << "condition_op-> GEQ"<<endl;}
           | LE {cout << "condition_op-> LE"<<endl;}
           | LEQ{cout << "condition_op-> LEQ"<<endl;}
           | EQ
           | NEQ
           ;
condition_expr : expr condition_op expr {cout << "condition_expr -> expr condition_op expr"<<endl;
                CodeNode* addNode = new CodeNode(YYSYMBOL_arithmetic_op);
                string ariOP="WTF!!!!";
                switch($2->type){
                        case GE:
                                addNode->subType = ADDING;
                                ariOP = ">";
                                break;
                        case GEQ:
                                addNode->subType = SUBTRACTING;
                                ariOP = ">=";
                                break;
                        case LE:
                                addNode->subType = DIVISION;
                                ariOP = "<";
                                break;
                        case LEQ:
                                addNode->subType = DIVISION;
                                ariOP = "<=";
                                break;
                        
                        case EQ:
                                addNode->subType = MODULE;
                                ariOP = "==";
                                break;
                        case NEQ:
                                addNode->subType = LOGICAL_ADD;
                                ariOP = "!=";
                                break;
                        default:
                           cout << "unknown type "+$2->type<<endl;
                           //yyerror("unknown type "+$2->type);
                }
                        addNode->addChild($1);
                        addNode->addChild($3);
                        $$=addNode;
                        string tempVar = SymbolManager::getInstance().allocate_temp(SymbolType::SYM_VAR_INT);
                        stringstream ss;
                        ss<< $1->IRCode <<$3->IRCode;

                        ss << ". " << tempVar<<endl;
                        ss<< ariOP<< " "<<tempVar<<", ";
                        if($1->type == NUMBER){
                                ss << $1->val.i;
                        }else if ($1->type == YYSYMBOL_arithmetic_op){
                                ss << *($1->val.str);
                        }
                        ss <<", ";
                        if($3->type == NUMBER){
                                ss << $3->val.i;
                        }else if ($3->type == YYSYMBOL_arithmetic_op){
                                ss << *($3->val.str);
                        }
                        ss << endl;
                        addNode->IRCode = ss.str();
                        addNode->val.str = new string(tempVar);
                        addNode->printIR();
                }
              ;
number_array : number_array COMMA number  {cout << "number_array -> number_array COMMA number"<<endl;}
              | number {cout << "number_array ->  number"<<endl;}
              |%empty
              ;
multi_demension_number_array:  multi_demension_number_array COMMA  LEFT_CURLEY number_array RIGHT_CURLEY {cout << "multi_demension_number_array -> multi_demension_number_array COMMA  LEFT_CURLEY number_array RIGHT_CURLEY"<<endl;}
                          | LEFT_CURLEY number_array RIGHT_CURLEY {cout << "multi_demension_number_array -> LEFT_CURLEY number_array RIGHT_CURLEY"<<endl;}
                          ;
single_variable_declartion: INT identifier {cout << "variable_declartion -> INT identifier"<<endl;
           CodeNode *variableDeclarationNode = new CodeNode(YYSYMBOL_single_variable_declartion);
           stringstream ss;
           ss<<std::string(". ") + ($2->sourceCode);
           variableDeclarationNode->addChild($2);
           variableDeclarationNode->IRCode = ss.str();
           variableDeclarationNode->printIR();
           $$ = variableDeclarationNode;
           }
          ;
variable_declartion: array_declartion_stmt {cout << "variable_declartion -> array_declartion_stmt"<<endl;}
                  | single_variable_declartion {cout << "variable_declartion -> single_variable_declartion"<<endl;}
                  ;
array_declartion_stmt: INT IDENTIFIER  LEFT_BOX_BRAC number RIGHT_BOX_BRAC {cout << "array_declartion_stmt -> INT IDENTIFIER  LEFT_BOX_BRAC number RIGHT_BOX_BRAC"<<endl;
                      CodeNode *identifier = $2;
                      CodeNode *numberNode = $4;
                      CodeNode *newNode = new CodeNode(YYSYMBOL_array_declartion_stmt);
                      stringstream ss;
                      newNode->addChild(identifier);
                      newNode->addChild(numberNode);
                      ss<<std::string(".[] ")<<identifier->sourceCode<<std::string(", ")<<numberNode->sourceCode;
                      newNode->IRCode = ss.str();
                      newNode->printIR();
                      $$ = newNode;

}
                    | array_declartion_stmt  LEFT_BOX_BRAC number RIGHT_BOX_BRAC {cout << "array_declartion_stmt -> array_declartion_stmt  LEFT_BOX_BRAC number RIGHT_BOX_BRAC"<<endl;}
                    ;
array_access_expr: IDENTIFIER LEFT_BOX_BRAC expr RIGHT_BOX_BRAC {cout << "array_access_expr -> IDENTIFIER LEFT_BOX_BRAC expr RIGHT_BOX_BRAC"<<endl;
                      CodeNode *identifier = $1;
                      CodeNode *expr = $3;
                      CodeNode *newNode = new CodeNode(YYSYMBOL_array_access_expr);
                      newNode->addChild(expr);
                      newNode->addChild(identifier);

                      stringstream ss;
                      ss<<identifier->sourceCode<<std::string(", ")<<expr->sourceCode;

                      newNode->IRCode = ss.str();
                      newNode->printIR();
                      $$ = newNode;


                      } 
            | array_access_expr LEFT_BOX_BRAC expr RIGHT_BOX_BRAC {cout << "array_access_expr -> array_access_expr LEFT_BOX_BRAC expr RIGHT_BOX_BRAC"<<endl;}
            ;

array_block_assignment_stmt: array_declartion_stmt ASSIGNMENT LEFT_CURLEY multi_demension_number_array  RIGHT_CURLEY {cout << "array_block_assignment_stmt -> array_declartion_stmt ASSIGNMENT LEFT_CURLEY multi_demension_number_array  RIGHT_CURLEY"<<endl;}
                    ;
array_access_stmt: expr ASSIGNMENT array_access_expr  {

        cout << "array_access_stmt -> expr ASSIGNMENT array_access_expr"<<endl;
        CodeNode *arrayNode = $3;
        CodeNode *exprNode = $1;
        
        CodeNode *newNode = new CodeNode(YYSYMBOL_array_access_stmt);

        newNode->addChild(arrayNode);
        newNode->addChild(exprNode);
        stringstream ss;
        ss<<"=[]"<< exprNode->IRCode<<", "<<arrayNode->IRCode;

        newNode->IRCode = ss.str();
        newNode->printIR();
        $$ = newNode;



        }
                    
assignment_stmt: INT IDENTIFIER ASSIGNMENT expr {cout << "assignment_stmt -> INT IDENTIFIER ASSIGNMENT expr"<<endl;}
          | INT IDENTIFIER ASSIGNMENT IDENTIFIER {cout << "assignment_stmt -> INT IDENTIFIER ASSIGNMENT IDENTIFIER"<<endl;}
          | IDENTIFIER ASSIGNMENT expr {cout << "assignment_stmt -> IDENTIFIER ASSIGNMENT expr "<<endl;}
          | INT IDENTIFIER LEFT_BOX_BRAC number RIGHT_BOX_BRAC {cout << "assignment_stmt -> INT IDENTIFIER LEFT_BOX_BRAC number RIGHT_BOX_BRAC"<<endl;}
          | INT IDENTIFIER LEFT_BOX_BRAC number RIGHT_BOX_BRAC ASSIGNMENT expr {
                cout << "assignment_stmt-> INT IDENTIFIER LEFT_BOX_BRAC number RIGHT_BOX_BRAC ASSIGNMENT expr"<<endl;
                 CodeNode *identifier = $2;
                 CodeNode *numberNode = $4;
                 CodeNode *exprNode = $7;  
                 CodeNode *newNode = new CodeNode(YYSYMBOL_assignment_stmt);
                stringstream ss;
                
                ss<< std::string("[]= ")<<identifier->sourceCode<<std::string(", ")<<numberNode->sourceCode<<std::string(", ")<<exprNode->sourceCode;
                newNode->IRCode = ss.str();
                newNode->printIR();
                $$ = newNode;
      
                }
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
          CodeNode *node = new CodeNode(YYSYMBOL_read_stmt);
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
          CodeNode *node = new CodeNode(YYSYMBOL_print_stmt);
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

functions: functions function_declartion {cout << "functions-> functions function_declartion"<<endl;}
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


