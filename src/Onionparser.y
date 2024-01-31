%{
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>
#include <string>

extern int yylex();
extern FILE* yyin;

%}

%define api.value.type union-directive
%union{
    int tokenVal;
    string tokenStr; 
}

