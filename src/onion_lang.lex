/*
The Onion Lang lexizier
 */
%option yylineno
%{
/* you can include anything here, will be insert to head */
#include <stdio.h>
#include <iostream>
#include <unistd.h>
#include <cstring>
#include <set>
#include "tok.h"
#include "code_node.hpp"
using namespace std;
#define ONION_PATTERN current_col += strlen(yytext) 
#define ONION_PATTERN_HANDLE_ERROR current_col += strlen(yytext); \
    if(in_error){ \
        printf("unexptected word found at line %d col %d: %s\n",error_begin_row, error_begin_col, error_lexeme.c_str());\
        exit(-1);\
    }
#define ENABLE_LEX_PRINTF 0  // Set this flag to 1 to enable printf, or 0 to disable it

#if ENABLE_LEX_PRINTF
    #define ODEBUG( ...) \
    do{printf("YYLEX: ");printf( __VA_ARGS__);}while(0)
#else
    #define ODEBUG( ...)
#endif

int white_spaces = 0;
//this variable tracks which line in current state
int current_line = 1;
int current_col = 1;
set<string> keywords = {"if","else","for","while","and","or","fun","break","continue","int",
"elif","return","read","print"};
string error_lexeme;
bool in_error = false;
int error_begin_row;
int error_begin_col;
%}
/*define your symbols here*/
DIGIT          [0-9]
WRONG_ID [0-9_]+[a-zA-Z0-9]+
ARITHMETIC [+\-*/]
COMPARISON (>=|<=|>|<|==|!=)
COMMENT #.*\n
MTLCOMMENT "/*"([^*]|\*+[^*/])*\*+"/"
BINARY [0b]+[0-1]+
HEX [0x]+[0-9a-eA-E]*
ID [a-zA-Z][a-zA-Z0-9_]*
END_OF_ID  [ \t\r\n;\[\]=\+\-\*\%\/\)\(\,]
END_OF_NUMBER [ \t\r\n\]\)\;\,\}\%\+\-\/\*\>\<\=\!]
WHITE_SPACE_OR_END [ \t;,\n]
NOT_WHITE_SPACE_OR_END [^ \t;\n]
WRONG_SYMBOL_CHAR [^ \t;\n\[\]]
LEFT_BOX_BRAC [\[]
RIGHT_BOX_BRAC [\]]

%%
{DIGIT}+/{END_OF_NUMBER}    {
    ONION_PATTERN;
    CodeNode* node = new CodeNode(yytext, CodeNodeType::O_INT);
    ODEBUG("NUMBER:%d\n", node->val.i);
    yylval.codeNode = node;
    return NUMBER;
}
{BINARY} {
    ONION_PATTERN;
    CodeNode* node = new CodeNode(yytext, BINARY_NUMBER);
    yylval.codeNode = node;
    ODEBUG("BINARY_NUMBER:%d\n", node->val.i);
    return BINARY_NUMBER;
}
{HEX} {
    ONION_PATTERN;
    CodeNode* node = new CodeNode(yytext, HEX_NUMBER);
    yylval.codeNode = node;
    ODEBUG("HEX_NUMBER:%d\n", node->val.i);
    return HEX_NUMBER;
}
return {
    ONION_PATTERN;
    ODEBUG( "Keyword: %s\n", yytext);
    CodeNode* node = new CodeNode(yytext, RETURN);
    yylval.codeNode = node;
    return RETURN;
}
read {
    ONION_PATTERN;
    ODEBUG( "Keyword: %s\n", yytext);
    CodeNode* node = new CodeNode(yytext, READ);
    yylval.codeNode = node;
    return READ;
}
print {
    ONION_PATTERN;
    ODEBUG( "Keyword: %s\n", yytext);
    CodeNode* node = new CodeNode(yytext, PRINT);
    yylval.codeNode = node;
    return PRINT;
}
fun {
    ONION_PATTERN;
    ODEBUG( "Keyword: %s\n", yytext);
    return FUN;
}
break {
    ONION_PATTERN;
    ODEBUG( "Keyword: %s\n", yytext);
    return BREAK;
}
continue {
    ONION_PATTERN;
    ODEBUG( "Keyword: %s\n", yytext);
    return CONTINUE;
}

and {
    ONION_PATTERN;
    ODEBUG( "Keyword: %s\n", yytext);
    return LOGICAL_ADD;
}
or {
    ONION_PATTERN;
    ODEBUG( "Keyword: %s\n", yytext);
    return LOGICAL_OR;
}
if {
    ONION_PATTERN;
    ODEBUG( "Keyword: %s\n", yytext);
    return IF;
}
elif {
    ONION_PATTERN;
    ODEBUG( "Keyword: %s\n", yytext);
    return ELIF;
}
else {
    ONION_PATTERN;
    ODEBUG( "Keyword: %s\n", yytext);
    return ELSE;
}

while {
    ONION_PATTERN;
    ODEBUG( "Keyword: %s\n", yytext);
    yylval.tokenStr = yytext;
    return WHILE;
}
for {
    ONION_PATTERN;
    ODEBUG( "Keyword: %s\n", yytext);
    yylval.tokenStr = yytext;
    return FOR;
}

int  {
   ONION_PATTERN;
   ODEBUG("INT TYPE\n");
   CodeNode* node = new CodeNode(yytext, INT);
   yylval.codeNode = node;
   return INT;

}
{LEFT_BOX_BRAC} {
    ONION_PATTERN;
    ODEBUG("LEFT BOX BRAC\n");
    yylval.tokenStr = yytext;
    return LEFT_BOX_BRAC;}
{RIGHT_BOX_BRAC} {
    ONION_PATTERN;
    ODEBUG("RIGHT BOX BRAC\n");
    yylval.tokenStr = yytext;
    return RIGHT_BOX_BRAC;}
