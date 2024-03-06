#include "symbol_table.hpp"
#include <iostream>
#include <cassert>
using namespace std;
int main(){
    auto manager = SymbolManager::getInstance();
    cout << manager->allocate_temp(SymbolType::SYM_VAR_INT)<<endl;
    auto m2 = SymbolManager::getInstance();
    assert(m2 == manager);
    
    auto* s0 = manager->find("_temp1","temp");
    assert(s0!=nullptr);
    auto *s1 = m2->find("_temp1","temp");
    assert(s1!=nullptr);
    manager->addFunction("f",*new std::vector<Symbol*>());
    for(int i = 0; i < 5; i++){
        if(i % 2 == 0){
            cout << "allocate label:"<< manager->allocate_label("a")<<endl;
        }else{
            cout << "allocate label:"<< manager->allocate_label("b")<<endl;
        }
        
    }
    m2->debugPrint();
    return 0;
}