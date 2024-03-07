#include <stack>
#include <string>
#pragma once
struct CodeNode;
std::string currentFunction();
void pushFunction(const std::string& name);
std::string popFunction();
CodeNode* currentLoopTag();
void pushLoopTag(CodeNode* node);
CodeNode* popLoopTag();

void push_code_node(CodeNode* node);
CodeNode* pop_code_node();

