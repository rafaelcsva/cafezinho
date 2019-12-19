#include <vector>
#include <iostream>
#include <algorithm>
#include <string>
#include <map>
#include <stack>
#include <set>
#include <sstream>
#include <map>
#include <string.h>

void yyerror(const char *);
void yyerror(const char *, int);

class ASTNode;
class Identifier;
class FuncDecl;
class ConstExpr;
class DeclId;
class ListaCmd;
class FuncBody;
class FuncParametro;

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

class VarNode{
public:
	DataType first;
	int second;//scope-level-comes-here
	int size = -1;
	int position;
};

typedef std::map<std::string, std::stack< VarNode > > VarSymTab;
typedef std::map<std::string, FuncDecl*> FuncSymTab;
static std::stack< DataType > func_ttp;
static std::stack< std::string > func_call_stack;
const int N = 1000, SIZE_ARRAY = 100;
static int escopo[N];
static std::vector< VarNode > globals;
static VarSymTab var_symbol_tab;
static FuncSymTab func_symbol_tab;
static std::stack< std::string > decl;
static int scope_lvl = 0;
static int inside_func = false;
static bool moved_s1 = false;
static int st_num = 0;
static int label = 0;
static int enquanto_num = 0;
static std::map< std::string, std::vector< std::pair< std::string, int > > > func_params;
static int lsize = 0;
static int totglobals = 0;
static std::map< std::string, bool > taked;

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

		virtual void run(DataType &dt) {
			for (size_t i = 0; i < child.size(); i++) child[i]->run();
		}

		virtual void generate_code(){
			if(!moved_s1){
				printf("move $s1, $sp\n");
				printf("b MAIN\n");
				moved_s1 = true;
			}
			// printf("gerando codigo em um AST qqr\n");

			for (size_t i = 0; i < child.size(); i++){
				if(child[i] == NULL) continue;

				child[i]->generate_code();
			} 
		}
};


class Expr : public ASTNode {
	public:
		DataType exp_tp;
	public:
		Expr(DataType dt){
			this->exp_tp = dt;
		}

		Expr(){
			this->exp_tp = INT_T;
		}

		DataType get_type(){
			return exp_tp;
		}
};

class Identifier : public Expr {
	protected:
		std::string* id;
	public:
		ASTNode* get_child(){
			return child[0];
		}

		void run(DataType &a) {
			// std::cout << *id << " procurando id " << var_symbol_tab[*id].size() << "\n";

			if(var_symbol_tab.find(*id) == var_symbol_tab.end() || var_symbol_tab[*id].empty()){
				std::string error = "Variavel " + *id + " nao declarada.";
				yyerror(error.c_str(), node_location);
			}

			// std::cout << *id << " procurando id " << var_symbol_tab[*id].size() << "\n";

			a = var_symbol_tab[*id].top().first;

		}

		void generate_code(){
			if(var_symbol_tab[*this->get_id()].empty()){//entao ele eh um parametro da funcao..
				int pos = 0;

				for(std::pair< std::string, int > u: func_params[func_call_stack.top()]){
					if(u.first == *this->get_id()){
						break;
					}

					pos += u.second;
				}

				printf("lw $s0, %d($fp)\n", (pos + 1) * 4);
			}else if(inside_func == 0){
				VarNode a = var_symbol_tab[*this->get_id()].top();

				int d = 0;

				for(int i = 0 ; i < a.second ; i++){
					d += escopo[i];
				}

				d += a.position;
		
				printf("lw $s0, %d($s1)\n", -d * 4);//acesso
			}else{
				int d = 0;

				VarNode a = var_symbol_tab[*this->get_id()].top();

				if(a.second == 0){
					printf("lw $s0, %d($s1)\n", -d);
				}else{
					for(int i = 1 ; i < a.second ; i++){
						d += escopo[i];
					}

					d += a.first;

					printf("lw $s0, %d($fp)\n", -(d + 1) * 4);
				}
			}
		}

		Identifier(std::string* id, ASTNode* arr_pos = NULL) : Expr(INT_T){
			this->id = id;

			this->add(arr_pos);
		}

		std::string* get_id(){
			return this->id;
		}
};

class Helper{
	public:

