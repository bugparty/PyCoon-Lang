#pragma once
#include <string>
#include <vector>
#include "tok.h"
struct CodeNode;
typedef struct CodeNode CodeNode;
union OnionVal{
    int i;
    float f;
    double d;
    std::string* str;
};
struct CodeNode{
    std::string IRCode;
    std::string sourceCode;
    OnionVal val;
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
};
