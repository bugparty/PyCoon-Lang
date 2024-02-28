#include "symbol_table.hpp"
#include <iostream>
#include <cassert>
using namespace std;
int main(){
    auto manager = SymbolManager::getInstance();
    cout << manager->allocate_temp(SymbolType::SYM_VAR_INT)<<endl;
    auto m2 = SymbolManager::getInstance();
    assert(m2 == manager);
    auto* s0 = manager->find("_temp0");
    assert(s0!=nullptr);
    auto *s1 = m2->find("_temp0");
    assert(s1!=nullptr);
    manager->addFunction("f",*new std::vector<Symbol*>());
    return 0;
}