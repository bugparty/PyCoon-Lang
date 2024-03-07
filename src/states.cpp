#include "states.hpp"
std::stack<std::string> functionStack;
std::stack<CodeNode*> loopStack;
std::stack<CodeNode*> codeNodeStack;

std::string currentFunction(){
    if(functionStack.empty()){
        return "";
    }else{
        return functionStack.top();
    }
}
void pushFunction(const std::string& name){
    functionStack.push(name);
}
std::string  popFunction(){
    if(functionStack.empty()){
        return "";
    }else{
        std::string name = functionStack.top();
        functionStack.pop();
        return name;
    }
    
}
void push_code_node(CodeNode* node){
    codeNodeStack.push(node);
}
CodeNode* pop_code_node(){
    if(codeNodeStack.empty()){
        return nullptr;
    }else{
        CodeNode* node = codeNodeStack.top();
        codeNodeStack.pop();
        return node;
    }
}
CodeNode* currentLoopTag(){
    if(loopStack.empty()){
        return nullptr;
    }else{
        return loopStack.top();
    }
}
void pushLoopTag(CodeNode* name){
    loopStack.push(name);
}
CodeNode* popLoopTag(){
    if(loopStack.empty()){
        return nullptr;
    }else{
        auto  node = loopStack.top();
        loopStack.pop();
        return node;
    }
}