%{
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>
#include <string>

extern int yylex();
extern FILE* yyin;

%}

%define api.value.type union
%define parse.error verbose
%define parse.lac full

%union{
    int tokenVal;
    char *tokenStr; 
}

$token <int> NUMBER
$token IDENTIFIER 
#token VARTYPE
#token LEFT_PAR RIGHT_PAR
#left ADDING SUBTRACTING
#left MULTIPLYING DIVISION MODULE 