"+" {
    ONION_PATTERN;
    ODEBUG("Arithmetic Op +:%s\n",yytext);
    CodeNode* node = new CodeNode(yytext, ADDING);
    yylval.codeNode = node;
    return ADDING;
}
"-" {
    ONION_PATTERN;
    ODEBUG("Arithmetic Op +:%s\n",yytext);
    CodeNode* node = new CodeNode(yytext, SUBTRACTING);
    yylval.codeNode = node;
    return SUBTRACTING;
}
"*" {
    
    ONION_PATTERN;
    ODEBUG("Arithmetic Op :%s\n",yytext);
    CodeNode* node = new CodeNode(yytext, MULTIPLYING);
    yylval.codeNode = node;
    return MULTIPLYING;
}
"/" {
    ONION_PATTERN;
    ODEBUG("Arithmetic Op :%s\n",yytext);
    CodeNode* node = new CodeNode(yytext, DIVISION);
    yylval.codeNode = node;
    return DIVISION;
}
"%" { 
    ONION_PATTERN;
    ODEBUG("Arithmetic Op :%s\n",yytext);
    CodeNode* node = new CodeNode(yytext, MODULE);
    yylval.codeNode = node;
    return MODULE;
}
"<=" { 
    ONION_PATTERN;
    ODEBUG("COMPARISON Op :%s\n",yytext);
    CodeNode* node = new CodeNode(yytext, LEQ);
    yylval.codeNode = node;
    return LEQ;
}
">=" { 
    ONION_PATTERN;
    ODEBUG("COMPARISON Op :%s\n",yytext);
    CodeNode* node = new CodeNode(yytext, GEQ);
    yylval.codeNode = node;
    return GEQ;
}

">" { 
    ONION_PATTERN;
    ODEBUG("COMPARISON Op :%s\n",yytext);
    CodeNode* node = new CodeNode(yytext, GE);
    yylval.codeNode = node;
    return GE;
}
"<" { 
    ONION_PATTERN;
    ODEBUG("COMPARISON Op :%s\n",yytext);
    CodeNode* node = new CodeNode(yytext, LE);
    yylval.codeNode = node;
    return LE;
}
"==" {
    ONION_PATTERN;
    ODEBUG("COMPARISON Op :%s\n",yytext);
    CodeNode* node = new CodeNode(yytext, EQ);
    yylval.codeNode = node;
    return EQ;
}
"!=" {
    ONION_PATTERN;
    ODEBUG("COMPARISON Op :%s\n",yytext);
    CodeNode* node = new CodeNode(yytext, NEQ);
    yylval.codeNode = node;
    return NEQ;
}
= {
    ONION_PATTERN;
    CodeNode* node = new CodeNode(yytext, ASSIGNMENT);
    yylval.codeNode = node;
    return ASSIGNMENT;

}

{ID}/{END_OF_ID} {
    ONION_PATTERN;
    if(keywords.find(yytext)!= keywords.end()){
        REJECT;
    }else{
        ODEBUG("Identifier: %s\n", yytext);
        
        CodeNode* node = new CodeNode(yytext, IDENTIFIER);
        yylval.codeNode = node;
        return IDENTIFIER;
    }
    
}
{ID}/{COMPARISON} {
    ONION_PATTERN;
    ODEBUG("Identifier: %s\n", yytext);
    CodeNode* node = new CodeNode(yytext, IDENTIFIER);
    yylval.codeNode = node;
    return IDENTIFIER;
}
{WRONG_ID} {
    ONION_PATTERN;
    ODEBUG("WrongIdentifier: %s at line %d column %d\n", yytext,current_line, current_col);
}
"(" {ONION_PATTERN;
    yylval.tokenStr = yytext;
    return LEFT_PAR;}
")" {ONION_PATTERN;
    yylval.tokenStr = yytext;
    return RIGHT_PAR;}
"{" {ONION_PATTERN;ODEBUG("LEFT CURLEY\n");
    yylval.tokenStr = yytext;
    return LEFT_CURLEY;}
"}" {ONION_PATTERN;ODEBUG("RIGHT CURLEY\n");
    yylval.tokenStr = yytext;
    return RIGHT_CURLEY;}
"," {ONION_PATTERN;
    yylval.tokenStr = yytext;
    return COMMA;}


{COMMENT} {ONION_PATTERN;ODEBUG("comment\n");}

{MTLCOMMENT} {ONION_PATTERN;ODEBUG("comment\n");}
[ \t] {
    ONION_PATTERN_HANDLE_ERROR;
    white_spaces++;
    if(in_error){ODEBUG("unexptected word found at line %d col %d: %s\n",error_begin_row, error_begin_col, error_lexeme.c_str());exit(-1);}
}
[\n\r] {
    ONION_PATTERN_HANDLE_ERROR;
    ++current_line;
    current_col=1;
}
; {
    ONION_PATTERN;
    ODEBUG("Terminator\n");
    yylval.tokenStr = yytext;
    return SEMICOLON;
}

. {
    if(!in_error){
        error_begin_col = current_col;
        error_begin_row = current_line;
        in_error = true;
    }
    ONION_PATTERN;
    
    error_lexeme += yytext;
}
%%

