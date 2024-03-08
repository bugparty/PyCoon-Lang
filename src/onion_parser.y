
/* Mini Calculator */
/* calc.y */

%{
#include "heading.h"
#include "code_node.hpp"
#include <sstream>
#include <fstream>
#include <cassert>
int yyerror(char *s);
int yylex(void);
#define ENABLE_BISON_PRINTF 1  // Set this flag to 1 to enable printf, or 0 to disable it

#if ENABLE_BISON_PRINTF
    #define ODEBUG( ...) \
    do{printf("BISON: ");printf( __VA_ARGS__ );printf("\t\tFile:%s:%d:0\n",__FILE__,__LINE__);}while(0)
#else
    #define ODEBUG( ...)
#endif
#define OWARN( ...) \
    do{fprintf(stderr, "\e[35mBISON: ");printf( __VA_ARGS__ );printf("\t\tFile:%s:%d:0\e[0m\n",__FILE__,__LINE__);}while(0)

#define OERROR( ...) \
    do{fprintf(stderr, "\e[31mBISON: ");printf( __VA_ARGS__ );printf("\t\tFile:%s:%d:0\e[0m\n",__FILE__,__LINE__);yyerror("error");}while(0)
%}


/*
use ./onion -p to enable parser tracing
*/
/* Generate the parser description file. */
%verbose
/* Enable run-time traces (yydebug). */
%define parse.trace
%define parse.error verbose
/* look ahead trace */
//%define parse.lac full

%union{
    int tokenVal;
    char *tokenStr; 
    struct CodeNode* codeNode;
};


%token <codeNode> NUMBER
%token <codeNode> BINARY_NUMBER
%token <codeNode> HEX_NUMBER
%token <codeNode> IDENTIFIER 
%token FUN RETURN READ PRINT
%token  INT
%token LEFT_PAR RIGHT_PAR LEFT_CURLEY RIGHT_CURLEY
%token LEFT_BRAC RIGHT_BRAC
%token ASSIGNMENT
%token SEMICOLON COMMA
%token IF ELSE WHILE FOR ELIF
%token BREAK CONTINUE
%token LOGICAL_ADD LOGICAL_OR
%token LEFT_BOX_BRAC RIGHT_BOX_BRAC
%token LEQ GEQ LE GE EQ NEQ
%token ADDING SUBTRACTING MULTIPLYING DIVISION MODULE

%left NUMBER
%left BINARY_NUMBER
%left HEX_NUMBER
%right ASSIGNMENT
%left LOGICAL_ADD LOGICAL_OR
%left LEQ GEQ LE GE EQ NEQ
%left ADDING SUBTRACTING
%left MULTIPLYING DIVISION MODULE 
%left LEFT_PAR RIGHT_PAR
%left IDENTIFIER
%right IF
%right ELSE
%right ELIF

%nterm  statement   assignment_stmt block_stmt while_stmt ifElse_stmt condition
%nterm loop_block for_stmt for_first_stmt
%nterm number_tuple function_arguments variable_declartion function_code_block
%nterm right_array_access_expr logical_op
%nterm loop_block_function number
%nterm function_declartion
%nterm condition_op arithmetic_op multiply_op term1 term2 factor 

%type <codeNode>  statement statement1 statement2 statement3
%type <codeNode> expr arithmetic_expr
%type <codeNode>  arithmetic_op condition_op 
%type <codeNode> identifier number
%type <codeNode> read_stmt print_stmt
%type <codeNode> assignment_stmt function_arguments_declartion_non_empty
%type <codeNode> variable_declartion  single_variable_declartion
%type <codeNode> left_array_access_expr right_array_access_expr  array_access_stmt array_declartion_stmt
%type <codeNode> function_code_block functions function_declartion function_call_stmt
%type <codeNode>  function_arguments_declartion function_argument function_arguments
%type <codeNode> control_flow_stmt_function loop_block_function loop_block
%type <codeNode>  multiply_op factor add_op logical_op
%type <codeNode> term1 term2 term3 term4 term5 term6 term7 loop_block_function_non_empty
%type <codeNode> for_stmt_function
%start entry

%%
number: NUMBER {ODEBUG("number -> NUMBER -> %i",$1->val.i );
                $1->type = O_INT;
                $$= $1;}
      | BINARY_NUMBER  {
                ODEBUG("number -> BINARY_NUMBER -> %d",$1 );
                $1->type = O_INT;
                $$= $1;}
      | HEX_NUMBER  {ODEBUG("number -> HEX_NUMBER -> %d",$1 );
                $1->type = O_INT;
                $$= $1;}
      ;
identifier: IDENTIFIER {ODEBUG("identifier -> IDENTIFIER -> %s",$1->sourceCode.c_str());
                    $$= $1;}
      ;
      
