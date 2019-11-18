#include <vector>
#include <iostream>
#include <algorithm>
#include <string>
#include <map>
#include <stack>
#include <set>
#include <sstream>

void yyerror(const char *);
void yyerror(const char *, int);

class Identifier;
class FuncDecl;
class ConstExpr;

enum DataType 
{
	CHAR_T = 0x0,
	INT_T = 0x1,
	CHAR_ARRAY_T = 0x2,
	INT_ARRAY_T = 0x3
};

class ASTNode {
	protected:
		std::vector< ASTNode* > child;
		int node_location;
	public:
		ASTNode() { child.clear(); }
		
		virtual void add(ASTNode* node) { child.push_back(node); }

		virtual void add_back(ASTNode* node){ 
			child.push_back(new ASTNode());

			for(int i = child.size() - 1 ; i >= 1 ; i--){
				child[i] = child[i - 1];
			}

			child[0] = node;
		}
		
		void set_location(int lineno) { node_location = lineno; }
		
		void reverse() { std::reverse(child.begin(), child.end()); }
		
		virtual void walk(int depth) {
			#ifdef DBG_PRINT_TREE
				INDENT( depth )
				std::cout << " em um ASTNode qualquer.." << std::endl;
			#endif
			for( size_t i = 0; i < child.size(); i++ ) child[i]->walk( depth+1 );
		}
};

class Helper{
public:
	static DataType get_type_o(std::string *dt, bool is_array = false){
		if(*dt == "char"){
			if(!is_array)
				return CHAR_T;
			else
				return CHAR_ARRAY_T;
		}else if(*dt == "int"){
			if(!is_array)
				return INT_T;
			else
				return INT_ARRAY_T;
		}
	}
};

class DeclVar : public ASTNode {
	protected:
		DataType var_type;
	public:
		void setDataType(std::string* dt, bool is_array = false){
			this->var_type = Helper::get_type_o(dt, is_array);
		}

		void setDataType(DataType dt) { var_type = dt; }
		
		void walk(int depth) {
			// #ifdef DBG_PRINT_TREE
			// 	INDENT(depth)
			// 	std::cout << " declarando variaveis tipo " << getTypeName(var_type) << std::endl;
			// #endif
			
			// for (size_t i = 0; i < child.size(); i++) ((DeclIdentifier*)child[i])->walk(depth+1, var_type);	
		}
};

class DeclId : public ASTNode {
	protected:
		std::string* var_id;
		int var_size = -1;
	public:
		DeclId(std::string *identifier){
			this->var_id = identifier;
		}

		DeclId(std::string *identifier, int sz){
			this->var_id = identifier;
			this->var_size = sz;
		}

		DeclId(std::string *identifier, std::string *sz){
			this->var_id = identifier;
			this->var_size = std::stoi(*sz);
		}

		void set_var_id(std::string* name){
			this->var_id = name;
		}

		std::string* getVarName() { return this->var_id; }
		int getVarSize() { return this->var_size; }
};

class FuncDecl : public ASTNode {
	protected:
		DataType func_type;
		std::string* func_name;
	public:
		FuncDecl(std::string *tp, std::string *nm){
			this->func_name = nm;
			this->func_type = Helper::get_type_o(tp);
		}


};