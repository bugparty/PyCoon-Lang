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
    CodeNode(int type):type(type),subType(0){}
    CodeNode(const CodeNode& right){
        this->IRCode = right.IRCode;
        this->sourceCode = right.sourceCode;
        this->val = right.val;
        this->type = right.type;
        this->subType = right.subType;
        this->children = right.children;
        //std::cout << "copy constructor"<<std::endl;
    }
    CodeNode(char* sourceCode,yytoken_kind_t type):sourceCode(std::string(sourceCode)),type(type){
        std::string s = std::string(sourceCode);
        switch(type){
            case NUMBER:
                val.i = std::stoi(sourceCode);
                break;
            case BINARY_NUMBER:
                
                val.i = stoul(s.substr(2),0,2);
                break;
            case HEX_NUMBER:
                val.i = stoul(s.substr(2),0,16);
                break;
            default:
                break;
        }
    }
    void addChild(CodeNode* child){
        children.push_back(child);
    }
    void debug(){
        std::cout << "type:" << type <<" subtype: " << subType;
        std::cout << "children size:" << children.size() <<std::endl;
        for(int i=0;i<children.size();i++){
            std::cout << i << "th child, address: " << children[i] <<std::endl;
        }
        printIR();
    }
    void printIR(){
        std::cout<<"IRCode:"<<std::endl << IRCode <<"end of IRCode"<<std::endl;
    }
};