		static DataType get_type_o(std::string *dt, bool is_array = false){
			if(*dt == "car"){
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

		static bool incompativel(DataType a, DataType b){
			if(a == CHAR_ARRAY_T){
				a = CHAR_T;
			}

			if(a == INT_ARRAY_T){
				a = INT_T;
			}

			if(b == INT_ARRAY_T){
				b = INT_T;
			}

			if(b == CHAR_ARRAY_T){
				b = CHAR_T;
			}

			return a != b;
		}

		static int get_size_params(){
			int tot = 0;

			for(std::pair< std::string, int > u: func_params[func_call_stack.top()]){
				tot += u.second;
			}

			return tot;
		}

		static int get_deslocamento(Identifier *id){
			if(var_symbol_tab[*id->get_id()].empty()){//entao ele eh um parametro da funcao..
				int pos = 0;

				for(std::pair< std::string, int > u: func_params[func_call_stack.top()]){
					if(u.first == *id->get_id()){
						break;
					}

					pos += u.second;
				}

				return pos;
			}

			// std::cou
			VarNode a = var_symbol_tab[*id->get_id()].top();

			int d = 0;

			for(int i = 0 ; i < a.second ; i++){
				d += escopo[i];
			}

			d += a.position;
			
			return d;
		}

		static void empilha_s0(int sz = 1){
			printf("sw $s0, 0($sp)\n");
			printf("addiu $sp, $sp, %d\n", -4 * sz);
		}

		static void desempilhar(){
			printf("addiu $sp, $sp, 4\n");
		}
};

class DeclId : public ASTNode {
	protected:
		std::string* var_id;
		int var_size = -1;
	public:
		void run(DataType dt){
			// std::cout << "declarando " << *var_id << '\n';

			if(func_symbol_tab.find(*var_id) != func_symbol_tab.end()){
				std::string error = "Declaracao previa de funcao com mesmo nome (" + *var_id + ")";
				yyerror(error.c_str(), node_location);
			}
			
			if(var_symbol_tab.find(*var_id) != var_symbol_tab.end() && !var_symbol_tab[*var_id].empty() && var_symbol_tab[*var_id].top().second == scope_lvl){
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

			// std::cout << *var_id << " com tipo " << dt << " declarada no escopo " << scope_lvl << "\n";

			if(scope_lvl == 0){
				globals.push_back({dt, scope_lvl, var_size, escopo[scope_lvl]});
				if(!taked[*var_id])
					totglobals += var_size == -1 ? 1 : var_size;
		
				taked[*var_id] = true;

			}

			var_symbol_tab[*var_id].push({dt, scope_lvl, var_size, escopo[scope_lvl]});
			escopo[scope_lvl] += (var_size == -1) ? 1 : var_size;

			decl.push(*var_id);
		}

		void get_ids(std::vector< ASTNode* > &v){
			v.push_back(this);

			// printf("ids tem %lu filhos!\n", this->child.size());

			if(this->child.size()){
				static_cast< DeclId* >(this->child[0])->get_ids(v);
			}
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

		void generate_code(){
			for(int i = 0 ; i < decl_var.size() ; i++){
				DeclId *a = decl_var[i];

				a->run(this->var_type);
			}

			int tot = 0;

			if(!moved_s1){
				printf("move $s1, $sp\n");
				Helper::empilha_s0(totglobals);
				printf("b MAIN\n");
				moved_s1 = true;
			}

			for(int i = 0 ; i < decl_var.size() ; i++){
				DeclId *a = decl_var[i];

				tot += (a->getVarSize() == -1 ? 1 : a->getVarSize());
			}

			if(scope_lvl != 0)
				printf("addiu $sp, $sp, %d\n", -tot * 4);//Deslocar a pilha o número de variáveis + 1

			for(int i = 0 ; i < (this->child).size() ; i++){
				this->child[i]->generate_code();
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
			decl.push("#");

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

			while(decl.top() != "#"){
				var_symbol_tab[decl.top()].pop();
				decl.pop();
			}

			decl.pop();
		}

		virtual void generate_code(){
			if(!moved_s1){
				printf("move $s1, $sp\n");
				printf("b MAIN\n");
				moved_s1 = true;
			}
			// printf("gerando codigo em um AST qqr\n");

			decl.push("#");

			for (size_t i = 0; i < child.size(); i++){
				if(child[i] == NULL) continue;

				child[i]->generate_code();
			} 

			while(decl.top() != "#"){
				var_symbol_tab[decl.top()].pop();
				decl.pop();
			}

			decl.pop();
		}
};

class FuncParametro : public ASTNode{
	public:
		DataType dt;
		std::string* id_name;
	public:
		void setDataType(std::string *d, bool is_array = false){
			this->dt = Helper::get_type_o(d, is_array);
		}

		DataType get_type(){
			return dt;
		}

		void setName(std::string *id){
			this->id_name = id;
		}

		void run(){
			// std::cout << *id_name << " sendo declarado\n";
			if(var_symbol_tab.find(*id_name) != var_symbol_tab.end() && var_symbol_tab[*id_name].top().second == scope_lvl){
				std::string error = "Redeclaracao da variavel " + *id_name + "."; 
				yyerror(error.c_str(), node_location);
			}

			var_symbol_tab[*id_name].push({dt, scope_lvl});
			decl.push(*id_name);

			for(int i = 0 ; i < child.size() ; i++){
				child[i]->run();
			}
		}

		void get_params(std::vector< FuncParametro* > &params){
			params.push_back(this);

			if(this->child.size()){
				static_cast< FuncParametro* >(this->child[0])->get_params(params);
			}
		}

		std::string get_name(){
			return *this->id_name;
		}
};

class FuncBody : public ASTNode {
	public:
		FuncParametro *params;
		Bloco *body;
		
		FuncParametro* get_params(){
			return params;
		}

		void run() {
			FuncBody *body = this;
			FuncParametro *params = body->get_params();

			std::vector< FuncParametro* > param_list;

			if(params != NULL){
				params->get_params(param_list);
			}

			for(int i = 0 ; i < param_list.size() ; i++){
				FuncParametro *e = param_list[i];

				int sz = 1;

				if(e->get_type() != CHAR_T && e->get_type() != INT_T){
					sz = SIZE_ARRAY;
				}

				func_params[func_call_stack.top()].push_back({e->get_name(), sz});
			}
		}

		void generate_code(){
			
		}

		FuncBody(ASTNode *par, ASTNode *bod){
			this->params = static_cast< FuncParametro* > (par);
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
			// std::cout << *tp << " eh o tipo da minha funcao!\n";
			func_type = Helper::get_type_o(tp);
			// printf("possui tipo %d\n", func_type);
		}

		FuncBody* get_func_body(){
			return (FuncBody*) this->child[0];
		}

		void generate_code(){
			func_symbol_tab[*func_name] = this;

			printf("%s:\n", func_name->c_str());

			printf("move $fp, $sp\n");
			printf("sw $ra, 0($sp)\n");
			printf("addiu $sp, $sp, -4\n");

			func_call_stack.push(*func_name);

			scope_lvl++;
			decl.push("#");

			if(this->child[0] != NULL){
				this->child[0]->run();

				if(((FuncBody*)this->child[0])->params != NULL){
					(((FuncBody*)this->child[0])->params)->generate_code();
				}

				if(((FuncBody*)this->child[0])->body != NULL)
					(((FuncBody*) this->child[0])->body)->generate_code();
			}

			scope_lvl--;

			while(decl.top() != "#"){
				// std::cout << decl.top() << " sendo tirado!\n";
				var_symbol_tab[decl.top()].pop();
				decl.pop();
			}

			decl.pop();

			printf("FIM%s:\n", func_name->c_str());
			
			func_call_stack.pop();
		}

		void run(){
			func_ttp.push(this->func_type);
			// printf("a funcao tem tipo %d\n", func_ttp);

			if(var_symbol_tab.find(*func_name) != var_symbol_tab.end()){
				std::string error = "A função " + *func_name + " nao pode ter o mesmo nome que uma variavel declarada no mesmo escopo.";
				yyerror(error.c_str(), node_location);
			}

			if(func_symbol_tab.find(*func_name) != func_symbol_tab.end()){
				std::string error = "A função " + *func_name + " ja possui uma definicao previa.";
				yyerror(error.c_str(), node_location);
			}else{
				// std::cout << *func_name << " declarada!\n";
				func_symbol_tab[*func_name] = this;
			}

			scope_lvl++;
			decl.push("#");

			if(this->child[0] != NULL){
				if(((FuncBody*)this->child[0])->params != NULL){
					(((FuncBody*)this->child[0])->params)->run();
				}

				if(((FuncBody*)this->child[0])->body != NULL)
					(((FuncBody*) this->child[0])->body)->run();
			}

			scope_lvl--;

			while(decl.top() != "#"){
				// std::cout << decl.top() << " sendo tirado!\n";
				var_symbol_tab[decl.top()].pop();
				decl.pop();
			}

			decl.pop();

			func_ttp.pop();
		}

		static void generate_code_to_id(std::string id){
			
		}
};

class Se : public Expr {
	public:
		void run(DataType &dt){
			for (size_t i = 0; i < child.size(); i++) static_cast< Expr* >(child[i])->run(dt);
		}

		Se(ASTNode* expr, ASTNode* stmt, ASTNode* elsestmt = NULL) : Expr(INT_T){
			this->add(expr);
			this->add(stmt);

			if(elsestmt != NULL){
				this->add(elsestmt);
			}
		}

		void generate_code(){
			int lab = label;
			label++;

			child[0]->generate_code();

			printf("beq $s0, 0, SENAO%d\n", lab);
			
			if(child[1] != NULL)
				child[1]->generate_code();
			
			printf("b FIMSE%d\n", lab);

			printf("SENAO%d:\n", lab);

			if(child.size() > 2){
				child[2]->generate_code();
			}

			printf("FIMSE%d:\n", lab);
		}
};

class Enquanto : public Expr {
	public:
		void generate_code(){
			int meq = enquanto_num;
			enquanto_num++;
			printf("ENQUANTO%d:\n", meq);
			child[0]->generate_code();
			printf("beq $s0, 0, FIMENQUANTO%d\n", meq);
			
			if(child.size() > 1){
				child[1]->generate_code();
			}

			child[0]->generate_code();
			
			printf("beq $s0, 1, ENQUANTO%d\n", meq);

			printf("FIMENQUANTO%d:\n",meq);
		}

		void run(DataType &dt) {
			// printf("Enquanto tem %lu filhos!\n", child.size());

			for (size_t i = 0; i < child.size(); i++){
				child[i]->run(dt);
			}
		}

		Enquanto(ASTNode* expr, ASTNode* stmt){
			this->add(expr);
			if(stmt != NULL){
				this->add(stmt);
			}
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

			if(Helper::incompativel(o, dt)){
				// std::cout << dt << " " << o << "\n";
				std::string error = "Expressao com tipos incompativeis. ";
				yyerror(error.c_str(), node_location);
			}
		}

		void generate_code(){
			rhs->generate_code();
			
			Identifier *id = static_cast< Identifier* >(lhs);
			
			// std::cout << *id->get_id() << " " << var_symbol_tab[*id->get_id()].size();

			int d = Helper::get_deslocamento(id);

			if(id->get_child() == NULL){
				printf("sw $s0, %d($s1)\n", -d * 4);
			}else{
				Helper::empilha_s0();

				printf("lw $a0, %d($s1)\n", -d * 4);//a0 eh o endereco do array

				id->get_child()->generate_code();

				printf("sll $s0, $s0, 2\n");

				printf("addu $a1, $s0, $a0\n");//a1 eh o endereco ja com a posicao correta

				printf("lw $t1, 4($sp)\n");

				Helper::desempilhar();

				printf("sw $t1, 0($a1)\n");
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
		ASTNode *lhs, *rhs;
	public:
		void run(DataType &dt) {
			static_cast< Expr* >(lhs)->run(dt);

			DataType o;

			static_cast< Expr* >(rhs)->run(o);

			if(Helper::incompativel(dt, o)){
				std::string error = "Expressao utiliza tipos incompativeis.";
				yyerror(error.c_str(), node_location);
			}
		}

		BinaryExpr(Op op, ASTNode* lhs, ASTNode* rhs) : Expr(INT_T){
			this->op = op;
			this->lhs = lhs;
			this->rhs = rhs;
		}

		void generate_code(){
			lsize = 1;

			lhs->generate_code();

			Helper::empilha_s0();

			rhs->generate_code();

			printf("lw $t1, 4($sp)\n");

			Helper::desempilhar();

			if(op == GREATER){
				printf("sub $s0, $t1, $s0\n");
				printf("bgtz $s0, A%d\n", label);
				printf("li $s0, 0\n");
				printf("b FIM_A%d\n", label);
				printf("A%d:\n", label);
				printf("li $s0, 1\n");
				printf("FIM_A%d:\n", label);
				label++;
			}else if(op == LESS){
				printf("sub $s0, $t1, $s0\n");
				printf("bltz $s0, A%d\n", label);
				printf("li $s0, 0\n");
				printf("b FIM_A%d\n", label);
				printf("A%d:\n", label);
				printf("li $s0, 1\n");
				printf("FIM_A%d:\n", label);
				label++;
			}else if(op == LESS_EQUAL){
				printf("sub $s0, $t1, $s0\n");
				printf("blez $s0, A%d\n", label);
				printf("li $s0, 0\n");
				printf("b FIM_A%d\n", label);
				printf("A%d:\n", label);
				printf("li $s0, 1\n");
				printf("FIM_A%d:\n", label);
				label++;
			}else if(op == GREATER_EQUAL){
				printf("sub $s0, $t1, $s0\n");
				printf("bgezal $s0, A%d\n", label);
				printf("li $s0, 0\n");
				printf("b FIM_A%d\n", label);
				printf("A%d:\n", label);
				printf("li $s0, 1\n");
				printf("FIM_A%d:\n", label);
				label++;
			}else if(op == PLUS){
				printf("add $s0, $t1, $s0\n");
			}else if(op == MINUS){
				printf("sub $s0, $t1, $s0\n");
			}else if(op == TIMES){
				printf("mult $s0, $t1\n");
				printf("mflo $s0\n");
			}else if(op == DIVIDES){
				printf("div $s0, $t1\n");
				printf("mflo $s0\n");
			}else if(op == MOD){
				printf("div $s0, $t1\n");
				printf("mfhi $s0\n");
			}else if(op == EQUALS){
				printf("beq $s0, $t1, A%d\n", label);
				printf("li $s0, 0\n");
				printf("b FIM_A%d\n", label);
				printf("A%d:\n", label);
				printf("li $s0, 1\n");
				printf("FIM_A%d:\n", label);
				label++;
			}
			
		}
};

class UnaryExpr : public Expr {
	protected:
		UnOp op;
	public:
		void run(DataType &dt) {
			for (size_t i = 0; i < child.size(); i++){
				static_cast< Expr* >(child[i])->run(dt);	
			} 

			this->exp_tp = dt;
		}

		UnaryExpr(ASTNode* expr, UnOp opt = NOTHING) : Expr(INT_T){
			this->op = opt;
		
			this->add(expr);
		}
};	

class ConstExpr : public Expr {
	protected:
		std::string* value;
	public:
		void run(DataType &dt) { 
			dt = this->exp_tp;

			// std::cout << "rodando const expr tem tipo " << dt << "\n";
			// std::cout << "const expr com tipo" << dt << "\n";
		}

		void generate_code(){
			if(this->exp_tp == INT_T)
				printf("li $s0, %d\n", this->getIntVal());
			else if(this->exp_tp == CHAR_T){
				printf("li $0, %s\n", this->value->c_str());
			}
		}

		ConstExpr(DataType dt, std::string* val) : Expr(dt){
			// std::cout << *val << " criada!\n";
			this->value = val;
			// std::cout << dt << " eh o tipo const expr\n"; 
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
		void run(DataType &dt) {
			// printf("chamei uma funcao!\n");
			// std::cout << *func_id << "\n";
			dt = INT_T;

			if(func_symbol_tab.count(*func_id) == 0){
				std::string error = "A função " + *func_id + " nao foi previamente declarada.";
				yyerror(error.c_str(), node_location);
			}

			FuncDecl *func = func_symbol_tab[*func_id];
			FuncBody *body = func->get_func_body();
			FuncParametro *params = body->get_params();

			if(this->child[0] == NULL && params != NULL){
				std::string error = "A função " + *func_id + " nao aceita ser chamada sem parametros.";
				yyerror(error.c_str(), node_location);
			}

			if(this->child[0] != NULL && params == NULL){
				std::string error = "A função " + *func_id + " nao aceita ser chamada com parametros.";
				yyerror(error.c_str(), node_location);
			}

			std::vector< ASTNode* > args;

			if(this->child[0] != NULL){
				args = this->child[0]->get_child();
			}

			std::vector< FuncParametro* > param_list;

			if(params != NULL){
				params->get_params(param_list);
			}

			// printf("|params| = %lu\n", param_list.size());

			if(args.size() != param_list.size()){
				std::string error = "Numero de parametros para a função " + *func_id + " incorretos";
				yyerror(error.c_str(), node_location);
			}

			for(int i = 0 ; i < args.size() ; i++){
				Expr *r = (Expr*) args[i];
				FuncParametro *e = param_list[i];
				DataType mdt;

				r->run(mdt);

				if(mdt != e->dt){
					std::string error = "Tipos para argumentos da funcao " + *func_id + " incorretos";
					yyerror(error.c_str(), node_location);
				}
			}
		}

		void generate_code(){
			FuncDecl *func = func_symbol_tab[*func_id];
			FuncBody *body = func->get_func_body();
			FuncParametro *params = body->get_params();

			std::vector< ASTNode* > args;

			if(this->child[0] != NULL){
				args = this->child[0]->get_child();
			}

			std::vector< FuncParametro* > param_list;

			if(params != NULL){
				params->get_params(param_list);
			}

			for(int i = int(args.size()) - 1 ; i >= 0 ; i--){
				Expr *r = (Expr*) args[i];
				int sz = 1;

				r->generate_code();

				if(r->exp_tp != CHAR_T && r->exp_tp != INT_T){
					sz = SIZE_ARRAY;
				}

				Helper::empilha_s0(sz);
			}

			printf("jal %s\n", func_id->c_str());
		}

		FuncCall(std::string* func_nm, ASTNode* args = NULL) : Expr(INT_T){
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

		void generate_code(){
			printf("li $v0, 5\n");
			printf("syscall\n");

			int d = Helper::get_deslocamento(var_id);

			printf("sw $v0, %d($s1)\n", -4 * d);
		}
};

class Escreva : public Expr {
	public:
		int type;

		Escreva(){}

		Escreva(ASTNode *expr, int tp = 0){
			this->add(expr);
			type = tp;
		}

		void run(DataType &dt) {
			for (size_t i = 0; i < child.size(); i++) static_cast< Expr* >(child[i])->run(dt);
		}

		void generate_code(){
			for(int i = 0 ; i < child.size() ; i++){
				this->child[i]->generate_code();
			}

			ConstExpr *exp = static_cast< ConstExpr* > (this->child[0]);

			std::string st = exp->getStringVal();
			char str[100];

			for(int i = 0 ; i < st.length() ; i++){
				str[i] = st[i];
			}

			str[st.length()] = 0;

			// std::cout << "======= " << exp->getStringVal() << " " << (exp->getStringVal()).length() << "\n";

			if(exp->get_type() == CHAR_ARRAY_T){
				printf(".data\n");
				printf("\tstr%d: .asciiz \"%s\"\n.text\n", st_num, str);
				printf("li $v0, 4\n");
				printf("la $a0, str%d\n", st_num);
				printf("syscall\n");
			}else{
				printf("li $v0, 1\n");
				printf("addiu $a0, $s0, 0\n");
				printf("syscall\n");
			}

			st_num++;
		}
};

class Return : public Expr {
	protected:
		DataType rtype;
		Expr* rval;
	public:
		Return(ASTNode* expr) : rval(static_cast< Expr* >(expr)), Expr(INT_T) {}

		DataType getReturnType() { return this->rtype; }

		void run(DataType &dt) {
			rval->run(dt);

			// printf("xxxx == = %d %d\n", inside_func, func_ttp);

			if(!func_ttp.empty() && dt != func_ttp.top()){
				std::string error = "A funcao possui um retorno com tipo diferente da declaracao";
				yyerror(error.c_str(), node_location);
			}

			rtype = dt;
		}

		void generate_code(){
			rval->generate_code();

			//voltar pilha...
			printf("lw $ra, 0($fp)\n");
			printf("move $sp, $fp\n");
			printf("addiu $sp, $sp, %d\n", (Helper::get_size_params() + 1 + 1) * 4);
			printf("move $fp, $sp\n");//deslocando a pilha da forma certa
			printf("addiu $sp, $sp, -8\n");
			printf("jr $ra\n");
		}
};

class ListaCmd : public ASTNode{
	public:
		void run(){
			for(int i = 0 ; i < child.size() ; i++){
				DataType test;

				child[i]->run(test);
			}
		}

		void run(DataType &dt){
			// printf("aqui!\n");

			for(int i = 0 ; i < child.size() ; i++){
				DataType test;

				child[i]->run(test);
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