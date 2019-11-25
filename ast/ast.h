#include <vector>
#include <iostream>
#include <algorithm>
#include <string>
#include <map>
#include <stack>
#include <set>
#include <sstream>
#include <map>

void yyerror(const char *);
void yyerror(const char *, int);

class Identifier;
class FuncDecl;
class ConstExpr;
class DeclId;
class ListaCmd;

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

typedef std::map<std::string, std::stack< std::pair<DataType,int> > > VarSymTab;
typedef std::map<std::string, FuncDecl*> FuncSymTab;
static VarSymTab var_symbol_tab;
static FuncSymTab func_symbol_tab;
static std::stack< std::string > decl;
static int scope_lvl = 0;

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
		
		std::vector< ASTNode* > get_child(){
			return this->child;
		}

		void set_location(int lineno) { node_location = lineno; }
		
		void reverse() { std::reverse(child.begin(), child.end()); }
		
		virtual void run() {
			for( size_t i = 0; i < child.size(); i++ ) child[i]->run();
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

class DeclId : public ASTNode {
	protected:
		std::string* var_id;
		int var_size = -1;
	public:
		void run(DataType dt){
			if(func_symbol_tab.find(*var_id) != func_symbol_tab.end()){
				std::string error = "Declaracao previa de funcao com mesmo nome (" + *var_id + ")";
				yyerror(error.c_str(), node_location);
			}

			if(var_symbol_tab.find(*var_id) != var_symbol_tab.end() && var_symbol_tab[*var_id].top().second == scope_lvl){
				std::string error = "Variavel previamente declarada no escopo (" + *var_id + ")";
				yyerror(error.c_str(), node_location);
			}

			if( var_size != -1 ){
				if(dt == INT_T){
					dt = INT_ARRAY_T;
				}

				if(dt == CHAR_T){
					dt = CHAR_ARRAY_T;
				}
			}

			// std::cout << *var_id << " declarada com tipo " << dt << " no escopo " << scope_lvl << "\n";

			var_symbol_tab[*var_id].push(std::make_pair(dt, scope_lvl));
			decl.push(*var_id);
		}

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

		std::vector< ASTNode* > get_child(){
			return this->child;
		}

		std::string* getVarName() { return this->var_id; }
		int getVarSize() { return this->var_size; }
};

class ListaDeclVar : public ASTNode {
	protected:
		DataType var_type;
		std::vector< DeclId* > decl_var;
	public:
		void set_type(std::string *st){
			this->var_type = Helper::get_type_o(st);
		}

		void add_var(DeclId *var){
			(this->decl_var).push_back(var);
		}

		void run(){
			for(int i = 0 ; i < decl_var.size() ; i++){
				DeclId *a = decl_var[i];

				a->run(this->var_type);
			}

			for(int i = 0 ; i < (this->child).size() ; i++){
				this->child[i]->run();
			}
		}
};

class DeclVar : public ASTNode {
	public:
		DataType var_type;
	public:
		void setDataType(std::string* dt, bool is_array = false){
			this->var_type = Helper::get_type_o(dt, is_array);
		}

		void setDataType(DataType dt) { var_type = dt; }
		
		void run() {
			for (size_t i = 0; i < child.size(); i++){ 
				if(child[i] == NULL) continue;

				((DeclId*)child[i])->run(var_type);
			}
		}
};

class Bloco : public ASTNode{
	public:
		void run(){
			for(int i = 0 ; i < child.size() ; i++){
				if(child[i] == NULL) continue;

				if(dynamic_cast<Bloco*>(child[i]) != NULL){
					scope_lvl++;

					child[i]->run();

					scope_lvl--;
				}else{
					child[i]->run();
				}
			}
		}
};

class FuncParametro : public ASTNode{
	protected:
		DataType dt;
		std::string* id_name;
	public:
		void setDataType(std::string *d, bool is_array = false){
			this->dt = Helper::get_type_o(d, is_array);
		}

		void setName(std::string *id){
			this->id_name = id;
		}

		void run(){
			if(var_symbol_tab.find(*id_name) != var_symbol_tab.end() && var_symbol_tab[*id_name].top().second == scope_lvl){
				std::string error = "Redeclaracao da variavel " + *id_name + "."; 
				yyerror(error.c_str(), node_location);
			}

			var_symbol_tab[*id_name].push(std::make_pair(dt, scope_lvl));

			for(int i = 0 ; i < child.size() ; i++){
				child[i]->run();
			}
		}
};

class FuncBody : public ASTNode {
	public:
		DeclVar *params;
		Bloco *body;
		
		std::vector< ASTNode * > get_params(){
			if(params == NULL){
				std::vector< ASTNode * > p;

				return p;
			}

			return params->get_child();
		}

		void run() {
			for (size_t i = 0; i < child.size(); i++) child[i]->run();
		}

		FuncBody(ASTNode *par, ASTNode *bod){
			this->params = static_cast< DeclVar* > (par);
			this->body = static_cast< Bloco* > (bod);
		}
};

class FuncDecl : public ASTNode {
	protected:
		DataType func_type;
		std::string* func_name;
	public:
		FuncDecl(std::string *tp, std::string *nm){
			this->func_name = nm;
		}

		FuncBody* get_func_body(){
			return (FuncBody*) this->child[0];
		}

		void run(){
			if(var_symbol_tab.find(*func_name) != var_symbol_tab.end()){
				std::string error = "A função " + *func_name + " nao pode ter o mesmo nome que uma variavel declarada no mesmo escopo.";
				yyerror(error.c_str(), node_location);
			}

			if(func_symbol_tab.find(*func_name) != func_symbol_tab.end()){
				std::string error = "A função " + *func_name + " ja possui uma definicao previa.";
				yyerror(error.c_str(), node_location);
			}else{
				func_symbol_tab[*func_name] = this;
			}

			scope_lvl++;
			decl.push("#");

			if(this->child[0] != NULL){
				if(((FuncBody*)this->child[0])->params != NULL)
					(((FuncBody*)this->child[0])->params)->run();
				
				if(((FuncBody*)this->child[0])->body != NULL)
					(((FuncBody*) this->child[0])->body)->run();
			}

			scope_lvl--;

			while(decl.top() != "#"){
				var_symbol_tab[decl.top()].pop();
				decl.pop();
			}

			decl.pop();
		}
};

class Se : public ASTNode {
	public:
		void run() {
			for (size_t i = 0; i < child.size(); i++) child[i]->run();
		}

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
		void run() {
			for (size_t i = 0; i < child.size(); i++) child[i]->run();
		}

		Enquanto(ASTNode* expr, ASTNode* stmt){
			this->add(expr);
			this->add(stmt);
		}
};

class Expr : public ASTNode {
	public:
		DataType exp_tp;
	public:
		virtual void run(DataType &dt) {
			for (size_t i = 0; i < child.size(); i++) child[i]->run();
		}

		Expr(DataType dt){
			this->exp_tp = dt;
		}

		Expr(){
			this->exp_tp = INT_T;
		}
};

class Identifier : public ASTNode {
	protected:
		std::string* id;
	public:
		void run(DataType &a) {
			// std::cout << (*id).length() << " existe ?\n";
			// std::cout << "sim e tem tipo igual a " << var_symbol_tab[*id].top().first<< "\n";

			if(var_symbol_tab.find(*id) == var_symbol_tab.end()){
				std::string error = "Variavel " + *id + " nao declarada.";
				yyerror(error.c_str(), node_location);
			}

			// printf("erro %d\n", var_symbol_tab["z"].top().first);

			a = var_symbol_tab[*id].top().first;
			
			// std::cout << a << "\n";
			a = var_symbol_tab[*id].top().first;
			a = var_symbol_tab[*id].top().first;
			// std::cout << var_symbol_tab[*id].size() << "\n";

		}

		Identifier(std::string* id, ASTNode* arr_pos = NULL){
			this->id = id;
			this->add(arr_pos);
		}
};

class AssignExpr : public Expr {
	protected:
		ASTNode *lhs;
		Expr *rhs;
	public:
		void run(DataType &dt) {
			static_cast< Identifier* >(lhs)->run(dt);

			DataType o;

			rhs->run(o);
			// std::cout << "AQUI\n";

			if(o != dt){
				std::cout << dt << " " << o << "\n";
				std::string error = "Expressao com tipos incompativeis. ";
				yyerror(error.c_str(), node_location);
			}
		}

		AssignExpr(ASTNode* lhs, Expr* rhs) : Expr(INT_T){
			this->lhs = lhs;
			this->rhs = rhs;
		}
};

class TernExpr : public Expr {
	protected:
		Expr *expr, *at1, *at2;
	public:
		void run(DataType &dt) {
			at1->run(dt);

			DataType o;

			at2->run(o);

			if(dt != o){
				std::string error = "Expressao ternaria com tipos incompativeis.";
				yyerror(error.c_str(), node_location);
			}
		}

		TernExpr(Expr* expr, Expr* at1, Expr* at2) : Expr(INT_T){
			this->expr = expr;
			this->at1 = at1;
			this->at2 = at2;
		}
};

class BinaryExpr : public Expr {
	protected:
		Op op;
	public:
		void run(DataType &dt) {
			for (size_t i = 0; i < child.size(); i++) child[i]->run();
		}

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
		void run(DataType &dt) {
			for (size_t i = 0; i < child.size(); i++) child[i]->run();
		}

		UnaryExpr(ASTNode* expr, UnOp opt = NOTHING) : Expr(INT_T){
			this->op = opt;
		
			this->add(expr);
		}
};	

class ConstExpr : public Expr {
	protected:
		std::string* value;
		DataType exp_tp;
	public:
		void run(DataType &dt) {
			dt = this->exp_tp;
			// std::cout << "const expr com tipo" << dt << "\n";
		}

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

class FuncCall : public ASTNode {
	protected:
		std::string* func_id;
		DataType dt;
	public:
		void run() {
			FuncDecl *func = func_symbol_tab[*func_id];
			FuncBody *body = func->get_func_body();
			std::vector< ASTNode* > params = body->get_params();

			if(this->child[0] == NULL && body->params != NULL){
				std::string error = "A função " + *func_id + " nao aceita ser chamada sem parametros.";
				yyerror(error.c_str(), node_location);
			}

			if(this->child[0] != NULL && body->params == NULL){
				std::string error = "A função " + *func_id + " nao aceita ser chamada com parametros.";
				yyerror(error.c_str(), node_location);
			}

			std::vector< ASTNode* > args;

			if(this->child[0] != NULL){
				args = this->child[0]->get_child();
			}

			if(args.size() != params.size() / 2){
				std::string error = "Numero de parametros para a função " + *func_id + " incorretos";
				yyerror(error.c_str(), node_location);
			}

			for(int i = 0 ; i < args.size() ; i++){
				Expr *r = (Expr*) args[i];
				DeclVar *e = (DeclVar*) params[i * 2];

				if(r->exp_tp != e->var_type){
					std::string error = "Tipos para argumentos da funcao " + *func_id + " incorretos";
					yyerror(error.c_str(), node_location);
				}
			}
		}

		FuncCall(std::string* func_nm, ASTNode* args = NULL){
			this->add(args);

			this->func_id = func_nm;
		}
};

class ArgList : public ASTNode {
	public:
		void run() {
			for (size_t i = 0; i < child.size(); i++) child[i]->run();
		}
};

class Leia : public ASTNode{
	protected:
		Identifier* var_id;
	public:	
		void run() {
			for (size_t i = 0; i < child.size(); i++) child[i]->run();
		}

		Leia(Identifier* identifier) : var_id(identifier) {}
};

class Escreva : public ASTNode {
	public:
		Escreva(){}

		Escreva(ASTNode *expr){
			this->add(expr);
		}

		void run() {
			for (size_t i = 0; i < child.size(); i++) child[i]->run();
		}
};

class Return : public ASTNode {
	protected:
		DataType rtype;
		Expr* rval;
	public:
		Return(ASTNode* expr) : rval(static_cast< Expr* >(expr)) {}

		DataType getReturnType() { return this->rtype; }

		void run() {
			for (size_t i = 0; i < child.size(); i++) child[i]->run();
		}
};

class ListaCmd : public ASTNode{
	public:
		void run(){
			for(int i = 0 ; i < child.size() ; i++){
				DataType test;

				static_cast< AssignExpr* >(child[i])->run(test);
			}
		}
};

class Stmt : public ASTNode{
	public:
		void run() {
			for (size_t i = 0; i < child.size(); i++){ 
				
				child[i]->run();
			}
		}
};