expr: arithmetic_expr {ODEBUG("expr -> arithmetic_expr");$$ = $1;}
    ;

multiply_op: MULTIPLYING {ODEBUG("multiply_op-> MULTIPLYING");}
            | DIVISION     {ODEBUG("multiply_op-> DIVISION");}         
            | MODULE       {ODEBUG("multiply_op-> MODULE");}
            ;
add_op:  ADDING       {ODEBUG("add_op-> ADDING");}
        | SUBTRACTING  {ODEBUG("add_op-> SUBTRACTING");}
            ;
logical_op: LOGICAL_ADD  {ODEBUG("logical_op-> logical_ADD");}
          | LOGICAL_OR   {ODEBUG("logical_op-> logical_OR");}
          ;
condition_op: GE {ODEBUG("condition_op-> GE");}
           | GEQ {ODEBUG("condition_op-> GEQ");}
           | LE {ODEBUG("condition_op-> LE");}
           | LEQ {ODEBUG("condition_op-> LEQ");}
           | EQ {ODEBUG("condition_op-> EQ");}
           | NEQ {ODEBUG("condition_op-> NEQ");}
           ;

arithmetic_expr : arithmetic_expr logical_op term1 {
                ODEBUG("arithmetic_expr -> expr logical_op term1");
                CodeNode* addNode = new CodeNode(O_EXPR);
                string ariOP="WTF!!!!";
                switch($2->type){

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
                        
                        string tempVar = SymbolManager::getInstance()->allocate_temp(SymbolType::SYM_VAR_INT);
                        stringstream ss;
                        ss<< $1->IRCode <<$3->IRCode;

                        ss << ". " << tempVar<<endl<<ariOP<< " "<<tempVar<<", ";
                        if($1->type == O_INT){
                                ss << $1->val.i;
                        }else if ($1->type == O_EXPR){
                                ss << *($1->val.str);
                        }else{
                                OERROR("unexpected type %d", $1->type);
                        }
                        ss <<", ";
                        if($3->type == O_INT){
                                ss << $3->val.i;
                        }else if ($3->type == O_EXPR){
                                ss << *($3->val.str);
                        }else{
                                OERROR("unexpected type %d", $3->type);
                        }
                        ss << endl;
                        addNode->IRCode = ss.str();
                        addNode->val.str = new string(tempVar);
                        addNode->printIR();
                        $$=addNode;
                        }
                | term1 {ODEBUG("arithmetic_expr -> term1 ");
                        $$ = $1;
                }
                ;
term1 : term1 condition_op term2 {
                ODEBUG("term1 -> term1 condition_op term2");
                CodeNode* addNode = new CodeNode(O_EXPR);
                string ariOP="WTF!!!!";
                switch($2->type){
                        case GE:
                                addNode->subType = GE;
                                ariOP = ">";
                                break;
                        case GEQ:
                                addNode->subType = GEQ;
                                ariOP = ">=";
                                break;
                        case LE:
                                addNode->subType = LE;
                                ariOP = "<";
                                break;
                        case LEQ:
                                addNode->subType = LEQ;
                                ariOP = "<=";
                                break;
                        
                        case EQ:
                                addNode->subType = EQ;
                                ariOP = "==";
                                break;
                        case NEQ:
                                addNode->subType = NEQ;
                                ariOP = "!=";
                                break;
                        default:
                           ODEBUG("unknown type %d",$2->type);
                                yyerror("unknown type ");
                }
                        addNode->addChild($1);
                        addNode->addChild($3);
                        $$=addNode;
                        string tempVar = SymbolManager::getInstance()->allocate_temp(SymbolType::SYM_VAR_INT);
                        stringstream ss;
                        ss<< $1->IRCode <<$3->IRCode;
                        ss << ". " << tempVar<<endl;
                        ss<< ariOP<< " "<<tempVar<<", ";
                        if($1->type == O_INT){
                                ss << $1->val.i;
                        }else if ($1->type == O_EXPR){
                                ss << *($1->val.str);
                        }
                        ss <<", ";
                        if($3->type == O_INT){
                                ss << $3->val.i;
                        }else if ($3->type == O_EXPR){
                                ss << *($3->val.str);
                        }
                        ss << endl;
                        addNode->IRCode = ss.str();
                        addNode->val.str = new string(tempVar);
                        addNode->printIR();

                                }
        | term2 {ODEBUG("term1 -> term2 ");$$ = $1;}
        ;
term2 :  term2 add_op term3 {
                ODEBUG("term2 -> term2 add_op term3");
                CodeNode* addNode = new CodeNode(O_EXPR);
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
                        default:
                           ODEBUG("unknown type "+$2->type);
                           $2->debug();
                           yyerror("unknown type "+$2->type);
                }
                        addNode->addChild($1);                       
                        addNode->addChild($3);
                        
                        string tempVar = SymbolManager::getInstance()->allocate_temp(SymbolType::SYM_VAR_INT);
                        stringstream ss;
                        ss<< $1->IRCode <<$3->IRCode;
                        ss << ". " << tempVar<<endl<<ariOP<< " "<<tempVar<<", ";
                        if($1->getImmOrVariableIRCode(ss)==false){
                                $1->debug();
                                OERROR("unexpected type %d", $1->type);
                                
                        }
                        ss <<", ";
                        if($3->getImmOrVariableIRCode(ss)==false){
                                $1->debug();
                                OERROR("unexpected type %d", $1->type);
                                
                        }
                        ss << endl;
                        addNode->IRCode = ss.str();
                        addNode->val.str = new string(tempVar);
                        addNode->printIR();
                        $$=addNode;
                }
                |term3 {ODEBUG("term2 -> term3 ");$$ = $1;}
    ;
