#include "symbol_table.hpp"
#include <iostream>
#include <cassert>
using namespace std;
int main(){
    auto manager = SymbolManager::getInstance();
    cout << manager.allocate_temp(SymbolType::SYM_VAR_INT)<<endl;
    auto* s0 = manager.find("temp0");
    assert(s0!=nullptr);
    return 0;
}