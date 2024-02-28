
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




%define parse.error verbose
%define parse.lac full

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

%right ASSIGNMENT
%left LOGICAL_ADD LOGICAL_OR
%left LEQ GEQ LE GE EQ NEQ
%left ADDING SUBTRACTING
%left MULTIPLYING DIVISION MODULE 
%left LEFT_PAR RIGHT_PAR
%left IDENTIFIER


%nterm  statement add sub multi div mod statements quote assignment_stmt block_stmt while_stmt ifElse_stmt condition
%nterm greaterEqual greater smaller smallerEqual equal
%nterm loop_block for_stmt for_first_stmt
%nterm number_tuple function_arguments variable_declartion function_code_block
%nterm right_array_access_expr logical_op
%nterm loop_block_function number
%nterm function_declartion
%nterm condition_op arithmetic_op multiply_op term1 term2 factor operand 

%type <codeNode> statements statement 
%type <codeNode> expr arithmetic_expr
%type <codeNode>  arithmetic_op condition_op 
%type <codeNode> add sub multi div mod
%type <codeNode> identifier number
%type <codeNode> read_stmt print_stmt
%type <codeNode> assignment_stmt number_tuple
%type <codeNode> variable_declartion  single_variable_declartion
%type <codeNode> left_array_access_expr right_array_access_expr  array_access_stmt array_declartion_stmt
%type <codeNode> function_code_block functions function_declartion function_call_stmt
%type <codeNode>  function_arguments_declartion function_argument
%type <codeNode> control_flow_stmt_function loop_block_function loop_block
%type <codeNode>  multiply_op factor add_op logical_op term1 term2 term3 operand 

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
expr: 
    | number {ODEBUG("expr -> number ");$$=$1;}
    | identifier {ODEBUG("expr -> identifier -> "); $$=$1;}
    | arithmetic_expr {ODEBUG("expr -> arithmetic_expr");$$ = $1;}
    | array_access_stmt {ODEBUG("expr -> array_access_stmt");}
    | function_call_stmt {ODEBUG("expr -> function_call_stmt");}
    | %empty {ODEBUG("expr -> %%empty");
                CodeNode *node = new CodeNode(O_EXPR);
                $$ = node;
                }
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

