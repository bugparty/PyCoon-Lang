#pragma once
#include <string>
#include <vector>
#include <iostream>
#include "tok.h"
struct CodeNode;
typedef struct CodeNode CodeNode;
/*
if target type is YYSYMBOL_arithmetic_op, store the temp variable name in val.str*/
struct CodeNode{
    std::string IRCode;
    std::string sourceCode;
    union OnionVal{
    int i;
    float f;
    double d;
    std::string* str;
    }val;
    int type;
    int subType;
    std::vector<CodeNode*> children;
    CodeNode(int type):type(type){}
    CodeNode(char* sourceCode,yytoken_kind_t type):sourceCode(std::string(sourceCode)),type(type){
        switch(type){
            case NUMBER:
                parseInt();
                break;
            default:
                break;
        }
    }
    void parseInt(){
         val.i = stoi(sourceCode);
    }
    void addChild(CodeNode* child){
        children.push_back(child);
    }
    void printIR(){
        std::cout<<"IRCode:"<<std::endl << IRCode <<"end of IRCode"<<std::endl;
    }
};
