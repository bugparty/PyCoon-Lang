#include "symbol_table.hpp"
#include <sstream>
#include <cassert>
std::mutex m; 

SymbolManager* SymbolManager::instance = nullptr;
std::mutex SymbolManager::mutex_;
std::string real_name(const std::string& name,const std::string& scope){
    std::stringstream ss;
    ss <<"__" << scope << "__" << name;
    return ss.str();
}
 Symbol* SymbolManager::find(const std::string&  name,const std::string& scope){
    std::lock_guard<std::mutex> lock(m);
    std::string realName = real_name(name,scope);
    auto it = symbols.find(realName);
    if (it!= symbols.end()){
        return it->second;
    }

    return nullptr;
 }
 Symbol* SymbolManager::addSymbol(const std::string&  name,const std::string& scope, 
                                  const enum SymbolType type){
    
    Symbol* old = this->find(name,scope);
    if(old!=nullptr) {
        std::cerr << "symbol " << name << " already exists in " << scope << std::endl;
        return nullptr;
    }
    std::lock_guard<std::mutex> lock(m);
    Symbol * sym = new Symbol(name,type);
    std::string realName = real_name(name,scope);
    symbols.insert(std::pair<std::string,Symbol*>(realName,sym));
    return sym;
 }
std::string SymbolManager::allocate_temp(enum SymbolType type){
    std::stringstream ss;
    ss << "_temp" << ++tempCounter;
    addSymbol(ss.str(),"temp", type);
    return ss.str();
}
std::string SymbolManager::allocate_label(std::string prefix){
    auto it = labelMap.find(prefix);
    if (it==labelMap.end()){
        labelMap[prefix]=0;
    }
    std::stringstream ss;
    ss << "_label_";
    if(prefix.length()>0){
        ss << prefix << "_";
    }
    ss << labelMap[prefix]++;
    return ss.str();
}
 SymbolManager* SymbolManager::getInstance(){
    std::lock_guard<std::mutex> lock(mutex_);
    if(instance == nullptr){
        instance = new SymbolManager();
        // std::cout << "create new symbol manager" << std::endl;
    }
    return instance;
}
Symbol* SymbolManager::addFunction(const std::string& name, const std::vector<Symbol*>& arguments){
    auto it = functions.find(name);
    Symbol* old;
    if (it!= functions.end()){
        old = it->second;
    }else{
        old = nullptr;
    }
    if(old!=nullptr) return nullptr;
    Symbol * sym = new Symbol(name,SymbolType::SYM_FUNCTION);
    sym->val.funVal = new std::vector<Symbol*>(arguments);
    assert( sym->val.funVal != nullptr);
    functions[name]=sym;
    return sym;
}
void SymbolManager::debugPrint(){
    std::cout << "Symbols:" << std::endl;
    for(auto it = symbols.begin(); it!=symbols.end();it++){
        std::cout << it->first << " : " << it->second->name << std::endl;
    }
    std::cout << "Labels:" << std::endl;
    for(auto it = labelMap.begin(); it!=labelMap.end();it++){
        std::cout << it->first << " : " << it->second << std::endl;
    }
    std::cout << "Functions:" << std::endl;
    for(auto it = functions.begin(); it!=functions.end();it++){
        std::cout << it->first << " : " << it->second->name << std::endl;
    }
}