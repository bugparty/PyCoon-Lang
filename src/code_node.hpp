#pragma once
#include <string>
#include <vector>
#include "tok.h"
struct CodeNode;
typedef struct CodeNode CodeNode;
struct CodeNode{
    std::string IRCode;
    std::string sourceCode;
    yytoken_kind_t type;
    std::vector<CodeNode*> sliblings;
    CodeNode(std::string& sourceCode):sourceCode(sourceCode){}
};
