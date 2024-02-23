#include "symbol_table.hpp"
#include <sstream>

SymbolManager SymbolManager::instance;
 Symbol* SymbolManager::find(const std::string&  name){
    auto it = symbols.find(name);
    if (it!= symbols.end()){
        return it->second;
    }
    return nullptr;
 }
 Symbol* SymbolManager::addSymbol(const std::string&  name, enum SymbolType type){
    Symbol* old = this->find(name);
    if(old!=nullptr) return nullptr;
    Symbol * sym = new Symbol(name,type);
    symbols[name]=sym;
    return sym;
 }
std::string SymbolManager::allocate_temp(enum SymbolType type){
    std::stringstream ss;
    ss << "temp" << tempCounter++;
    addSymbol(ss.str(), type);
    return ss.str();
}
 SymbolManager& SymbolManager::getInstance(){
    return instance;
}