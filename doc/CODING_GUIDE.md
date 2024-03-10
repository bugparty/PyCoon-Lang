# how to avoid memory leaks.

## you should always add all the CodeNode symbols and terminals to the current node.

`if_stmt_function: IF LEFT_PAR expr RIGHT_PAR LEFT_CURLEY loop_block_function RIGHT_CURLEY {
        ODEBUG("if_stmt_function -> IF LEFT_PAR expr RIGHT_PAR LEFT_CURLEY loop_block_function RIGHT_CURLEY");
        CodeNode *node = new CodeNode(O_IF_STMT);
        CodeNode *expr = $3;
        CodeNode *loop_block = $6;
        stringstream ss;
        ss << expr->IRCode;
        auto tempCond = SymbolManager::getInstance()->allocate_temp(SymbolType::SYM_VAR_INT);
        ss << ". " << tempCond <<endl;
        ss << "> " << tempCond << " , " << expr->getImmOrVariableIRCode() << ", 0" << endl;
        
        auto label_if_true = SymbolManager::getInstance()->allocate_label("if_true");
        auto label_if_false = SymbolManager::getInstance()->allocate_label("if_false");
        auto label_if_true_next = SymbolManager::getInstance()->allocate_label("if_true_next");
        ss << "?:= " << label_if_true << ", " << tempCond << endl;
        ss << ":= " << label_if_false << endl;
        ss << ": " << label_if_true << endl;
        ss << loop_block->IRCode;
        ss << ":= " << label_if_true_next << endl;
        ss << ": " << label_if_false << endl;
        node->IRCode = ss.str();
        node->val.str = new string(label_if_true_next);
        $$=node;    
        node->addChild($1);
        node->addChild(expr);
        node->addChild(loop_block);
        }
        ;
    `

    ## when you override CodeNode->val.str, delete the old value first

    `
    elif_stmt_function {ODEBUG("multi_elif_stmt_function -> else_stmt_function");
                                CodeNode *elif = $1;
                                stringstream ss;
                                ss << ": " << *(elif->val.str) << endl;
                                delete elif->val.str;
                                elif->val.str = new string(ss.str());
                                $$=elif;}
                        ;
    `

    ## if a node type is using val.str, you need to add the type to code_node.hpp in there

    `
     void CodeNode::freeUnionVal(){
        switch(type){
            //if the codenode type used the val.str, we need to add a case here to free the memory
            case O_EXPR:
            case O_FUNC_CALL:
            case O_RIGHT_EXPR:
            case O_IF_STMT:
            case O_ELIF_STMT:
            
                delete val.str;
                val.str = nullptr;
                break;
    `