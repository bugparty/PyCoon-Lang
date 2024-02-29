#pragma once
#include <string>
#include <vector>
#include <iostream>
#include <sstream>
#include "tok.h"

struct CodeNode;
typedef struct CodeNode CodeNode;
enum CodeNodeType{
    O_INT=4096,
    O_FLOAT,
    O_DOUBLE,
    O_IDENTIFIER,
    O_NUMBER,
    O_EXPR,
    O_ARRAY_EXPR,
    O_VAR_DECLARATION,
    O_ARRAY_DECLARATION,
    O_FUNC_DECLARATION,
    O_FUNC_ARGS,
    O_FUNC_CALL,
};
/*
if target type is O_EXPR, store the temp variable name in val.str*/
struct CodeNode{
    std::string IRCode;
    std::string sourceCode;
    int lineno;
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
    CodeNode(char* sourceCode,int type):sourceCode(std::string(sourceCode)),type(type){
        std::string s = std::string(sourceCode);
        switch(type){
            case O_INT:
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
    /*get the immediate value or variable name
    return false if the type is not immediate value or variable name
    output the immediate value or variable name to ss
    output sample:
    sample1:
    123
    sample2:
    a
    */
    bool getImmOrVariableIRCode(std::stringstream& ss);
    std::string getImmOrVariableIRCode();
    bool genFunctionCallIRCodeImpl(std::stringstream &ss, std::vector<std::string> &args);
    bool genFunctionCallIRCode(std::stringstream &ss, std::string &funName);
    void addChild(CodeNode* child){
        children.push_back(child);
    }
    void debug(bool recursive = false){
        std::cout << "sourceCode: " << sourceCode << std::endl;
        std::stringstream ss;
        getImmOrVariableIRCode(ss);
        std::cout << "val: " << ss.str() << std::endl;
        std::cout << "type:" << type <<" subtype: " << subType;
        std::cout << " children size:" << children.size() <<std::endl;
        for(size_t i=0;i<children.size();i++){
            std::cout << i << "th child, address: " << children[i] << " type:" << children[i]->type <<
            " children size: "<<children[i]->children.size()<< std::endl;
            if(recursive){
                children[i]->debug();
            }
            
        }
        printIR();
    }
    void printIR(){
        std::cout<<"IRCode:"<<std::endl << IRCode <<"end of IRCode"<<std::endl;
    }
};
