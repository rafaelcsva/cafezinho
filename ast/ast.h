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

enum Op
{
		MOD,
        PLUS,
        MINUS,
        TIMES,
        DIVIDES,
        GREATER,
        LESS,
		EQUALS,
        NOT_EQUAL,
		LESS_EQUAL,
		GREATER_EQUAL,
        LOGICAL_OR,
        LOGICAL_AND,
		NOT
};

enum UnOp{
	INV,
	NEG,
	NOTHING
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

class Se : public ASTNode {
	public:
		Se(ASTNode* expr, ASTNode* stmt, ASTNode* elsestmt = NULL){
			this->add(expr);
			this->add(stmt);

			if(elsestmt != NULL){
				this->add(elsestmt);
			}
		}
};

class Enquanto : public ASTNode {
	public:
		Enquanto(ASTNode* expr, ASTNode* stmt){
			this->add(expr);
			this->add(stmt);
		}
};

class Expr : public ASTNode {
	protected:
		DataType exp_tp;
	public:
		Expr(DataType dt){
			this->exp_tp = dt;
		}

		Expr(){
			this->exp_tp = INT_T;
		}
};

class AssignExpr : public Expr {
	public:
		AssignExpr(ASTNode* lhs, ASTNode* rhs) : Expr(INT_T){
			this->add(lhs);
			this->add(rhs);
		}
};

class TernExpr : public Expr {
	public:
		TernExpr(ASTNode* expr, ASTNode* at1, ASTNode* at2) : Expr(INT_T){
			this->add(expr);
			this->add(at1);
			this->add(at2);	
		}
};

class BinaryExpr : public Expr {
	protected:
		Op op;
	public:
		BinaryExpr(Op op, ASTNode* lhs, ASTNode* rhs) : Expr(INT_T){
			this->op = op;
			this->add(lhs);
			this->add(rhs);
		}
};

class UnaryExpr : public Expr {
	protected:
		UnOp op;
	public:
		UnaryExpr(ASTNode* expr, UnOp opt = NOTHING) : Expr(INT_T){
			this->op = opt;
		
			this->add(expr);
		}
};	

class ConstExpr : public Expr {
	protected:
		std::string* value;
	public:
		ConstExpr(DataType dt, std::string* val) : Expr(dt){
			this->value = val;
		}

		int getIntVal(){
			return stoi(*value);
		}

		std::string getStringVal(){
			return *value;
		}

		char getCharVal(){
			if( value->at(0) == '\\' ){
				switch( value->at(1) ){
					case '0': return '\0';
					case 'n': return '\n';
					case 't': return '\t';
					case 'a': return '\a';
					case 'r': return '\r';
					case 'b': return '\b'; 
					case 'f': return '\f';
					case '\\': return '\\';
				}
			}

			return value->at(0);
		}
};

class FuncCall : public Expr {
	protected:
		std::string* func_id;
	public:
		FuncCall(std::string* func_nm, ASTNode* args = NULL){
			this->add(args);

			this->func_id = func_nm;
		}
};

class ArgList : public ASTNode {
	public:
		std::vector< ASTNode* > get_childs(){
			return this->child;
		}
};

class Identifier : public ASTNode {
	protected:
		DataType var_tp;
		std::string* id;
	public:
		Identifier(std::string* id, ASTNode* arr_pos = NULL){
			this->id = id;
			this->add(arr_pos);
		}
};

class Leia : public ASTNode{
	protected:
		Identifier* var_id;
	public:	
		Leia(Identifier* identifier) : var_id(identifier) {}
};

class Escreva : public ASTNode {
	public:
		Escreva(){}

		Escreva(ASTNode *expr){
			this->add(expr);
		}
};

class Return : public ASTNode {
	protected:
		DataType rtype;
		Expr* rval;
	public:
		Return(ASTNode* expr) : rval(static_cast< Expr* >(expr)) {}

		DataType getReturnType() { return this->rtype; }
};

class Cmd : public ASTNode{

};