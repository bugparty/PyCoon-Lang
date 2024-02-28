#pragma once
#include <string>
#include <vector>
#include <map>
#include <mutex> 
#include "tok.h"
#include "code_node.hpp"
enum class SymbolType {
    SYM_VAR_INT=2048,
    SYM_VAR_FLOAT,
    SYM_VAR_DOUFLE,
    SYM_VAR_INT_ARRAY,
    SYM_FUNCTION
};
struct Symbol{
    using enum SymbolType;
    std::string name;
    enum SymbolType type;
    int *arraySize;
    int arrayDimension;
    Symbol(std::string name,enum SymbolType type):name(name),type(type),arraySize(nullptr),
                                                 arrayDimension(0){}
    Symbol(enum SymbolType type):name(""),type(type),arraySize(nullptr),
                                                 arrayDimension(0){}
    Symbol(std::string name,enum SymbolType type, int arrayDimension, int *arraySize):name(name),type(type),arraySize(arraySize),
                                                 arrayDimension(arrayDimension){}
    union {
        int iVal;
        std::vector<Symbol*>* funVal;
    }val;
    static Symbol* createFromCodeNode(CodeNode* node){
        switch(node->type){
            case CodeNodeType::O_INT:
                return new Symbol(node->sourceCode,SYM_VAR_INT);
                break;
            case CodeNodeType::O_FLOAT:
                return new Symbol(node->sourceCode,SYM_VAR_FLOAT);
                break;
            case CodeNodeType::O_DOUBLE:
            case CodeNodeType::O_ARRAY_DECLARATION:
                CodeNode *identifier = node->children[0];
                CodeNode *numberNode = node->children[1];
                //currently only support one dimension array
                //TODO: support multi-dimension array
                return new Symbol(identifier->sourceCode,SYM_VAR_INT_ARRAY,new int(numberNode->val.i),1);
                break;
    
        }
    }
};
class SymbolManager{
    private:
    std::map<std::string,Symbol*> symbols;
    std::map<std::string,Symbol*> functions;
    int tempCounter;
    static std::mutex mutex_;
    static SymbolManager* instance;
    protected:
    SymbolManager():tempCounter(0){
    }
    public:
       /**
     * Singletons should not be cloneable.
     */
    SymbolManager(SymbolManager &other) = delete;
    /**
     * Singletons should not be assignable.
     */
    void operator=(const SymbolManager &) = delete;
    //find a existing symbol,if not exist,return null
    Symbol* find(const std::string& name,const std::string& scope);
     Symbol* addSymbol(const std::string&  name,const std::string& scope, const enum SymbolType type);
    Symbol* addFunction(const std::string& name, const std::vector<Symbol*>& arguments);
    //allocate a new temp variable
    std::string allocate_temp(enum SymbolType type);
    static SymbolManager* getInstance();
    void debugPrint();
};