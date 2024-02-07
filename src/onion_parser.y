%{
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>
#include <string>
#define YY_NO_UNPUT
#include "flex_externs.hpp"
#include "tok.h"

%}

%define parse.error verbose
%define parse.lac full

%union{
    int tokenVal;
    char *tokenStr; 
}

%token <int> NUMBER
%token IDENTIFIER 
%token VARTYPE
%token LEFT_PAR RIGHT_PAR
%left ADDING SUBTRACTING
%left MULTIPLYING DIVISION MODULE 

%nterm <int> statement add sub multi div mod

%start statements

%%

statements: statements statement {printf("%expression" ,$2);}
          | %empty
          ;

statement: add
         | sub
         | multi
         | div
         | mod
         | NUMBER
         ;
        
add:    LEFT_PAR statement ADDING statement RIGHT_PAR{$$ = $2 + $4;}

sub:    LEFT_PAR statement SUBTRACTING statement RIGHT_PAR{$$ = $2 - $4;}

multi:  LEFT_PAR statement MULTIPLYING statement RIGHT_PAR{$$ = $2 * $4;}

div: LEFT_PAR statement DIVISION statement RIGHT_PAR{$$ = $2 / $4;}

mod: LEFT_PAR statement MODULE statement RIGHT_PAR{$$ = $2 % $4;}


