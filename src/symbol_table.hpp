#pragma once
#include <string>
#include <vector>
#include <map>
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
    Symbol(std::string name,enum SymbolType type):name(name),type(type){}
    union {
        int iVal;
        std::vector<Symbol*>* funVal;
    }val;
};
class SymbolManager{
    std::map<std::string,Symbol*> symbols;
    static SymbolManager instance;
    int tempCounter;
    protected:
    SymbolManager():tempCounter(0){

    }
    public:
    //find a existing symbol,if not exist,return null
    Symbol* find(const std::string& name);
     Symbol* addSymbol(const std::string&  name, enum SymbolType type);
    Symbol* addFunction(const std::string& name, std::vector<Symbol*> arguments);
    //allocate a new temp variable
    std::string allocate_temp(enum SymbolType type);
    static SymbolManager& getInstance();
};