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

%token program
%token function
%token arithmetic
%token <int> NUMBER
%token IDENTIFIER 
%token VARTYPE
%token FUN
%token INT
%token LEFT_PAR RIGHT_PAR
%token LEFT_BRAC RIGHT_BRAC
%left ADDING SUBTRACTING
%left MULTIPLYING DIVISION MODULE 

%nterm <int> statement add sub multi div mod

%start program

%%

program: %empty
       | program function 
       ;

function : FUN LEFT_PAR INT IDENTIFIER RIGHT_PAR LEFT_BRAC statements RIGHT_BRAC



statements: statements statement {printf("%expression" ,$2);}
          | arithmetic
          | %empty
          ;

statement: arithmetic
         ;


arithmetic: add
          | sub
          | multi
          | div
          | mod
          | NUMBER
          ;
        
add:    LEFT_PAR arithmetic ADDING arithmetic RIGHT_PAR{$$ = $2 + $4;}

sub:    LEFT_PAR arithmetic SUBTRACTING arithmetic RIGHT_PAR{$$ = $2 - $4;}

multi:  LEFT_PAR arithmetic MULTIPLYING arithmetic RIGHT_PAR{$$ = $2 * $4;}

div: LEFT_PAR arithmetic DIVISION arithmetic RIGHT_PAR{$$ = $2 / $4;}

mod: LEFT_PAR arithmetic MODULE arithmetic RIGHT_PAR{$$ = $2 % $4;}