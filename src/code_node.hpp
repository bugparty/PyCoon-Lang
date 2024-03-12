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
    O_FLOAT=4097,
    O_DOUBLE=4098,
    O_IDENTIFIER=4099,
    O_NUMBER=4100,
    O_EXPR=4101,
    O_ARRAY_EXPR=4102,
    O_VAR_DECLARATION=4103,
    O_ARRAY_DECLARATION=4104,
    O_FUNC_DECLARATION=4105,
    O_FUNC_ARGS,
    O_FUNC_CALL,
    O_IF_ELSE_STMT,//this is the ifElse_stmt_function
    O_IF_STMT, // this is if_stmt_function
    O_ELSE_STMT,
    O_ELIF_STMT,
    O_FUNC_RETURN,
    O_WHILE_STMT,
    O_CODE_BLOCK,
    O_FOR_STMT,
    O_CONTAINER,
    O_RIGHT_EXPR,
    O_LEFT_EXPR,
    O_ASSIGN_STMT,
};
struct LoopTag_{
    int loopNo;
    std::string loopStartLabel;
    std::string loopBodyLabel;
    std::string loopEndLabel;
    LoopTag_(int loopNo,std::string loopStartLabel,std::string loopBodyLabel,std::string loopEndLabel):
        loopNo(loopNo),loopStartLabel(loopStartLabel),loopBodyLabel(loopBodyLabel),loopEndLabel(loopEndLabel){}
    };
typedef struct LoopTag_ LoopTag;
/*
if target type is O_EXPR, store the temp variable name in val.str*/
struct CodeNode{
    std::string IRCode;
    std::string sourceCode;
    std::string IRVars;
    std::string IRLogics;
    int lineno;
    union OnionVal{
    int i;
    float f;
    double d;
    std::string* str;
    LoopTag* loopTag;
    }val;
    int type;
    int subType;
    std::vector<CodeNode*> children;
    CodeNode(int type):type(type),subType(0){}
    CodeNode(const CodeNode& right);
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
    virtual ~CodeNode();
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
    bool genFunctionCallIRCode(std::stringstream &ss);
    void addChild(CodeNode* child){
        children.push_back(child);
    }
    bool isImmediateValue(){
        return type == O_INT || type == O_FLOAT || type == O_DOUBLE;
    }
    void debug(bool recursive = false);
    void printIR();
    private:
       void freeUnionVal();
};