term3 : term3 multiply_op factor {ODEBUG("term3 -> term3 multiply_op factor");
                ODEBUG("term2 -> term2 add_op term3");
                CodeNode* addNode = new CodeNode(O_EXPR);
                string ariOP="WTF!!!!";
                switch($2->type){
                        case MULTIPLYING:
                                addNode->subType = ADDING;
                                ariOP = "*";
                                break;
                        case DIVISION:
                                addNode->subType = SUBTRACTING;
                                ariOP = "/";
                                break;
                        case MODULE:
                                addNode->subType = MODULE;
                                ariOP = "%";
                                break;
                        default:
                           ODEBUG("unknown type "+$2->type);
                           $2->debug();
                           yyerror("unknown type "+$2->type);
                }
                        addNode->addChild($1);                       
                        addNode->addChild($3);
                        $$=addNode;
                        string tempVar = SymbolManager::getInstance()->allocate_temp(SymbolType::SYM_VAR_INT);
                        stringstream ss;
                        ss<< $1->IRCode <<$3->IRCode;
                        ss << ". " << tempVar<<endl<<ariOP<< " "<<tempVar<<", ";
                        if($1->type == O_INT){
                                ss << $1->val.i;
                        }else if ($1->type == O_EXPR){
                                ss << *($1->val.str);
                        }else{
                                $1->debug();
                                OERROR("unexpected type %d", $1->type);
                                
                        }
                        ss <<", ";
                        if($3->type == O_INT){
                                ss << $3->val.i;
                        }else if ($3->type == O_EXPR){
                                ss << *($3->val.str);
                        }else{
                                OERROR("unexpected type %d", $3->type);
                        }
                        ss << endl;
                        addNode->IRCode = ss.str();
                        addNode->val.str = new string(tempVar);
                        addNode->printIR();}
        | factor {ODEBUG("term3 ->factor");$$ = $1;}
        ;
factor:  term4 {ODEBUG("factor-> term4");$$ = $1;}
        ;
term4: number {ODEBUG("factor-> NUMBER");$$ = $1;}
        | term5 {ODEBUG("factor-> term5");$$ = $1;}
        ;
term5:  IDENTIFIER {ODEBUG("term5-> IDENTIFIER %s",$1->sourceCode.c_str());$$ = $1;}
        |term6 {ODEBUG("factor-> term6");$$ = $1;}
        ;
term6: LEFT_PAR arithmetic_expr RIGHT_PAR  {ODEBUG("term6-> LEFT_PAR expr RIGHT_PAR ");$$=$2;}
       ;


number_tuple : number_tuple COMMA number  {ODEBUG("number_tuple -> number_tuple COMMA number");}
              | number {ODEBUG("number_tuple ->  number");}
              |%empty
              ;
multi_demension_number_tuple:  multi_demension_number_tuple COMMA  LEFT_CURLEY number_tuple RIGHT_CURLEY {ODEBUG("multi_demension_number_tuple -> multi_demension_number_tuple COMMA  LEFT_CURLEY number_tuple RIGHT_CURLEY");}
                          | LEFT_CURLEY number_tuple RIGHT_CURLEY {ODEBUG("multi_demension_number_tuple -> LEFT_CURLEY number_tuple RIGHT_CURLEY");}
                          ;
