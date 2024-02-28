#include "states.hpp"
std::stack<std::string> functionStack;
std::stack<std::string> loopStack;
std::stack<CodeNode*> codeNodeStack;

std::string currentFunction(){
    return functionStack.top();
}
void pushFunction(std::string name){
    functionStack.push(name);
}
std::string  popFunction(){
    std::string name = functionStack.top();
    functionStack.pop();
    return name;
}
void push_code_node(CodeNode* node){
    codeNodeStack.push(node);
}
CodeNode* pop_code_node(){
    CodeNode* node = codeNodeStack.top();
    codeNodeStack.pop();
    return node;
}