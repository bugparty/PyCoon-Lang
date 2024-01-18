/*
The Onion Lang lexizier
 */

%{
/* you can include anything here, will be insert to head */
#include <stdio.h>
#include <iostream>
#include <unistd.h>
#include <cstring>
using namespace std;
int white_spaces = 0;
//this variable tracks which line in current state
int current_line = 1;
int current_col = 1;
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
BINARY [0b]+[0-1]*
HEX [0x]+[0-9a-eA-E]*



%%
{DIGIT}+    {
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
{ID} {
    ONION_PATTERN;
    printf("Identifier: %s\n", yytext);
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
"[" {ONION_PATTERN;printf("LEFT BOX BRAC\n");}
"]" {ONION_PATTERN;printf("RIGHT BOX BRAC\n");}

{COMMENT} {ONION_PATTERN;}

{MTLCOMMENT} {ONION_PATTERN;}

. {
    ONION_PATTERN;
    printf("unexptected symbol found at line %d col %d: %s\n",current_line, current_col, yytext);
    return -1;
}
%%