single_variable_declartion: INT IDENTIFIER {ODEBUG("single_variable_declartion -> INT identifier");
           //it should be the first time to seen the identifier
           CodeNode *identifer = $2;
           auto ctx = SymbolManager::getInstance();
           Symbol* sym = ctx->find(identifer->sourceCode,currentFunction());
           if(sym!=nullptr){
                OWARN("redeclaration of variable %s",identifer->sourceCode.c_str());
                yyerror("redeclaration of variable ");
           }else{
                ctx->addSymbol(identifer->sourceCode, currentFunction(),SymbolType::SYM_VAR_INT);
           }
           ctx->debugPrint();
           CodeNode *variableDeclarationNode = new CodeNode(O_VAR_DECLARATION);
           stringstream ss;
           ss<<". " << $2->sourceCode<<endl;
           variableDeclarationNode->addChild($2);
           variableDeclarationNode->subType = INT;
           //variableDeclarationNode->val.str = new string($2->sourceCode);
           variableDeclarationNode->sourceCode = ($2->sourceCode);
           variableDeclarationNode->IRCode = ss.str();
           variableDeclarationNode->printIR();
           $$ = variableDeclarationNode;
           }
          ;
variable_declartion: array_declartion_stmt {ODEBUG("variable_declartion -> array_declartion_stmt");$$=$1;}
                  | single_variable_declartion {ODEBUG("variable_declartion -> single_variable_declartion");$$=$1;}
                  ;