arithmetic_expr : expr logical_op term1 {
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
                        
                        string tempVar = SymbolManager::getInstance().allocate_temp(SymbolType::SYM_VAR_INT);
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
                        string tempVar = SymbolManager::getInstance().allocate_temp(SymbolType::SYM_VAR_INT);
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
        | term2 {ODEBUG("term1 -> term2 ");$$ = $1;
                $$=$1;}
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
                        $$=addNode;
                        string tempVar = SymbolManager::getInstance().allocate_temp(SymbolType::SYM_VAR_INT);
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
                        addNode->printIR();
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
                        string tempVar = SymbolManager::getInstance().allocate_temp(SymbolType::SYM_VAR_INT);
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
factor: LEFT_PAR arithmetic_expr RIGHT_PAR  {ODEBUG("factor-> LEFT_PAR expr RIGHT_PAR ");$$=$2;}
        | NUMBER {ODEBUG("factor-> NUMBER");$$ = $1;}
        | BINARY_NUMBER {ODEBUG("factor-> BINARY_NUMBER");$$ = $1;}
        | HEX_NUMBER {ODEBUG("factor-> HEX_NUMBER");$$ = $1;}
        | IDENTIFIER {ODEBUG("factor-> IDENTIFIER");$$ = $1;}
        ;


number_tuple: number_tuple COMMA number {
                ODEBUG("number_tuple -> number_tuple COMMA number");
                $1->addChild($3);
                $$ = $1;
                }
                | number {
                ODEBUG("number_tuple -> number");
                CodeNode *node = new CodeNode(YYSYMBOL_number_tuple);
                node->addChild($1);
                $$ = node;
                }
                | %empty
multi_demension_number_tuple:  multi_demension_number_tuple COMMA  LEFT_CURLEY number_tuple RIGHT_CURLEY {ODEBUG("multi_demension_number_tuple -> multi_demension_number_tuple COMMA  LEFT_CURLEY number_tuple RIGHT_CURLEY");}
                          | LEFT_CURLEY number_tuple RIGHT_CURLEY {ODEBUG("multi_demension_number_tuple -> LEFT_CURLEY number_tuple RIGHT_CURLEY");}
                          ;
single_variable_declartion: INT identifier {ODEBUG("variable_declartion -> INT identifier");
           //it should be the first time to seen the identifier
           CodeNode *identifer = $2;
           auto ctx = SymbolManager::getInstance();
           Symbol* sym = ctx.find(identifer->sourceCode);
           if(sym!=nullptr){
                OWARN("redeclaration of variable %s",identifer->sourceCode);
                yyerror("redeclaration of variable ");
           }else{
                ctx.addSymbol(identifer->sourceCode, SymbolType::SYM_VAR_INT);
           }

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

                      auto ctx = SymbolManager::getInstance();
                      Symbol* sym = ctx.find(identifier->sourceCode);
                      if(sym!=nullptr)
                      {
                      OWARN("redeclaration of array variable %s",identifier->sourceCode);
                      yyerror("redeclaration of variable ");
                      }
                      else
                        {
                        ctx.addSymbol(identifier->sourceCode, SymbolType::SYM_VAR_INT_ARRAY);
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
                      auto& ctx = SymbolManager::getInstance();
                      auto tempVar = ctx.allocate_temp(SymbolType::SYM_VAR_INT);
                      ss << ". " << tempVar <<endl;
                      ss<<"=[] "<<tempVar << "," << identifier->sourceCode<<", "<<expr->sourceCode<<"\n";
                      newNode->val.str = new string(tempVar);
                      newNode->IRCode = ss.str();
                      newNode->printIR();
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
                    
assignment_stmt: INT IDENTIFIER ASSIGNMENT expr{
                ODEBUG("assignment_stmt -> INT IDENTIFIER ASSIGNMENT expr");
                CodeNode *identifierLeft = $2;
                //it should be the first time to seen the identifier
                auto ctx = SymbolManager::getInstance();
                Symbol* sym = ctx.find(identifierLeft->sourceCode);
                if(sym!=nullptr){
                        OWARN("redeclaration of variable %s",identifierLeft->sourceCode);
                        yyerror("redeclaration of variable ");
                }else{
                        ctx.addSymbol(identifierLeft->sourceCode, SymbolType::SYM_VAR_INT);
                }
                stringstream ss;
                ss << ". " << identifierLeft->sourceCode<<endl;
                ss << $4->IRCode;
                ss << "= " << identifierLeft->sourceCode << ", ";
                
                switch($4->type){
                        case IDENTIFIER:
                                ss << $4->sourceCode;
                                break;
                        case O_INT:
                                ss << $4->val.i;
                                break;
                        case O_EXPR:
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
                newNode->addChild($4);
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
          | left_array_access_expr ASSIGNMENT right_array_access_expr {
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
                        case YYSYMBOL_right_array_access_expr:
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
                CodeNode *functionIdentifier = $3;
                stringstream ss;
                ss << $3->IRCode;



                switch($3->type){
                        case YYSYMBOL_function_call_stmt:
                                ss << "call " << identifierLeft->sourceCode << ", ";
                                ss << functionIdentifier->children.front()->sourceCode;
                                break;
                        case IDENTIFIER:
                                ss << "= " << $3->sourceCode << ", ";
                                ss << identifierLeft->sourceCode;
                                break;
                        case O_INT:
                                ss << "= " << identifierLeft->sourceCode << ", ";
                                ss << $3->val.i;
                                break;
                        case O_EXPR:
                                ss << "= " << identifierLeft->sourceCode << ", ";
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
          | INT IDENTIFIER LEFT_BOX_BRAC number RIGHT_BOX_BRAC ASSIGNMENT LEFT_CURLEY number_tuple RIGHT_CURLEY {
                ODEBUG("assignment_stmt -> INT IDENTIFIER LEFT_BOX_BRAC number RIGHT_BOX_BRAC ASSIGNMENT LEFT_CURLEY number_tuple RIGHT_CURLEY");
                CodeNode *identifier = $2;
                CodeNode *numberNode = $4;
                CodeNode *numberTuple = $8;
                CodeNode *newNode = new CodeNode(YYSYMBOL_assignment_stmt);

                stringstream ss;
                //initialize the array
                ss << ".[] " << identifier->sourceCode << ", " << numberNode->sourceCode << "\n";

                //fill array w/ values
                for (int i = 0; i < numberTuple->children.size(); i++) {
                        ss << "[]= " << identifier->sourceCode << ", " << i << ", " << numberTuple->children[i]->sourceCode << "\n";
                }

                newNode->IRCode = ss.str();

                newNode->addChild(identifier);
                newNode->addChild(numberNode);
                newNode->addChild(numberTuple);

                newNode->printIR();
                $$ = newNode;
                }
          | INT IDENTIFIER LEFT_BOX_BRAC  RIGHT_BOX_BRAC ASSIGNMENT LEFT_CURLEY number_tuple RIGHT_CURLEY {
                ODEBUG("assignment_stmt-> INT IDENTIFIER LEFT_BOX_BRAC  RIGHT_BOX_BRAC ASSIGNMENT LEFT_CURLEY number_tuple RIGHT_CURLEY");
                CodeNode *identifier = $2;
                CodeNode *numberTuple = $7;
                CodeNode *newNode = new CodeNode(YYSYMBOL_assignment_stmt);

                stringstream ss;
                //initialize the array
                ss << ".[] " << identifier->sourceCode << ", " << numberTuple->children.size() << "\n";

                for (int i = 0; i < numberTuple->children.size(); i++) {
                        ss << "[]= " << identifier->sourceCode << ", " << i << ", " << numberTuple->children[i]->sourceCode << "\n";
                }

                newNode->IRCode = ss.str();

                newNode->addChild(identifier);
                newNode->addChild(numberTuple);

                newNode->printIR();
                $$ = newNode;
                }
          
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
                //querying if the function type is already defined
                auto ctx = SymbolManager::getInstance();
                vector<Symbol*> args;
                for(int i=0;i<arguments->children.size();i++){
                        args.push_back(new Symbol(arguments->children[i]->sourceCode, SymbolType::SYM_VAR_INT));
                }
                Symbol* sym = ctx.addFunction(identifer->sourceCode, args);
                if(sym==nullptr){
                        OWARN("redeclaration of function %s",identifer->sourceCode);
                        yyerror("redeclaration of function");
                }
               //processing arguments
                for(int i=0;i<arguments->children.size();i++){
                   ss<< ". "<< *(arguments->children[i]->val.str) << "," << "$" << i<<endl;
                }
                
                ss << codes->IRCode;
                ss << "endfunc"<<endl;
                func->IRCode = ss.str();
                func->printIR();
                func->addChild($2);
                func->addChild($4);
                func->addChild($7);
                $$=func;
                }
          ;

function_code_block: function_code_block  statement SEMICOLON {ODEBUG( "function_code_block -> function_code_block  statement SEMICOLON");
                $1->IRCode+=$2->IRCode;
                $1->addChild($2);
                $$=$1;
                 }
          | statement SEMICOLON {
                ODEBUG( "function_code_block -> statement SEMICOLON");
                CodeNode* node = new CodeNode(YYSYMBOL_function_code_block);
                node->IRCode+=$1->IRCode;
                node->addChild($1);
                $$=node;
               
          }
          | function_code_block control_flow_stmt_function {
                ODEBUG( "function_code_block -> function_code_block control_flow_stmt_function");
                $1->IRCode+=$2->IRCode;
                $1->addChild($2);
                }
          | function_code_block RETURN expr SEMICOLON {
                ODEBUG( "function_code_block -> function_code_block RETURN expr SEMICOLON");
                stringstream ss;
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
                  | right_array_access_expr { ODEBUG("function_argument -> array_access_expr");}
                  | function_call_stmt {ODEBUG("function_argument -> function_call_stmt");}
                  ;
function_arguments  : function_arguments COMMA function_argument {ODEBUG("function_arguments -> function_arguments COMMA function_argument");}
                  | function_argument {ODEBUG("function_arguments -> function_argument ");}
                  | %empty
                  ;

function_call_stmt : IDENTIFIER LEFT_PAR function_arguments RIGHT_PAR {ODEBUG("function_call_stmt -> IDENTIFIER LEFT_PAR function_arguments RIGHT_PAR");}
                  | IDENTIFIER LEFT_PAR RIGHT_PAR  {
                        ODEBUG("function_call_stmt -> IDENTIFIER LEFT_PAR RIGHT_PAR");
                        CodeNode *identifier = $1;
                        
                        CodeNode *newNode = new CodeNode(YYSYMBOL_function_call_stmt);

                        newNode->addChild(identifier);
                        newNode->printIR();
                        $$ = newNode;
                        }
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
        | PRINT LEFT_PAR identifier LEFT_BOX_BRAC number RIGHT_BOX_BRAC RIGHT_PAR {
          ODEBUG("print_stmt-> PRINT LEFT_PAR identifier RIGHT_PAR"); 

          CodeNode *numberNode = $5;

          CodeNode *node = new CodeNode(YYSYMBOL_print_stmt);
          stringstream ss;
          ss << ".[]> "<< $3->sourceCode << ", " << numberNode->sourceCode <<endl;
          node->IRCode = ss.str();
          $$ = node; 
        }
        ;

statements: statements  statement SEMICOLON  {
                        ODEBUG("statements -> statements  statement SEMICOLON");
                        $1->addChild($2);
                        $1->IRCode+=$2->IRCode;
                        $$=$1;}
          | statements control_flow_stmt {ODEBUG("statements -> statements control_flow_stmt");}
          | statement SEMICOLON {
                ODEBUG("statements -> statement SEMICOLON");
                CodeNode *node = new CodeNode(YYSYMBOL_statements);
                $$=node;
                }
          | statements function_declartion {
                ODEBUG("statements -> statements function_declartion");
                $1->addChild($2);
                $1->IRCode+=$2->IRCode;
                $$=$1;
                }
          | %empty{
                CodeNode *node = new CodeNode(YYSYMBOL_statements);
                $$=node;
          }
          ;

statement: expr {ODEBUG("statement -> expr");$$=$1;}
          | assignment_stmt {ODEBUG("statement -> assignment_stmt");
                CodeNode *node = new CodeNode(YYSYMBOL_statement);
                node->addChild($1);
                //node->addChild($2);
                node->IRCode = $1->IRCode;
                $$=node;
                }
          | variable_declartion {ODEBUG("statement -> variable_declartion");$$=$1;}
          | function_call_stmt {ODEBUG("statement -> function_call_stmt");}
          | array_access_stmt {ODEBUG("statement -> array_access_stmt");}
          | read_stmt          {ODEBUG("statement -> read_stmt");}
          | print_stmt         {ODEBUG("statement -> print_stmt");}
          | %empty      {ODEBUG("statement -> %empty");
                        CodeNode *node = new CodeNode(YYSYMBOL_statement);
                        $$=node;
                        }
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


