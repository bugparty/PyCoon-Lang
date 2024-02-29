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
        debug();
        for(size_t i =0;i<children.size();i++){
            if(children[i]->type != O_FUNC_CALL){
                switch(children[i]->type){
                    case O_INT:
                    case O_FLOAT:
                    case O_DOUBLE:
                    {
                        auto tempVar = ctx->allocate_temp(SymbolType::SYM_VAR_INT);
                        ss << ". " << tempVar << std::endl;
                        ss << "= " << tempVar << ", " << children[i]->val.i  << std::endl;
                        args.push_back(tempVar);
                    }
                        break;
                    case O_IDENTIFIER:
                    case IDENTIFIER:
                        args.push_back(children[i]->sourceCode);
                        break;
                    case O_EXPR:
                    case O_FUNC_CALL:

                        args.push_back(*(children[i]->val.str));
                        break;
                    default:
                        return false;
                }
            }else{// we suppose the function call in arguments is alsways already processed
                ss << children[i]->IRCode;
                args.push_back(*(children[i]->val.str));
            }
        }
        return true;
    }
    bool CodeNode::genFunctionCallIRCode(std::stringstream &ss, std::string &funName){
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
        ss << "call " << funName << ", " << tempVar << std::endl;
        
        return true;
    }
    std::string CodeNode::getImmOrVariableIRCode(){
        std::stringstream ss;
        getImmOrVariableIRCode(ss);
        return ss.str();
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
            
                if(val.str == nullptr){
                    return false;
                }
                ss << *(val.str);
                break;

            default:
                OWARN("getImmOrVariableIRCode: unknown type %d\n",type);
                return false;
        }
        return true;
    }