array_declartion_stmt: INT IDENTIFIER  LEFT_BOX_BRAC number RIGHT_BOX_BRAC {ODEBUG("array_declartion_stmt -> INT IDENTIFIER  LEFT_BOX_BRAC number RIGHT_BOX_BRAC");
                      CodeNode *identifier = $2;

                      auto ctx = SymbolManager::getInstance();
                      Symbol* sym = ctx->find(identifier->sourceCode,currentFunction());
                      if(sym!=nullptr)
                      {
                      OWARN("redeclaration of array variable %s",identifier->sourceCode);
                      yyerror("redeclaration of variable ");
                      }
                      else
                        {
                        ctx->addSymbol(identifier->sourceCode,currentFunction(), SymbolType::SYM_VAR_INT_ARRAY);
                        }

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
right_array_access_expr: IDENTIFIER LEFT_BOX_BRAC expr RIGHT_BOX_BRAC {
                      ODEBUG("right_array_access_expr -> IDENTIFIER LEFT_BOX_BRAC expr RIGHT_BOX_BRAC");
                      CodeNode *identifier = $1;
                      CodeNode *expr = $3;
                      CodeNode *newNode = new CodeNode(YYSYMBOL_right_array_access_expr);
                      newNode->addChild(expr);
                      newNode->addChild(identifier);
                      
                      stringstream ss;
                      auto ctx = SymbolManager::getInstance();
                      auto tempVar = ctx->allocate_temp(SymbolType::SYM_VAR_INT);
                      ss << ". " << tempVar <<endl;
                      ss<<"=[] "<<tempVar << "," << identifier->sourceCode<<", "<<expr->sourceCode<<"\n";
                      newNode->val.str = new string(tempVar);
                      newNode->IRCode = ss.str();
                      //Do not output this. array_access_expr content should only be output from array_access_stmt

                      $$ = newNode;
                      } 
            | right_array_access_expr LEFT_BOX_BRAC expr RIGHT_BOX_BRAC {ODEBUG("array_access_expr -> array_access_expr LEFT_BOX_BRAC expr RIGHT_BOX_BRAC");}
            ;
left_array_access_expr: IDENTIFIER LEFT_BOX_BRAC expr RIGHT_BOX_BRAC {
                      ODEBUG("left_array_access_expr -> IDENTIFIER LEFT_BOX_BRAC expr RIGHT_BOX_BRAC");
                      CodeNode *identifier = $1;
                      CodeNode *expr = $3;
                      CodeNode *newNode = new CodeNode(YYSYMBOL_left_array_access_expr);
                      newNode->addChild(identifier);
                      newNode->addChild(expr);
                      stringstream ss;           
                      ss<<$3->IRCode;
                      newNode->IRCode = ss.str();
                      newNode->printIR();
                      $$ = newNode;


                      } 
            | left_array_access_expr LEFT_BOX_BRAC expr RIGHT_BOX_BRAC {
                ODEBUG("array_access_expr -> array_access_expr LEFT_BOX_BRAC expr RIGHT_BOX_BRAC");
                CodeNode *right_array_access_expr = $1;
                right_array_access_expr->addChild($3);
                right_array_access_expr->IRCode += $3->IRCode;
                $$ = right_array_access_expr;
                }
            ;

array_block_assignment_stmt: array_declartion_stmt ASSIGNMENT LEFT_CURLEY multi_demension_number_tuple  RIGHT_CURLEY {ODEBUG("array_block_assignment_stmt -> array_declartion_stmt ASSIGNMENT LEFT_CURLEY multi_demension_number_tuple  RIGHT_CURLEY");}
                    ;
array_access_stmt: IDENTIFIER ASSIGNMENT right_array_access_expr  {

        ODEBUG("array_access_stmt -> IDENTIFIER ASSIGNMENT right_array_access_expr");
        CodeNode *arrayNode = $3;
        CodeNode *identifier = $1;
        
        CodeNode *newNode = new CodeNode(YYSYMBOL_array_access_stmt);

        newNode->addChild(identifier);
        newNode->addChild(arrayNode);
        stringstream ss;
        ss << $3->IRCode;
        ss<<"= "<< (identifier->sourceCode)<<", "<<*(arrayNode->val.str)<<endl;

        newNode->IRCode = ss.str();
        newNode->printIR();
        $$ = newNode;

        }
                    
assignment_stmt: array_access_stmt 
                | single_variable_declartion ASSIGNMENT expr{
                ODEBUG("assignment_stmt -> INT IDENTIFIER ASSIGNMENT expr");
                CodeNode *identifierLeft = $1;
                CodeNode *expr = $3;
                stringstream ss;
                ss << ". " << identifierLeft->sourceCode<<endl;
                ss << expr->IRCode;
                ss << "= " << identifierLeft->sourceCode << ", ";
                
                switch(expr->type){
                        case IDENTIFIER:
                                ss << expr->sourceCode;
                                break;
                        case O_INT:
                                ss << expr->val.i;
                                break;
                        case O_EXPR:
                                ss << *(expr->val.str);
                                break;
                        default:
                                cout << "Invalid expr";
                                break;
                }

                CodeNode *newNode = new CodeNode(YYSYMBOL_assignment_stmt);
                ss << endl;
                newNode->IRCode = ss.str();
                newNode->printIR();
                newNode->addChild(identifierLeft);
                newNode->addChild(expr);
                $$ = newNode;
                }
          | left_array_access_expr ASSIGNMENT expr {
                ODEBUG("assignment_stmt -> left_array_access_expr ASSIGNMENT expr ");
                assert($1!=nullptr && $3!=nullptr);
                CodeNode *array_access_expr = $1;
                stringstream ss;
                ss << $1->IRCode;
                ss << $3->IRCode;
                assert(array_access_expr->children.size()==2);
                assert(array_access_expr->children[0]->type == IDENTIFIER);
                ss << "[]= " << (array_access_expr->children[0]->sourceCode) << ", " ;
                switch(array_access_expr->children[1]->type){
                        case IDENTIFIER:
                                ss << array_access_expr->children[1]->sourceCode;
                                break;
                        case O_INT:
                                ss << array_access_expr->children[1]->val.i;
                                break;
                        case O_EXPR:
                                ss << *($3->val.str);
                                break;
                        default:
                                break;
                }
                ss<<", ";
                switch($3->type){
                        case IDENTIFIER:
                                ss << $3->sourceCode;
                                break;
                        case O_INT:
                                ss << $3->val.i;
                                break;
                        case O_EXPR:
                        case YYSYMBOL_left_array_access_expr:
                                ss << *($3->val.str);
                                break;
                        default:
                                break;
                }

                CodeNode *newNode = new CodeNode(YYSYMBOL_assignment_stmt);
                ss << endl;
                newNode->IRCode = ss.str();
                newNode->addChild($1);
                newNode->addChild($3);
                newNode->printIR();
                $$ = newNode;
                
          }
          | IDENTIFIER ASSIGNMENT expr {
                ODEBUG("assignment_stmt -> IDENTIFIER ASSIGNMENT expr ");
                assert($1!=nullptr && $3!=nullptr);
                CodeNode *identifierLeft = $1;
                stringstream ss;
                ss << $3->IRCode;
                ss << "= " << identifierLeft->sourceCode << ", ";

                switch($3->type){
                        case IDENTIFIER:
                                ss << $3->sourceCode;
                                break;
                        case O_INT:
                                ss << $3->val.i;
                                break;
                        case O_EXPR:
                                ss << *($3->val.str);
                                break;
                        default:
                                break;
                }

                CodeNode *newNode = new CodeNode(YYSYMBOL_assignment_stmt);
                ss << endl;
                newNode->IRCode = ss.str();
                newNode->addChild($1);
                newNode->addChild($3);
                newNode->printIR();
                $$ = newNode;
                }
          | single_variable_declartion ASSIGNMENT function_call_stmt {
                ODEBUG("assignment_stmt -> single_variable_declartion ASSIGNMENT function_call_stmt ");
                assert($1!=nullptr && $3!=nullptr);
                $3->debug();
                CodeNode *identifierLeft = $1;
                stringstream ss;
                ss << $1->IRCode;
                ss << $3->IRCode;
                ss << "= " << identifierLeft->sourceCode << ", ";
                ss << *($3->val.str) <<endl;
                CodeNode *newNode = new CodeNode(YYSYMBOL_assignment_stmt);
                newNode->IRCode = ss.str();
                newNode->addChild($1);
                newNode->addChild($3);
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
                newNode->addChild($2);
                newNode->addChild($4);
                newNode->addChild($7);
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
function_arguments_declartion  : function_arguments_declartion_non_empty {ODEBUG( "function_arguments_declartion -> function_arguments_declartion_non_empty");}
                        | %empty {ODEBUG( "function_arguments_declartion -> empty");
                                CodeNode *node = new CodeNode(YYSYMBOL_function_arguments_declartion);
                                $$=node;}
                        ;

function_arguments_declartion_non_empty  : function_arguments_declartion_non_empty COMMA variable_declartion {ODEBUG( "function_arguments_declartion -> function_arguments_declartion COMMA variable_declartion");
                        CodeNode* arguments = $1;
                        arguments->IRCode+=$3->IRCode;
                        arguments->addChild($3);
                        $$=arguments;
                        }
                  | variable_declartion {ODEBUG( "function_arguments_declartion -> variable_declartion");
                                        CodeNode * newNode = new CodeNode(YYSYMBOL_function_arguments_declartion);
                                        newNode->addChild($1);
                                        $$=newNode;}
                  ;
function_declartion : FUN IDENTIFIER {
                ODEBUG( "function_declartion -> FUN IDENTIFIER");
                //push the identifier to the stack, it will be used in the next half of the function_declartion
                push_code_node($2);
                pushFunction($2->sourceCode);
                } 
        LEFT_PAR function_arguments_declartion RIGHT_PAR LEFT_CURLEY function_code_block RIGHT_CURLEY {
                ODEBUG( "function -> FUN IDENTIFIER LEFT_PAR function_arguments_declartion RIGHT_PAR LEFT_CURLEY function_code_block RIGHT_CURLEY");
                //pop the identifier from the stack
                CodeNode* identifer = pop_code_node();
                assert(identifer!=nullptr);
                CodeNode* arguments = $5;   
                CodeNode* codes = $8;
 
                CodeNode* func = new CodeNode(YYSYMBOL_function_declartion);
                
                stringstream ss;
                ss << "func " << identifer->getImmOrVariableIRCode()<<endl;
                //querying if the function type is already defined
                auto ctx = SymbolManager::getInstance();
                vector<Symbol*> args;
                for(int i=0;i<arguments->children.size();i++){
                        args.push_back(new Symbol(arguments->children[i]->getImmOrVariableIRCode(), SymbolType::SYM_VAR_INT));
                }
                Symbol* sym = ctx->addFunction(identifer->getImmOrVariableIRCode(), args);
                if(sym==nullptr){
                        OWARN("redeclaration of function %s",identifer->getImmOrVariableIRCode().c_str());
                        yyerror("redeclaration of function");
                }
               /*processing arguments,will generate the IR code for the arguments
               sample:
               . a
               = a, $0
                */
  
                for(int i=0;i<arguments->children.size();i++){
                   ss<< ". " << arguments->children[i]->getImmOrVariableIRCode()<<endl;
                   ss << "= "<< arguments->children[i]->getImmOrVariableIRCode()<< ", " << "$" << i<<endl;
                }
                
                ss << codes->IRCode;
                ss << "endfunc"<<endl;
                func->IRCode = ss.str();
                func->printIR();
                func->addChild(identifer);
                func->addChild(arguments);
                func->addChild(codes);
                popFunction();
                $$=func;
                }
          ;

function_code_block: function_code_block  statement SEMICOLON {ODEBUG( "function_code_block -> function_code_block  statement SEMICOLON");
                $1->IRCode+=$2->IRCode;
                $1->addChild($2);
                $$=$1;
                 }
          | function_code_block control_flow_stmt_function {
                ODEBUG( "function_code_block -> function_code_block control_flow_stmt_function");
                ODEBUG("test1");
                $1->debug();
                ODEBUG("test 2");
                $2->debug();
                ODEBUG("test 3");
                $1->IRCode+=$2->IRCode;
                $1->addChild($2);
                $$=$1;
                }
          | function_code_block RETURN expr SEMICOLON {
                ODEBUG( "function_code_block -> function_code_block RETURN expr SEMICOLON");
                stringstream ss;
                ss << $3->IRCode;
                ss <<$1->IRCode<< "ret ";
                switch($3->type){
                        case O_INT:
                                ss << $3->val.i;
                                break;
                        case IDENTIFIER:
                                ss << $3->sourceCode;
                                break;
                        case O_EXPR:
                                ss << *($3->val.str);
                                break;
                        default:
                           OWARN("unexpected type");
                           yyerror("unexpected type");
                }
                ss <<endl;
                $1->IRCode = ss.str();
                $1->printIR();
                $1->addChild($3);
                $$=$1;
}
          | statement SEMICOLON {ODEBUG( "function_code_block ->  statement SEMICOLON");
                $$=$1;
                 }
         | RETURN expr SEMICOLON {
                ODEBUG( "function_code_block -> RETURN expr SEMICOLON");
                CodeNode *node = new CodeNode(O_FUNC_RETURN);
                stringstream ss;
                ss << $2->IRCode;
                ss << "ret ";
                switch($2->type){
                        case O_INT:
                                ss << $2->val.i;
                                break;
                        case IDENTIFIER:
                                ss << $2->sourceCode;
                                break;
                        case O_EXPR:
                                ss << *($2->val.str);
                                break;
                        default:
                           OWARN("unexpected type");
                           yyerror("unexpected type");
                }
                ss <<endl;
                node->IRCode = ss.str();
                node->printIR();
                node->addChild($2);
                $$=node;
                }
        | control_flow_stmt_function {
                ODEBUG( "function_code_block -> control_flow_stmt_function");
                $$=$1;
                }
          ;

control_flow_stmt_function:  while_stmt_function {ODEBUG("control_flow_stmt_function -> while_stmt");}
        | for_stmt_function {
                ODEBUG("control_flow_stmt_function -> for_stmt");
                $$ = $1;
                }
        | ifElse_stmt_function {ODEBUG("control_flow_stmt_function -> ifElse_stmt_function");
                CodeNode *node = new CodeNode(O_IF_STMT);
                $$ = node;}
        ;
while_stmt_function: WHILE LEFT_PAR expr RIGHT_PAR LEFT_CURLEY loop_block_function  RIGHT_CURLEY {ODEBUG("while_stmt -> WHILE LEFT_PAR expr RIGHT_PAR LEFT_CURLEY loop_block  RIGHT_CURLEY");}
          ;


for_stmt_function: FOR LEFT_PAR assignment_stmt SEMICOLON expr SEMICOLON assignment_stmt RIGHT_PAR LEFT_CURLEY loop_block_function  RIGHT_CURLEY
        {
        ODEBUG("for_stmt -> FOR LEFT_PAR statement SEMICOLON statement SEMICOLON statement RIGHT_PAR LEFT_CURLEY loop_block  RIGHT_CURLEY");
        CodeNode *newNode = new CodeNode(O_FOR_STMT);
        CodeNode *loop_control_var = $3; 
        CodeNode *loopContinueCondition =$5;
        CodeNode *incrementVar = $7;
        stringstream ss;

        std::string loop_control_variable = loop_control_var->children.at(0)->sourceCode;
         

        ss<< loop_control_var->IRCode;

       
        
        ss<<"= "<<loopContinueCondition->getImmOrVariableIRCode()<<", "<<loop_control_variable<<endl;

         
        

        
        //This must be before the loopbody so we will not redeclare var
        //Label declaration
       
        auto label_loop_start = SymbolManager::getInstance()->allocate_label();
        auto label_loop_body = SymbolManager::getInstance()->allocate_label();
        auto label_loop_end = SymbolManager::getInstance()->allocate_label();

        auto tempCond = SymbolManager::getInstance()->allocate_temp(SymbolType::SYM_VAR_INT); //Borrowed from ifelse
        ss << ". " << tempCond <<endl;
        ss << "> " << tempCond << " , " << loopContinueCondition->getImmOrVariableIRCode() << ", 0" << endl;

        
        ss<<": "<<label_loop_start<<endl;

        ss << "?:= " << label_loop_body << ", " << tempCond << endl;
        ss << ":= " << label_loop_end << endl;

        ss<<": "<<label_loop_body<<endl;
        ss<<$10->IRCode; //Code Body
        ss<<incrementVar->IRCode; //increment, like i++

        ss<<": "<<label_loop_end<<endl;
        
       
        //We jump back to the label if the condition is still true;

        //?:= label, predicate
        //If predicate is true(1) goto label
        
        //: label 
        //declares label

        //:= label
        //goto labels 

       
        

        newNode->IRCode = ss.str();
        newNode->addChild($3);
        newNode->addChild($5);
        newNode->addChild($7);
        $$=newNode;
        } 
          ;
ifElse_stmt_function: if_stmt_function multi_elif_stmt_function else_stmt_function {ODEBUG("ifElse_stmt_function -> if_stmt_function multi_elif_stmt_function");}
                    | if_stmt_function else_stmt_function {ODEBUG("ifElse_stmt_function -> if_stmt_function else_stmt_function ");}
                    ;
if_stmt_function: IF LEFT_PAR expr RIGHT_PAR LEFT_CURLEY loop_block_function RIGHT_CURLEY {ODEBUG("if_stmt_function -> IF LEFT_PAR expr RIGHT_PAR LEFT_CURLEY loop_block_function RIGHT_CURLEY");}
                 ;
elif_stmt_function: ELIF LEFT_PAR expr RIGHT_PAR LEFT_CURLEY loop_block_function RIGHT_CURLEY {ODEBUG("elif_stmt: ELIF LEFT_PAR expr RIGHT_PAR LEFT_CURLEY code_block RIGHT_CURLEY");}
          ;
multi_elif_stmt_function: multi_elif_stmt_function elif_stmt_function {ODEBUG("multi_elif_stmt_function -> multi_elif_stmt_function else_stmt_function");}
                        |elif_stmt_function {ODEBUG("multi_elif_stmt_function -> else_stmt_function");}
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

function_argument: arithmetic_expr {ODEBUG("function_argument -> arithmetic_expr");$$=$1;} 
                        
                  | right_array_access_expr { ODEBUG("function_argument -> array_access_expr"); $$=$1;}
                  ;
function_arguments  : function_arguments COMMA function_argument {
                        ODEBUG("function_arguments -> function_arguments COMMA function_argument");$1->addChild($3);
                        $1->IRCode+=$3->IRCode;
                        $1->printIR();
                        $$=$1;}
                  | function_argument {ODEBUG("function_arguments -> function_argument"); 
                        CodeNode *node = new CodeNode(O_FUNC_ARGS);
                        node->IRCode = $1->IRCode;
                        node->addChild($1);
                        node->printIR();
                        $$=node;}
                  | %empty {ODEBUG("function_arguments -> %%empty");
                        CodeNode *node = new CodeNode(YYSYMBOL_function_arguments);
                        $$=node;
                  }
                  ;

function_call_stmt : IDENTIFIER LEFT_PAR function_arguments RIGHT_PAR {
                        ODEBUG("function_call_stmt -> IDENTIFIER LEFT_PAR function_arguments RIGHT_PAR");
                        
                        CodeNode *node = new CodeNode(O_FUNC_CALL);
                        //function name
                        node->sourceCode = $1->sourceCode;
                        for(int i=0;i<$3->children.size();i++){
                                node->addChild($3->children[i]);
                        }
                        stringstream ss;
                        ss << $3->IRCode;
                        node->genFunctionCallIRCode(ss);
                        node->IRCode = ss.str();
                        node->printIR();
                        node->debug();
                        $$=node;
                        }
                  ;
loop_block_function: %empty {ODEBUG("loop_block_function -> %empty");
                        CodeNode *node = new CodeNode(YYSYMBOL_loop_block_function);
                        $$=node;}
                | loop_block_function_non_empty {ODEBUG("loop_block_function -> loop_block_function_non_empty");
                        $$=$1;}
                ;
loop_block_function_non_empty: loop_block_function_non_empty BREAK  {ODEBUG("loop_block_function -> loop_block BREAK SEMICOLON");}
                  | function_code_block
                  | BREAK SEMICOLON
                  ;

loop_block:  code_block {ODEBUG("loop_block -> loop_block code_block");}
          | loop_block BREAK  {ODEBUG("loop_block -> loop_block BREAK SEMICOLON");}
          | %empty
          ;

code_block: code_block statement SEMICOLON { ODEBUG("code_block -> code_block statement SEMICOLON ");}
          | code_block control_flow_stmt { ODEBUG("code_block -> code_block control_flow_stmt ");}
          | statement SEMICOLON
          | control_flow_stmt
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
          CodeNode*expr = $3;
           CodeNode *node = new CodeNode(YYSYMBOL_print_stmt);
           stringstream ss;
           ss << expr->IRCode;
           ss << ".> ";
           expr->getImmOrVariableIRCode(ss);
           ss << endl;
          node->IRCode = ss.str();
          $$ = node; 
        }
        ;


statement: statement2
          | expr {ODEBUG("statement -> expr");$$=$1;}
          | variable_declartion {ODEBUG("statement -> variable_declartion");$$=$1;}
          | read_stmt          {ODEBUG("statement -> read_stmt");$$=$1;}
          | print_stmt         {ODEBUG("statement -> print_stmt");}
          ;
statement2: assignment_stmt {ODEBUG("statement -> assignment_stmt");
                $$=$1;
                }
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
        fstream fout("a.mil", ios::out);
        for(int i=0;i<$1->children.size();i++){
                assert($1->children[i]!=nullptr);
                cout << $1->children[i]->IRCode;
                fout << $1->children[i]->IRCode;
        }
        puts("\e[0m");
        fout.close();
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


