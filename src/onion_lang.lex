/*
The Onion Lang lexizier
 */

%{
/* you can include anything here, will be insert to head */
#include <stdio.h>
#include <iostream>
#include <unistd.h>
#include <cstring>
#include <set>
using namespace std;
int white_spaces = 0;
//this variable tracks which line in current state
int current_line = 1;
int current_col = 1;
set<string> keywords={"or","and"};
#define ONION_PATTERN current_col += strlen(yytext)
%}
/*define your symbols here*/
DIGIT          [0-9]
ID       [a-zA-Z][a-zA-Z0-9_]*
WRONG_ID [0-9_]+[a-zA-Z0-9]+
ARITHMETIC [+\-*/]
COMPARISON (>=|<=|>|<|==|!=)
COMMENT #.*\n
MTLCOMMENT "/*"([^*]|\*+[^*/])*\*+"/"
BINARY [0b]+[0-1]+
HEX [0x]+[0-9a-eA-E]*
VARIABLE [a-zA-Z][a-zA-Z0-9_]*
END_OF_VARIABLE  [ \t\r\n;\[\]=\+\-\*\/\)]
END_OF_NUMBER [ \t\r\n\]\)]
WHITE_SPACE_OR_END [ \t;,\n]
NOT_WHITE_SPACE_OR_END [^ \t;\n]
WRONG_SYMBOL_CHAR [^ \t;\n\[\]]
LEFT_BOX_BRAC [\[]
RIGHT_BOX_BRAC [\]]

%%
{DIGIT}+/{END_OF_NUMBER}    {
    ONION_PATTERN;
    printf("IntergerNum: %s\n", yytext);
}
if|else|for|while|and|or|fun|print|break|read|continue    {
    ONION_PATTERN;
    printf( "Keyword: %s\n", yytext );
}
int|float|double    {
   ONION_PATTERN;
   printf( "number type: %s\n", yytext ); 

}
{LEFT_BOX_BRAC} {ONION_PATTERN;printf("LEFT BOX BRAC\n");}
{RIGHT_BOX_BRAC} {ONION_PATTERN;printf("RIGHT BOX BRAC\n");}
\+|-|\*|\/|% {
    ONION_PATTERN;
    printf("Arithmetic Op :%s\n",yytext);
}
{COMPARISON} {
    ONION_PATTERN;
    printf("Arithmetic Comparator :%s\n",yytext);
}
= {
    ONION_PATTERN;
    printf("Assignment: %s\n",yytext);
}
[ \t] {
    ONION_PATTERN;
    white_spaces++;
}
[\n] {
    ++current_line;
    current_col=1;
}
; {
    ONION_PATTERN;
    printf("Terminator\n");
}
{BINARY} {
    ONION_PATTERN;
    printf("BINARY: %s\n", yytext);
}
{HEX} {
    ONION_PATTERN;
    printf("HEX: %s\n", yytext);
}
{VARIABLE}/{END_OF_VARIABLE} {
    ONION_PATTERN;
    if(keywords.find(yytext)!= keywords.end()){
        REJECT;
    }else{
        printf("Variable: %s\n", yytext);
    }
    
}
{VARIABLE}/{COMPARISON} {
    ONION_PATTERN;
    printf("Variable: %s\n", yytext);
}
{WRONG_ID} {
    ONION_PATTERN;
    printf("WrongIdentifier: %s at line %d column %d\n", yytext,current_line, current_col);
}
"(" {ONION_PATTERN;
    printf("LEFT PAREN\n");}
")" {ONION_PATTERN;printf("RIGHT PAREN\n");}
"{" {ONION_PATTERN;printf("LEFT CURLEY\n");}
"}" {ONION_PATTERN;printf("RIGHT CURLEY\n");}


{COMMENT} {ONION_PATTERN;printf("comment\n");}

{MTLCOMMENT} {ONION_PATTERN;printf("comment\n");}


. {
    ONION_PATTERN;
    printf("unexptected char found at line %d col %d: %s\n",current_line, current_col, yytext);
    exit(-1);
}
%%

