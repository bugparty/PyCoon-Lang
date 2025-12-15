/*
The Onion Lang lexizier
 */
%option yylineno
%option prefix="onion_"
%option noyywrap
%{
/* you can include anything here, will be insert to head */
#include <stdio.h>
#include <iostream>
#include <unistd.h>
#include <cstring>
#include <set>
#include <vector>
#include <queue>
#include "tok.h"
#include "code_node.hpp"
using namespace std;
#define ONION_PATTERN current_col += strlen(yytext) 
#define ONION_PATTERN_HANDLE_ERROR current_col += strlen(yytext); \
    if(in_error){ \
        printf("unexptected word found at line %d col %d: %s\n",error_begin_row, error_begin_col, error_lexeme.c_str());\
        exit(-1);\
    }
#define ENABLE_LEX_PRINTF 1  // Set this flag to 1 to enable printf, or 0 to disable it

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
set<string> keywords = {"if","else","for","while","and","or","fun","def","break","continue","int",
"elif","return","read","print"};
string error_lexeme;
bool in_error = false;
int error_begin_row;
int error_begin_col;
std::vector<int> indent_stack = {0};
std::queue<int> indent_tokens;
int yylex(void);
static int keyword_to_token(const char* s) {
    // 你仍然可以保留 keywords set 用于快速判断
    // 但真正返回 token 需要映射到 bison 的 token 值
    if (strcmp(s, "if") == 0) return IF;
    if (strcmp(s, "elif") == 0) return ELIF;
    if (strcmp(s, "else") == 0) return ELSE;
    if (strcmp(s, "for") == 0) return FOR;
    if (strcmp(s, "while") == 0) return WHILE;

    if (strcmp(s, "and") == 0) return LOGICAL_ADD;
    if (strcmp(s, "or") == 0) return LOGICAL_OR;

    if (strcmp(s, "fun") == 0 || strcmp(s, "def") == 0) return FUN;

    if (strcmp(s, "break") == 0) return BREAK;
    if (strcmp(s, "continue") == 0) return CONTINUE;

    if (strcmp(s, "int") == 0) return INT;
    if (strcmp(s, "return") == 0) return RETURN;
    if (strcmp(s, "read") == 0) return READ;
    if (strcmp(s, "print") == 0) return PRINT;

    return 0; // not a keyword
}

%}
/*define your symbols here*/
ID [a-zA-Z][a-zA-Z0-9]*
DIGIT          [0-9]
WRONG_ID [0-9_]+[a-zA-Z0-9]+
ARITHMETIC [+\-*/]
COMPARISON (>=|<=|>|<|==|!=)
COMMENT #.*\n
MTLCOMMENT "/*"([^*]|\*+[^*/])*\*+"/"
BINARY [0b]+[0-1]+
HEX  0[xX][0-9a-fA-F]+
END_OF_NUMBER [ \t\r\n\]\)\;\,\}\%\+\-\/\*\>\<\=\!]
WHITE_SPACE_OR_END [ \t;,\n]
NOT_WHITE_SPACE_OR_END [^ \t;\n]
WRONG_SYMBOL_CHAR [^ \t;\n\[\]]
LEFT_BOX_BRAC [\[]
RIGHT_BOX_BRAC [\]]
%%

{ID} {
    ONION_PATTERN;
    ODEBUG("protential ID : %s\n", yytext);
    int tok = 0;
    std::string yytext_str(yytext);
    if(keywords.find(yytext_str)!= keywords.end()){
        tok = keyword_to_token(yytext);
    }
    if (tok != 0) {
        ODEBUG("Keyword: %s\n", yytext);

        // 这里“要不要设置 yylval”取决于你 bison 里 token 是否声明了 <codeNode>
        // 你之前有的关键字 token 写了 <codeNode>，有的写 tokenStr，非常不一致
        // 我建议：关键字一律不需要 codeNode；但为了兼容你现状，给几个常用的也塞 node
        switch (tok) {
            case RETURN: case READ: case PRINT: case INT:
            case IF: case LOGICAL_ADD: case LOGICAL_OR:
                yylval.codeNode = new CodeNode(yytext, tok);
                break;
            case WHILE: case FOR:
                yylval.tokenStr = yytext;
                break;
            default:
                // 其他关键字如果你 yacc 没要求语义值，可以不赋
                ODEBUG("No yylval set for token %d\n", tok);
                yylval.codeNode = new CodeNode(yytext, tok);
                break;
        }
        return tok;
    }
    
    ODEBUG("Identifier: %s\n", yytext);
    yylval.codeNode = new CodeNode(yytext, IDENTIFIER);
    return IDENTIFIER;
    
}
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


{COMMENT} {ONION_PATTERN;ODEBUG("comment\n");++current_line;current_col=1;}

{MTLCOMMENT} {ONION_PATTERN;ODEBUG("comment\n");}
[ \t]+ {
    ONION_PATTERN;
    if (in_error) {
        fprintf(stderr, "LEX ERROR at line %d col %d: %s\n",
                error_begin_row, error_begin_col, error_lexeme.c_str());
        in_error = false;
        error_lexeme.clear();
    }
}
\n[ \t]* {
    current_line++;
    current_col = 1;
    int indent = 0;
    for(int i = 1; i < yyleng; ++i){
        indent += (yytext[i] == '\t') ? 4 : 1;
    }
    int next_char = yyinput();
    if(next_char != EOF) unput(next_char);
    if(next_char == '\n' || next_char == '#'){
        continue;
    }
    int current_indent = indent_stack.back();
    if(indent > current_indent){
        indent_stack.push_back(indent);
        indent_tokens.push(INDENT);
        return NEWLINE;
    }

    while(indent < current_indent){
        indent_stack.pop_back();
        current_indent = indent_stack.back();
        indent_tokens.push(DEDENT);
    }

    if(indent != current_indent){
        fprintf(stderr, "Indentation error at line %d\n", current_line);
        exit(-1);
    }

    if(!indent_tokens.empty()){
        int tok = indent_tokens.front();
        indent_tokens.pop();
        return tok;
    }

    return NEWLINE;
}
; {
    ONION_PATTERN;
    ODEBUG("Terminator\n");
    yylval.tokenStr = yytext;
    return SEMICOLON;
}
: {
    ONION_PATTERN;
    ODEBUG("Colon\n");
    yylval.tokenStr = yytext;
    return COLON;
}
. {
    ODEBUG("DEBUG: Unmatched char: '%c' (0x%02x) at %d:%d\n", 
            yytext[0], (unsigned char)yytext[0], current_line, current_col);
    if(!in_error){
        error_begin_col = current_col;
        error_begin_row = current_line;
        in_error = true;
    }
    ONION_PATTERN;
    
    error_lexeme += yytext;
}
%%

#undef yylex
int yylex(void){
    if(!indent_tokens.empty()){
        int tok = indent_tokens.front();
        indent_tokens.pop();
        return tok;
    }
    int token = onion_lex();
    if(token == 0 && indent_stack.size() > 1){
        indent_stack.pop_back();
        return DEDENT;
    }
    return token;
}
