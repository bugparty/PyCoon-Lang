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
using namespace std;
#define ONION_PATTERN current_col += strlen(yytext) 
#define ONION_PATTERN_HANDLE_ERROR current_col += strlen(yytext); \
    if(in_error){ \
        printf("unexptected word found at line %d col %d: %s\n",error_begin_row, error_begin_col, error_lexeme.c_str());\
        exit(-1);\
    }

int white_spaces = 0;
//this variable tracks which line in current state
int current_line = 1;
int current_col = 1;
set<string> keywords = {"if","else","for","while","and","or","fun","print","break","read","continue","int"}; 
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
END_OF_NUMBER [ \t\r\n\]\)\;\,\}\+\-\/\*]
WHITE_SPACE_OR_END [ \t;,\n]
NOT_WHITE_SPACE_OR_END [^ \t;\n]
WRONG_SYMBOL_CHAR [^ \t;\n\[\]]
LEFT_BOX_BRAC [\[]
RIGHT_BOX_BRAC [\]]

%%
{DIGIT}+/{END_OF_NUMBER}    {
    ONION_PATTERN;
    yylval.tokenVal = atoi(yytext);
    return NUMBER;
}
if|else|for|while|and|or|fun|print|break|read|continue    {
    ONION_PATTERN;
    printf( "Keyword: %s\n", yytext );
}
int  {
   ONION_PATTERN;
   yylval.tokenStr = yytext; 
   return INT;

}
{LEFT_BOX_BRAC} {ONION_PATTERN;printf("LEFT BOX BRAC\n");}
{RIGHT_BOX_BRAC} {ONION_PATTERN;printf("RIGHT BOX BRAC\n");}
"+" {
    ONION_PATTERN;
    yylval.tokenStr = yytext; 
    return ADDING;
}
"-" {
    yylval.tokenStr = yytext; 
    ONION_PATTERN;
    return SUBTRACTING;
}
"*" {
    yylval.tokenStr = yytext; 
    ONION_PATTERN;
    return MULTIPLYING;
}
"/" {
    ONION_PATTERN;
    printf("Arithmetic Op /:%s\n",yytext);
    return DIVISION;
}
"%" { 
    ONION_PATTERN;
    return MODULE;
}
{COMPARISON} {
    ONION_PATTERN;
}
= {
    ONION_PATTERN;
    return ASSIGNMENT;

}
{BINARY} {
    ONION_PATTERN;
}
{HEX} {
    ONION_PATTERN;
}
{ID}/{END_OF_ID} {
    ONION_PATTERN;
    if(keywords.find(yytext)!= keywords.end()){
        REJECT;
    }else{
        printf("Identifier: %s\n", yytext);
    }
    
}
{ID}/{COMPARISON} {
    ONION_PATTERN;
    printf("Identifier: %s\n", yytext);
}
{WRONG_ID} {
    ONION_PATTERN;
    printf("WrongIdentifier: %s at line %d column %d\n", yytext,current_line, current_col);
}
"(" {ONION_PATTERN;
    return LEFT_PAR;}
")" {ONION_PATTERN; return RIGHT_PAR;}
"{" {ONION_PATTERN;printf("LEFT CURLEY\n");}
"}" {ONION_PATTERN;printf("RIGHT CURLEY\n");}
"," {ONION_PATTERN;return COMMA;}


{COMMENT} {ONION_PATTERN;printf("comment\n");}

{MTLCOMMENT} {ONION_PATTERN;printf("comment\n");}
[ \t] {
    ONION_PATTERN_HANDLE_ERROR;
    white_spaces++;
    if(in_error){printf("unexptected word found at line %d col %d: %s\n",error_begin_row, error_begin_col, error_lexeme.c_str());exit(-1);}
}
[\n\r] {
    ONION_PATTERN_HANDLE_ERROR;
    ++current_line;
    current_col=1;
}
; {
    ONION_PATTERN;
    printf("Terminator\n");
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

