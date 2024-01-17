/*

 */

%{
/* you can include anything here, will be insert to head */
#include <stdio.h>
#include <unistd.h>
#include <iostream>
#include <cstring>
using namespace std;
int white_spaces = 0;
//this variable tracks which line in current state
int current_line = 1;
int current_col = 1;
%}
/*define your symbols here*/
DIGIT          [0-9]
ID       [a-zA-z][a-zA-Z0-9_]*
WRONG_ID [0-9_]+[a-z][a-z0-9]*
ARITHMETIC [+\-*/]
COMPARISON [>|<|=][=]{0,1}
NOTEQUAL [!][=]
COMMENT #.*\n
MTLCOMMENT "/*"([^*]|\*+[^*/])*\*+"/"



%%
{DIGIT}+    {
    current_col += strlen(yytext);
    printf("IntergerNum: %s\n", yytext);
}
if|else|for|while|and|or|fun|print|break|read|continue    {
    current_col += strlen(yytext);
    printf( "Keyword: %s\n", yytext );
}
int|float|double    {
   current_col += strlen(yytext);
   printf( "number type: %s\n", yytext ); 

}
\+|-|\*|\/|% {
    current_col += strlen(yytext);
    printf("Arithmetic Op :%s\n",yytext);
}
>=|<=|>|<|==|!= {
    current_col += strlen(yytext);
    printf("Arithmetic Comparator :%s\n",yytext);
}
= {
    current_col += strlen(yytext);
    printf("Assignment: %s\n",yytext);
}
[ \t] {
    current_col += strlen(yytext);
    white_spaces++;
}
[\n] {
    ++current_line;
    current_col=1;
}
; {
    current_col += strlen(yytext);
    printf("Terminator\n");
}
{ID}{1} {
    printf("Identifier: %s\n", yytext);
}
{WRONG_ID} {
    printf("WrongIdentifier: %s at line %d column %d\n", yytext,current_line, current_col);
    current_col += strlen(yytext);
}
"(" {printf("LEFT PAREN\n");}
")" {printf("RIGHT PAREN\n");}
"{" {printf("LEFT CURLEY\n");}
"}" {printf("RIGHT CURLEY\n");}
"[" {printf("LEFT BOX BRAC\n");}
"]" {printf("RIGHT BOX BRAC\n");}

{COMMENT} {}

{MTLCOMMENT} {}

. {
    current_col += strlen(yytext);
    cerr<< "unexptected symbol found: " << yytext <<endl;
    return -1;
}
%%

int main(int argc,char** argv)
{

    ++argv, --argc;  /* skip over program name */
    if ( argc > 0 )
        yyin = fopen( argv[0], "r" );
    else
        yyin = stdin;

    yylex();
    return 0;
}
