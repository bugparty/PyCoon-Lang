
/* Mini Calculator */
/* calc.y */

%{
#include "heading.h"
#include "code_node.hpp"
#include <sstream>
#include <cassert>
int yyerror(char *s);
int yylex(void);
#define ENABLE_BISON_PRINTF 1  // Set this flag to 1 to enable printf, or 0 to disable it

#if ENABLE_BISON_PRINTF
    #define ODEBUG( ...) \
    do{printf("BISON: ");printf( __VA_ARGS__ );printf("\t\tFile:%s, lineno:%d\n",__FILE__,__LINE__);}while(0)
#else
    #define ODEBUG( ...)
#endif
#define OWARN( ...) \
    do{fprintf(stderr, "\e[35mBISON: ");printf( __VA_ARGS__ );printf("\t\tFile:%s, lineno:%d\e[0m\n",__FILE__,__LINE__);}while(0)
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
%token LEQ GEQ LE GE EQ NEQ

%right ASSIGNMENT
%left LOGICAL_ADD LOGICAL_OR
%left LEQ GEQ LE GE EQ NEQ
%left ADDING SUBTRACTING
%left MULTIPLYING DIVISION MODULE 
%left LEFT_PAR RIGHT_PAR



%nterm  statement add sub multi div mod statements quote assignment_stmt block_stmt while_stmt ifElse_stmt condition
%nterm greaterEqual greater smaller smallerEqual equal
%nterm loop_block for_stmt for_first_stmt
%nterm number_tuple function_arguments variable_declartion function_code_block
%nterm array_access_expr logical_op
%nterm loop_block_function number
%nterm function_declartion
%nterm condition_op

%type <codeNode> statement 
%type <codeNode> expr  arithmetic_expr condition_expr
%type <codeNode> quote_op arithmetic_op condition_op
%type <codeNode> add sub multi div mod
%type <codeNode> identifier number
%type <codeNode> read_stmt print_stmt
%type <codeNode> assignment_stmt
%type <codeNode> variable_declartion  single_variable_declartion
%type <codeNode> array_access_expr  array_access_stmt array_declartion_stmt
%type <codeNode> function_code_block functions function_declartion function_call_stmt
%type <codeNode>  function_arguments_declartion function_argument


%start entry

%%
number: NUMBER {ODEBUG("number -> NUMBER -> %i",$1->val.i );}
      | BINARY_NUMBER  {ODEBUG("number -> BINARY_NUMBER -> %d",$1 );}
      | HEX_NUMBER  {ODEBUG("number -> HEX_NUMBER -> %d",$1 );}
      ;
identifier: IDENTIFIER {ODEBUG("identifier -> IDENTIFIER -> %s",$1->sourceCode.c_str());
                    $$= $1;}
      ;
expr: quote_op {ODEBUG("LEFT_PAR expr RIGHT_PAR expr");}
    | number {ODEBUG("expr -> number ");}
    | identifier {ODEBUG("expr -> identifier -> ");}
    | arithmetic_expr {ODEBUG("expr -> arithmetic_expr");}
    | condition_expr {ODEBUG("expr -> condition_expr");}
    | array_access_stmt {ODEBUG("expr -> array_access_stmt");}
    | function_call_stmt {ODEBUG("expr -> function_call_stmt");}
    | %empty
    ;

quote_op: LEFT_PAR expr RIGHT_PAR {
        ODEBUG("quote_op-> LEFT_PAR expr RIGHT_PAR expr");
        $$ = $2;
}
arithmetic_op: MULTIPLYING {ODEBUG("arithmetic_op-> MULTIPLYING");}
            | DIVISION     {ODEBUG("arithmetic_op-> DIVISION");}
            | ADDING       {ODEBUG("arithmetic_op-> ADDING");}
            | SUBTRACTING  {ODEBUG("arithmetic_op-> SUBTRACTING");}
            | MODULE       {ODEBUG("arithmetic_op-> MODULE");}
            | logical_op   {ODEBUG("arithmetic_op-> logical_op");}
            ;
logical_op: LOGICAL_ADD  {ODEBUG("logical_op-> logical_ADD");}
          | LOGICAL_OR   {ODEBUG("logical_op-> logical_OR");}
          ;
arithmetic_expr :  expr arithmetic_op expr {ODEBUG("expr -> expr arithmetic_op expr");
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
                                ariOP = "%";
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
                           ODEBUG("unknown type "+$2->type);
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
condition_op: GE {ODEBUG("condition_op-> GE");}
           | GEQ {ODEBUG("condition_op-> GEQ");}
           | LE {ODEBUG("condition_op-> LE");}
           | LEQ {ODEBUG("condition_op-> LEQ");}
           | EQ {ODEBUG("condition_op-> EQ");}
           | NEQ {ODEBUG("condition_op-> NEQ");}
           ;
condition_expr : expr condition_op expr {ODEBUG("condition_expr -> expr condition_op expr");
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
                           ODEBUG("unknown type %d",$2->type);
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
number_tuple : number_tuple COMMA number  {ODEBUG("number_tuple -> number_tuple COMMA number");}
              | number {ODEBUG("number_tuple ->  number");}
              |%empty
              ;
multi_demension_number_tuple:  multi_demension_number_tuple COMMA  LEFT_CURLEY number_tuple RIGHT_CURLEY {ODEBUG("multi_demension_number_tuple -> multi_demension_number_tuple COMMA  LEFT_CURLEY number_tuple RIGHT_CURLEY");}
                          | LEFT_CURLEY number_tuple RIGHT_CURLEY {ODEBUG("multi_demension_number_tuple -> LEFT_CURLEY number_tuple RIGHT_CURLEY");}
                          ;
single_variable_declartion: INT identifier {ODEBUG("variable_declartion -> INT identifier");
           CodeNode *variableDeclarationNode = new CodeNode(YYSYMBOL_single_variable_declartion);
           stringstream ss;
           ss<<std::string(". ") + ($2->sourceCode)<<endl;
           variableDeclarationNode->addChild($2);
           variableDeclarationNode->subType = INT;
           variableDeclarationNode->val.str = new string($2->sourceCode);
           variableDeclarationNode->IRCode = ss.str();
           variableDeclarationNode->printIR();
           $$ = variableDeclarationNode;
           }
          ;
variable_declartion: array_declartion_stmt {ODEBUG("variable_declartion -> array_declartion_stmt");}
                  | single_variable_declartion {ODEBUG("variable_declartion -> single_variable_declartion");}
                  ;
array_declartion_stmt: INT IDENTIFIER  LEFT_BOX_BRAC number RIGHT_BOX_BRAC {ODEBUG("array_declartion_stmt -> INT IDENTIFIER  LEFT_BOX_BRAC number RIGHT_BOX_BRAC");
                      CodeNode *identifier = $2;
                      CodeNode *numberNode = $4;
                      CodeNode *newNode = new CodeNode(YYSYMBOL_array_declartion_stmt);
                      stringstream ss;
                      newNode->addChild(identifier);
                      newNode->addChild(numberNode);
                      ss<<std::string(".[] ")<<identifier->sourceCode<<std::string(", ")<<numberNode->sourceCode<<"\n";
                      newNode->IRCode = ss.str();
                      newNode->printIR();
                      $$ = newNode;

}
                    | array_declartion_stmt  LEFT_BOX_BRAC number RIGHT_BOX_BRAC {ODEBUG("array_declartion_stmt -> array_declartion_stmt  LEFT_BOX_BRAC number RIGHT_BOX_BRAC");}
                    ;
array_access_expr: IDENTIFIER LEFT_BOX_BRAC expr RIGHT_BOX_BRAC {ODEBUG("array_access_expr -> IDENTIFIER LEFT_BOX_BRAC expr RIGHT_BOX_BRAC");
                      CodeNode *identifier = $1;
                      CodeNode *expr = $3;
                      CodeNode *newNode = new CodeNode(YYSYMBOL_array_access_expr);
                      newNode->addChild(expr);
                      newNode->addChild(identifier);
                      
                      stringstream ss;
                      auto& ctx = SymbolManager::getInstance();
                      auto tempVar = ctx.allocate_temp(SymbolType::SYM_VAR_INT);
                      ss << ". " << tempVar <<endl;
                      ss<<"=[] "<<tempVar << "," << identifier->sourceCode<<", "<<expr->sourceCode<<"\n";
                      newNode->val.str = new string(tempVar);
                      newNode->IRCode = ss.str();
                      //Do not output this. array_access_expr content should only be output from array_access_stmt

                      $$ = newNode;


                      } 
            | array_access_expr LEFT_BOX_BRAC expr RIGHT_BOX_BRAC {ODEBUG("array_access_expr -> array_access_expr LEFT_BOX_BRAC expr RIGHT_BOX_BRAC");}
            ;

array_block_assignment_stmt: array_declartion_stmt ASSIGNMENT LEFT_CURLEY multi_demension_number_tuple  RIGHT_CURLEY {ODEBUG("array_block_assignment_stmt -> array_declartion_stmt ASSIGNMENT LEFT_CURLEY multi_demension_number_tuple  RIGHT_CURLEY");}
                    ;
array_access_stmt: IDENTIFIER ASSIGNMENT array_access_expr  {

        ODEBUG("array_access_stmt -> expr ASSIGNMENT array_access_expr");
        CodeNode *arrayNode = $3;
        CodeNode *identifier = $1;
        
        CodeNode *newNode = new CodeNode(YYSYMBOL_array_access_stmt);

        newNode->addChild(identifier);
        newNode->addChild(arrayNode);
        stringstream ss;
        ss<<"=[]"<< (identifier->sourceCode)<<", "<<*(arrayNode->val.str)<<endl;

        newNode->IRCode = ss.str();
        newNode->printIR();
        $$ = newNode;



        }
                    
assignment_stmt: INT IDENTIFIER ASSIGNMENT expr {
                ODEBUG("assignment_stmt -> INT IDENTIFIER ASSIGNMENT expr");
                CodeNode *identifierLeft = $2;
                stringstream ss;
                ss << "= " << identifierLeft->sourceCode << ", ";

                switch($4->type){
                        case IDENTIFIER:
                                ss << $4->sourceCode;
                                break;
                        case NUMBER:
                                ss << $4->val.i;
                                break;
                        case YYSYMBOL_arithmetic_op:
                                ss << *($4->val.str);
                                break;
                        default:
                                cout << "Invalid expr";
                                break;
                }

                CodeNode *newNode = new CodeNode(YYSYMBOL_assignment_stmt);
                ss << endl;
                newNode->IRCode = ss.str();
                newNode->printIR();
                $$ = newNode;
                }
          | array_access_expr ASSIGNMENT expr {
                ODEBUG("assignment_stmt -> array_access_expr ASSIGNMENT expr ");
                assert($1!=nullptr && $3!=nullptr);
                CodeNode *array_access_expr = $1;
                stringstream ss;
                ss << "= " << *(array_access_expr->val.str) << ", ";

                switch($3->type){
                        case IDENTIFIER:
                                ss << $3->sourceCode;
                                break;
                        case NUMBER:
                                ss << $3->val.i;
                                break;
                        case YYSYMBOL_arithmetic_op:
                        case YYSYMBOL_array_access_expr:
                                ss << *($3->val.str);
                                break;
                        default:
                                break;
                }

                CodeNode *newNode = new CodeNode(YYSYMBOL_assignment_stmt);
                ss << endl;
                newNode->IRCode = ss.str();
                newNode->printIR();
                $$ = newNode;
                
          }
          | IDENTIFIER ASSIGNMENT expr {
                ODEBUG("assignment_stmt -> IDENTIFIER ASSIGNMENT expr ");
                assert($1!=nullptr && $3!=nullptr);
                CodeNode *identifierLeft = $1;
                stringstream ss;
                ss << "= " << identifierLeft->sourceCode << ", ";

                switch($3->type){
                        case IDENTIFIER:
                                ss << $3->sourceCode;
                                break;
                        case NUMBER:
                                ss << $3->val.i;
                                break;
                        case YYSYMBOL_arithmetic_op:
                                ss << *($3->val.str);
                                break;
                        default:
                                break;
                }

                CodeNode *newNode = new CodeNode(YYSYMBOL_assignment_stmt);
                ss << endl;
                newNode->IRCode = ss.str();
                newNode->printIR();
                $$ = newNode;
                }
                | INT IDENTIFIER LEFT_BOX_BRAC number RIGHT_BOX_BRAC ASSIGNMENT expr {
                ODEBUG("assignment_stmt-> INT IDENTIFIER LEFT_BOX_BRAC number RIGHT_BOX_BRAC ASSIGNMENT expr");
                 CodeNode *identifier = $2;
                 CodeNode *numberNode = $4;
                 CodeNode *exprNode = $7;  

                 CodeNode *newNode = new CodeNode(YYSYMBOL_assignment_stmt);
                stringstream ss;
                ss<< ("[]= ")<<identifier->sourceCode<<(", ")<<numberNode->sourceCode<<std::string(", ")<<exprNode->sourceCode<<"\n";
                newNode->IRCode = ss.str();
                newNode->printIR();
                $$ = newNode;
      
                }
          | INT IDENTIFIER LEFT_BOX_BRAC number RIGHT_BOX_BRAC ASSIGNMENT LEFT_CURLEY number_tuple RIGHT_CURLEY {ODEBUG("assignment_stmt-> INT IDENTIFIER LEFT_BOX_BRAC number RIGHT_BOX_BRAC ASSIGNMENT LEFT_CURLEY number_tuple RIGHT_CURLEY");}
          | INT IDENTIFIER LEFT_BOX_BRAC  RIGHT_BOX_BRAC ASSIGNMENT LEFT_CURLEY number_tuple RIGHT_CURLEY {ODEBUG("assignment_stmt-> INT IDENTIFIER LEFT_BOX_BRAC  RIGHT_BOX_BRAC ASSIGNMENT LEFT_CURLEY number_tuple RIGHT_CURLEY");}
          
          ;
    

while_stmt: WHILE LEFT_PAR expr RIGHT_PAR LEFT_CURLEY loop_block  RIGHT_CURLEY {ODEBUG("while_stmt -> WHILE LEFT_PAR expr RIGHT_PAR LEFT_CURLEY loop_block  RIGHT_CURLEY");}
          ;
for_stmt: FOR LEFT_PAR statement SEMICOLON statement SEMICOLON statement RIGHT_PAR LEFT_CURLEY loop_block  RIGHT_CURLEY {ODEBUG("for_stmt -> FOR LEFT_PAR statement SEMICOLON statement SEMICOLON statement RIGHT_PAR LEFT_CURLEY loop_block  RIGHT_CURLEY");}
          ;
function_arguments_declartion  : function_arguments_declartion COMMA variable_declartion {ODEBUG( "function_arguments_declartion -> function_arguments_declartion COMMA variable_declartion");
                        CodeNode* arguments = $1;
                        arguments->addChild($3);
                        $$=arguments;
                }
                  | variable_declartion {ODEBUG( "function_arguments_declartion -> variable_declartion");
                                        CodeNode * newNode = new CodeNode(YYSYMBOL_function_arguments_declartion);
                                        newNode->addChild($1);
                                        $$=newNode;}
                  | %empty {
                        CodeNode * newNode = new CodeNode(YYSYMBOL_function_arguments_declartion);
                        $$=newNode;
                  }
                  ;
function_declartion : FUN IDENTIFIER LEFT_PAR function_arguments_declartion RIGHT_PAR LEFT_CURLEY function_code_block RIGHT_CURLEY {
                ODEBUG( "function -> FUN IDENTIFIER LEFT_PAR function_arguments_declartion RIGHT_PAR LEFT_CURLEY function_code_block RIGHT_CURLEY");
                CodeNode* identifer = $2;
                CodeNode* arguments = $4;   
                CodeNode* codes = $7;
 
                CodeNode* func = new CodeNode(YYSYMBOL_function_declartion);
                
                stringstream ss;
                ss << "func " << identifer->sourceCode<<endl;
               //processing arguments
                for(int i=0;i<arguments->children.size();i++){
                   ss<< ". "<< *(arguments->children[i]->val.str) << "," << "$" << i<<endl;
                }
                ss << codes->IRCode;
                ss << "endfunc"<<endl;
                func->IRCode = ss.str();
                func->printIR();
                $$=func;
                }
          ;

function_code_block: function_code_block  statement SEMICOLON {ODEBUG( "function_code_block -> function_code_block  statement SEMICOLON");
                $1->IRCode+=$2->IRCode;
                $$=$1;
                 }
          | statement SEMICOLON {
                ODEBUG( "function_code_block -> statement SEMICOLON");
                CodeNode* node = new CodeNode(YYSYMBOL_function_code_block);
                node->IRCode+=$1->IRCode;
                $$=node;
               
          }
          | function_code_block control_flow_stmt_function {
                ODEBUG( "function_code_block -> function_code_block control_flow_stmt_function");
                $$=$1;
                }
          | function_code_block RETURN expr SEMICOLON {
                ODEBUG( "function_code_block -> function_code_block RETURN expr SEMICOLON");
                stringstream ss;
                ss <<$1->IRCode<< "ret ";
                switch($3->type){
                        case NUMBER:
                                ss << $3->val.i;
                                break;
                        case IDENTIFIER:
                                ss << $3->sourceCode;
                                break;
                        case YYSYMBOL_arithmetic_op:
                                ss << *($3->val.str);
                                break;
                        default:
                           OWARN("unexpected type");
                           yyerror("unexpected type");
                }
                ss <<endl;
                $1->IRCode = ss.str();
                $1->printIR();
                $$=$1;
                }
          | %empty {
                CodeNode* node = new CodeNode(YYSYMBOL_function_code_block);
                 $$ = node;
          }
          ;

control_flow_stmt_function:  while_stmt {ODEBUG("block_stmt -> while_stmt");}
        | for_stmt {ODEBUG("block_stmt -> for_stmt");}
        | ifElse_stmt_function {ODEBUG("block_stmt -> ifElse_stmt_function");}
        ;

ifElse_stmt_function: if_stmt_function multi_elif_stmt_function else_stmt_function {ODEBUG("ifElse_stmt_function -> if_stmt_function multi_elif_stmt_function");}
                    | %empty
                    ;
if_stmt_function: IF LEFT_PAR expr RIGHT_PAR LEFT_CURLEY loop_block_function RIGHT_CURLEY {ODEBUG("if_stmt_function -> IF LEFT_PAR expr RIGHT_PAR LEFT_CURLEY loop_block_function RIGHT_CURLEY");}
                 ;
elif_stmt_function: ELIF LEFT_PAR expr RIGHT_PAR LEFT_CURLEY loop_block_function RIGHT_CURLEY {ODEBUG("elif_stmt: ELIF LEFT_PAR expr RIGHT_PAR LEFT_CURLEY code_block RIGHT_CURLEY");}
          ;
multi_elif_stmt_function: multi_elif_stmt_function elif_stmt_function {ODEBUG("multi_elif_stmt_function -> multi_elif_stmt_function else_stmt_function");}
                        |elif_stmt_function {ODEBUG("multi_elif_stmt_function -> else_stmt_function");}
                        |%empty
                        ;

else_stmt_function: ELSE LEFT_CURLEY loop_block_function RIGHT_CURLEY {ODEBUG("else_stmt_function -> ELSE LEFT_CURLEY loop_block RIGHT_CURLEY");}
          | %empty
          ;
elif_stmt: ELIF LEFT_PAR expr RIGHT_PAR LEFT_CURLEY code_block RIGHT_CURLEY {ODEBUG("elif_stmt: ELIF LEFT_PAR expr RIGHT_PAR LEFT_CURLEY code_block RIGHT_CURLEY");}
          ;

multi_elif_stmt: multi_elif_stmt elif_stmt {ODEBUG("multi_elif_stmt -> multi_elif_stmt elif_stmt");}
          | elif_stmt {ODEBUG("multi_elif_stmt -> elif_stmt");}
          | %empty
          ;

else_stmt: ELSE LEFT_CURLEY loop_block RIGHT_CURLEY {ODEBUG("else_stmt -> ELSE LEFT_CURLEY loop_block RIGHT_CURLEY");}
          | %empty
          ;
        
if_stmt:  IF LEFT_PAR expr RIGHT_PAR LEFT_CURLEY loop_block RIGHT_CURLEY {ODEBUG("if_stmt -> IF LEFT_PAR expr RIGHT_PAR LEFT_CURLEY loop_block RIGHT_CURLEY");}
          ;


ifElse_stmt: if_stmt multi_elif_stmt else_stmt {ODEBUG("ifElse_stmt -> if_stmt multi_elif_stmt else_stmt");}
          ;

function_argument: IDENTIFIER {ODEBUG("function_argument -> IDENTIFIER");}
                  | number {ODEBUG("function_argument -> number");}
                  | arithmetic_expr {ODEBUG("function_argument -> arithmetic_expr");}
                  | condition_expr {ODEBUG("function_argument -> condition_expr");}
                  | array_access_expr { ODEBUG("function_argument -> array_access_expr");}
                  | function_call_stmt {ODEBUG("function_argument -> function_call_stmt");}
                  ;
function_arguments  : function_arguments COMMA function_argument {ODEBUG("function_arguments -> function_arguments COMMA function_argument");}
                  | function_argument {ODEBUG("function_arguments -> function_argument ");}
                  | %empty
                  ;

function_call_stmt : IDENTIFIER LEFT_PAR function_arguments RIGHT_PAR {ODEBUG("function_call_stmt -> IDENTIFIER LEFT_PAR function_arguments RIGHT_PAR");}
                  | IDENTIFIER LEFT_PAR RIGHT_PAR  {ODEBUG("function_call_stmt -> IDENTIFIER LEFT_PAR RIGHT_PAR");}
                  ;

loop_block_function: loop_block_function code_block {ODEBUG("loop_block_function -> loop_block code_block");}
                  | loop_block_function BREAK SEMICOLON {ODEBUG("loop_block_function -> loop_block BREAK SEMICOLON");}
                  | loop_block_function RETURN expr {ODEBUG("loop_block_function -> loop_block_function RETURN expr");}
                  | %empty
                  ;

loop_block: loop_block code_block {ODEBUG("loop_block -> loop_block code_block");}
          | loop_block BREAK SEMICOLON {ODEBUG("loop_block -> loop_block BREAK SEMICOLON");}
          | %empty
          ;

code_block: code_block statement SEMICOLON { ODEBUG("code_block -> code_block statement SEMICOLON ");}
          | code_block control_flow_stmt { ODEBUG("code_block -> code_block control_flow_stmt ");}
          | code_block RETURN expr { ODEBUG("code_block -> code_block RETURN expr");}
          | %empty
          ;

control_flow_stmt: while_stmt {ODEBUG("block_stmt -> while_stmt");}
        | for_stmt {ODEBUG("block_stmt -> for_stmt");}
        | ifElse_stmt {ODEBUG("block_stmt -> ifElse_stmt");}
        ;
read_stmt: IDENTIFIER ASSIGNMENT READ LEFT_PAR RIGHT_PAR {
          ODEBUG("read_stmt -> IDENTIFIER ASSIGNMENT READ LEFT_PAR RIGHT_PAR");
          CodeNode *node = new CodeNode(YYSYMBOL_read_stmt);
          node->IRCode = std::string(".< ") + ($1->sourceCode) + std::string("\n");
          node->printIR();
          $$ = node; 
        }
        ;
print_stmt: PRINT LEFT_PAR expr RIGHT_PAR {
          ODEBUG("print_stmt-> PRINT LEFT_PAR expr RIGHT_PAR"); 
           CodeNode *node = new CodeNode(YYSYMBOL_print_stmt);
           stringstream ss;
           ss << ".> "<< *($3->val.str)<<endl;
          node->IRCode = ss.str();
          $$ = node; 
        }
        | PRINT LEFT_PAR identifier RIGHT_PAR {
          ODEBUG("print_stmt-> PRINT LEFT_PAR identifier RIGHT_PAR"); 
          CodeNode *node = new CodeNode(YYSYMBOL_print_stmt);
          stringstream ss;
          ss << ".> "<< $3->sourceCode<<endl;
          node->IRCode = ss.str();
          $$ = node; 
        }
        ;

statements: statements  statement SEMICOLON  {ODEBUG("statements -> statements  statement SEMICOLON");}
          | statements control_flow_stmt {ODEBUG("statements -> statements control_flow_stmt");}
          | statement SEMICOLON {ODEBUG("statements -> statement SEMICOLON");}
          | statements function_declartion {ODEBUG("statements -> statements function_declartion");}
          | %empty
          ;

statement: expr {ODEBUG("statement -> expr");}
          | assignment_stmt expr {ODEBUG("statement -> assignment_stmt expr");}
          | variable_declartion {ODEBUG("statement -> variable_declartion");}
          | function_call_stmt {ODEBUG("statement -> function_call_stmt");}
          | array_access_stmt
          | read_stmt
          | print_stmt
          | %empty
          ;

functions: functions function_declartion {
                ODEBUG("functions-> functions function_declartion");
                $1->addChild($2);
                $$=$1;
                }
        | %empty {
                CodeNode *node = new CodeNode(YYSYMBOL_functions);
                $$=node;
        }
        ;
entry: functions {
        ODEBUG("entry -> functions");
        puts("\e[36m");
        ODEBUG("full program mil code");
        puts("\e[32m");
        for(int i=0;i<$1->children.size();i++){
                assert($1->children[i]!=nullptr);
                cout << $1->children[i]->IRCode;
        }
        puts("\e[0m");
}
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


