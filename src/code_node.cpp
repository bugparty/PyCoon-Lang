    #include "code_node.hpp"
    #include "symbol_table.hpp"
    #include "tok.h"
#define ENABLE_CODE_NODE_PRINTF 1
#if ENABLE_CODE_NODE_PRINTF
#define ODEBUG( ...) \
    do{printf("CodeNode: ");printf( __VA_ARGS__ );printf("\t\tFile:%s:%d:0\n",__FILE__,__LINE__);}while(0)
#else
    #define ODEBUG( ...)
#endif
#define OWARN( ...) \
    do{fprintf(stderr, "\e[35mBISON: ");printf( __VA_ARGS__ );printf("\t\tFile:%s:%d:0\e[0m\n",__FILE__,__LINE__);}while(0)

#define OERROR( ...) \
    do{fprintf(stderr, "\e[31mBISON: ");printf( __VA_ARGS__ );printf("\t\tFile:%s:%d:0\e[0m\n",__FILE__,__LINE__);yyerror("error");}while(0)

    bool CodeNode::genFunctionCallIRCodeImpl(std::stringstream &ss, std::vector<std::string> &args){
        if(type != O_FUNC_CALL){
            return false;
        }
        auto ctx = SymbolManager::getInstance();
        CodeNode* funArgs = children[1];
        if(funArgs->type != O_FUNC_ARGS){
            OWARN("genFunctionCallIRCodeImpl: function call node's second child is not O_FUNC_ARGS\n");
            return false;
        }
        for(size_t i =0;i<funArgs->children.size();i++){
            if(funArgs->children[i]->type != O_FUNC_CALL){
                switch(funArgs->children[i]->type){
                    case O_INT:
                    case O_FLOAT:
                    case O_DOUBLE:
                    {
                        auto tempVar = ctx->allocate_temp(SymbolType::SYM_VAR_INT);
                        ss << ". " << tempVar << std::endl;
                        ss << "= " << tempVar << ", " << funArgs->children[i]->val.i  << std::endl;
                        args.push_back(tempVar);
                    }
                        break;
                    case O_IDENTIFIER:
                    case IDENTIFIER:
                        args.push_back(funArgs->children[i]->sourceCode);
                        break;
                    case O_EXPR:
                    case O_FUNC_CALL:

                        args.push_back(*(funArgs->children[i]->val.str));
                        break;
                    default:
                        return false;
                }
            }else{// we suppose the function call in arguments is alsways already processed
                ss << funArgs->children[i]->IRCode;
                args.push_back(*(funArgs->children[i]->val.str));
            }
        }
        return true;
    }
    bool CodeNode::genFunctionCallIRCode(std::stringstream &ss){
        std::vector<std::string> args;
        bool succeed = genFunctionCallIRCodeImpl(ss,args);
        if(!succeed){
            return false;
        }
        auto ctx = SymbolManager::getInstance();
        auto tempVar = ctx->allocate_temp(SymbolType::SYM_VAR_INT);
        val.str = new std::string(tempVar);
        ss << ". " << tempVar << std::endl;
        for(size_t i =0;i<args.size();i++){
            ss << "param " << args[i] << std::endl;
        }
        ss << "call " << sourceCode << ", " << tempVar << std::endl;
        
        return true;
    }
    std::string CodeNode::getImmOrVariableIRCode(){
        std::stringstream ss;
        getImmOrVariableIRCode(ss);
        return ss.str();
    }
    CodeNode::CodeNode(const CodeNode& right){
        this->IRCode = right.IRCode;
        this->sourceCode = right.sourceCode;
        this->val = right.val;
        this->type = right.type;
        this->subType = right.subType;
        this->children = right.children;
        //std::cout << "copy constructor"<<std::endl;
    }
    void CodeNode::printIR(){
        std::cout<<"IRCode:"<<std::endl << IRCode <<"end of IRCode"<<std::endl;
    }
    void CodeNode::debug(bool recursive){
        std::cout << "sourceCode: " << sourceCode << std::endl;
        std::stringstream ss;
        getImmOrVariableIRCode(ss);
        std::cout << "val: " << ss.str() << std::endl;
        std::cout << "type:" << type <<" subtype: " << subType;
        std::cout << " children size:" << children.size() <<std::endl;
        for(size_t i=0;i<children.size();i++){
            std::cout << i << "th child, address: " << children[i] << " type:" << children[i]->type <<
            " children size: "<<children[i]->children.size()<< std::endl;
            if(recursive){
                children[i]->debug();
            }
            
        }
        printIR();
    }
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
            case O_WHILE_STMT:
            //case O_FOR_STMT:
                delete val.loopTag;
                val.loopTag=nullptr;
                break;
            //these case don't need to free the memory
            case O_INT:
            case O_FLOAT:
            case O_DOUBLE:
            case O_LEFT_EXPR:
            
            case O_ELSE_STMT:
            
            
                 break;
            default:
                OWARN("freeUnionVal: unknown type %d\n",type);
                break;
        }
    }
    CodeNode::~CodeNode(){
        //std::cout << "destructor called at "<< this << " type: " << type << std::endl;
        //free the memory of val's pointer
        freeUnionVal();
        // recursively delete all the children,will call the destructor of children
        for(size_t i=0;i<children.size();i++){
            delete children[i];
        }
    }
    bool CodeNode::getImmOrVariableIRCode(std::stringstream& ss){
        switch(type){
            case O_INT:
                ss << val.i;
                break;
            case O_FLOAT:
                ss << val.f;
                break;
            case O_DOUBLE:
                ss << val.d;
                break;
            case O_IDENTIFIER:
            case IDENTIFIER:
            case O_VAR_DECLARATION:
                ss << sourceCode;
                break;
            case O_EXPR:
            case O_FUNC_CALL:
            //case YYSYMBOL_left_array_access_expr:
            
                if(val.str == nullptr){
                    return false;
                }
                ss << *(val.str);
                break;
            case O_CONTAINER:
                return false;
                break;
            default:
                OWARN("getImmOrVariableIRCode: unknown type %d\n",type);
                return false;
        }
        return true;
    }