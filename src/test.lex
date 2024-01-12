/*

 */

%{
/* you can include anything here, will be insert to head */
#include <stdio.h>
#include <unistd.h>
%}
/*define your symbols here*/
DIGIT          [0-9]
ID       [a-z][a-z0-9]*
ARITHMETIC [+\-*/]
/* COMPARISON [<|>|=(?!<|>)|(==)|(!=)|(>=)|(<=)|! ] */

%%
{DIGIT}+	{
    printf("IntergerNum: %s\n", yytext);
}
if|else|for|while|and|or|fun        {
printf( "Keyword: %s\n", yytext );
}
{ARITHMETIC}{1} {
printf("Arithmetic Op :%s\n",yytext);
}
>=|<= {
printf("Arithmetic Comparator :%s\n",yytext);
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
