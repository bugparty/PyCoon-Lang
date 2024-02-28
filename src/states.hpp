#include <stack>
#include <string>
#pragma once
extern std::stack<std::string> functionStack;
extern std::stack<std::string> loopStack;
struct CodeNode;
std::string currentFunction();
void pushFunction(std::string name);
std::string popFunction();

void push_code_node(CodeNode* node);
CodeNode* pop_code_node();

