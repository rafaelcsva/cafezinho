%{

	#include <cstdio>
	#include <iostream>
	#include <string>
	#include "ast/ast.h"

	extern int yylineno;
	extern int yylex();
	void yyerror(const char* s);

	ASTNode* root;
%}

%union {
	ASTNode* node;
	std::string *tval;
	DeclId* decId;
	DeclVar* decVar;
}

%token <tval> ID TIPO INTCONST carconst cadeiaCaracteres SE SENAO LEIA ESCREVA NOVALINHA ENTAO OR EQUAL DIF GEQ LEQ EXECUTE ENQUANTO RETURN PROGRAMA STRING LITCHAR

%type <node> DeclProg Programa DeclFuncVar DeclFunc ListaParametros ListaParametrosCont Bloco ListaDeclVar ListaComando Comando Expr AssignExpr CondExpr OrExpr AndExpr
%type <node> LValueExpr EqExpr DesigExpr AddExpr MulExpr UnExpr PrimExpr ListExpr DeclVar

%start Programa

%%

Programa :		DeclFuncVar DeclProg 
				{
					if($1 != NULL)
						$1->run();

					if($2 != NULL){
						scope_lvl = 1;

						$2->run();

						var_symbol_tab.clear();
						func_symbol_tab.clear();
						
						escopo[1] = 0;
						
						if($1 != NULL){
							scope_lvl = 0;
							$1->generate_code();
						}

						scope_lvl = 1;

						printf("MAIN:\n");
						$2->generate_code();
					}
				}
				;

DeclFuncVar :	TIPO ID DeclVar ';' DeclFuncVar {
					$$ = new ListaDeclVar();

					static_cast< ListaDeclVar* >($$)->set_type($1);

					DeclId* a = new DeclId($2);
					a->set_location(yylineno);
					
					if($3 != NULL){
						a->add($3);
					}				

					std::vector< ASTNode* > childs;

					a->get_ids(childs);

					for(int i = 0 ; i < childs.size() ; i++){
						static_cast< ListaDeclVar* >($$)->add_var(static_cast< DeclId* >(childs[i]));
					}

					if($5 != NULL)
						$$->add($5);

					$$->set_location(yylineno);
				}
				| TIPO ID '['INTCONST']' DeclVar ';' DeclFuncVar {
					$$ = new ListaDeclVar();

					static_cast< ListaDeclVar* >($$)->set_type($1);
					
					DeclId* a = new DeclId($2, $4);
					a->set_location(yylineno);

					if($6 != NULL){
						a->add($6);
					}

					std::vector< ASTNode* > childs;
					a->get_ids(childs);

					for(int i = 0 ; i < childs.size() ; i++){
						static_cast< ListaDeclVar* >($$)->add_var(static_cast< DeclId* >(childs[i]));
					}

					if($8 != NULL)
						$$->add($8);

					$$->set_location(yylineno);
				}
				| TIPO ID DeclFunc DeclFuncVar {
					$$ = new ASTNode();
					FuncDecl *f = new FuncDecl($1, $2);
					f->add($3);

					$$->add(f);

					if($4 != NULL){	
						$$->add($4);
					}

					$$->set_location(yylineno);
				}
				| %empty { $$ = NULL;}
				;

DeclProg :		PROGRAMA Bloco {
					$$ = $2;
				}
				;

DeclVar :		',' ID DeclVar {
					$$ = new DeclId($2);

					if($3 != NULL){
						$$->add($3);
					}

					$$->set_location(yylineno);
				}
				| ',' ID'['INTCONST']' DeclVar {
					$$ = new DeclId($2, $4);
					
					if($6 != NULL){
						$$->add($6);
					}

					$$->set_location(yylineno);
				}
				| %empty { 
					$$ = NULL;
				}
				;

DeclFunc :		'('ListaParametros')' Bloco {
					$$ = new FuncBody($2, $4);

					$$->set_location(yylineno);
				}
				;

ListaParametros :	%empty { $$ = NULL; }
					| ListaParametrosCont {
						if($1 != NULL){
							$$ = $1;
						}else{
							$$ = NULL;
						}

						$$->set_location(yylineno);
					}
					;

ListaParametrosCont :	TIPO ID {
							$$ = new FuncParametro();
							static_cast< FuncParametro* >($$)->setDataType($1);
							static_cast< FuncParametro* >($$)->setName($2);

							$$->set_location(yylineno);
						}
						| TIPO ID'['']' {
							$$ = new FuncParametro();
							static_cast< FuncParametro* >($$)->setDataType($1);
							static_cast< FuncParametro* >($$)->setName($2);

							$$->set_location(yylineno);
						}
						| TIPO ID','ListaParametrosCont {
							
							$$ = new FuncParametro();
							static_cast< FuncParametro* >($$)->setDataType($1);
							static_cast< FuncParametro* >($$)->setName($2);

							$$->add($4);

							$$->set_location(yylineno);
						}
						| TIPO ID'['']'',' ListaParametrosCont {
							$$ = new FuncParametro();
							static_cast< FuncParametro* >($$)->setDataType($1, true);
							static_cast< FuncParametro* >($$)->setName($2);

							$$->add($6);

							$$->set_location(yylineno);
						}
						;

Bloco :			'{'ListaDeclVar ListaComando'}' {
					$$ = new Bloco();
					
					if($2 != NULL)
						$$->add($2);
					
					if($3 != NULL)
						$$->add($3);

					$$->set_location(yylineno);
				}
				| '{'ListaDeclVar'}' {
					$$ = new Bloco();

					if($2 != NULL)
						$$->add($2);

					$$->set_location(yylineno);
				}
				;

ListaDeclVar :	%empty { $$ = NULL; }
				| TIPO ID DeclVar';'ListaDeclVar { 
					$$ = new ListaDeclVar();

					static_cast< ListaDeclVar* >($$)->set_type($1);

					DeclId* a = new DeclId($2);
					a->set_location(yylineno);
					
					if($3 != NULL){
						a->add($3);
					}				

					std::vector< ASTNode* > childs;

					a->get_ids(childs);
						
					for(int i = 0 ; i < childs.size() ; i++){
						static_cast< ListaDeclVar* >($$)->add_var(static_cast< DeclId* >(childs[i]));
					}

					if($5 != NULL)
						$$->add($5);

					$$->set_location(yylineno);
				}
				| TIPO ID'['INTCONST']' DeclVar';' ListaDeclVar {
					$$ = new ListaDeclVar();

					static_cast< ListaDeclVar* >($$)->set_type($1);
					
					DeclId* a = new DeclId($2, $4);
					a->set_location(yylineno);

					if($6 != NULL){
						a->add($6);
					}

					std::vector< ASTNode* > childs;
					a->get_ids(childs);

					for(int i = 0 ; i < childs.size() ; i++){
						static_cast< ListaDeclVar* >($$)->add_var(static_cast< DeclId* >(childs[i]));
					}

					if($8 != NULL)
						$$->add($8);

					$$->set_location(yylineno);
				}
				;

ListaComando :	Comando {
					$$ = new ListaCmd();
					$$->add($1);
				}
				| Comando ListaComando {
					if($2 != NULL){
						$$ = $2;
					}else{
						$$ = new ListaCmd();
					}

					$$->add_back($1);
				}
				;

Comando :		';' {$$ = NULL; }
				| Expr ';' {
					if($1 != NULL){
						$$ = static_cast< AssignExpr* >($1);
						$$->set_location(yylineno);
					}
				}
				| RETURN Expr';' {
					$$ = new Return($2);
					$$->set_location(yylineno);
				}
				| LEIA LValueExpr';' {
					$$ = new Leia(dynamic_cast<Identifier*>($2));

					$$->set_location(yylineno);
				}
				| ESCREVA Expr';' {
					$$ = new Escreva($2);
					
					$$->set_location(yylineno);
				}
				| ESCREVA STRING';' {
					$$ = new Escreva(new ConstExpr(CHAR_ARRAY_T, $2));
					
					$$->set_location(yylineno);
				}
				| NOVALINHA ';' {
					std::string nline = "\n";

					$$ = new Escreva(new ConstExpr(CHAR_ARRAY_T, &nline));
				}
				| SE '(' Expr ')' ENTAO Comando { 
					$$ = new Se($3, $6);
					$$->set_location(yylineno);
				}
				| SE '(' Expr ')' ENTAO Comando SENAO Comando { 
					$$ = new Se($3, $6, $8);
					$$->set_location(yylineno);
				}
				| ENQUANTO '('Expr')' EXECUTE Comando {
					$$ = new Enquanto($3, $6);
					$$->set_location(yylineno);
				}
				| Bloco {
					$$ = $1;
					$$->set_location(yylineno);
				}
				;

Expr :			AssignExpr { 
					$$ = $1;
					$$->set_location(yylineno);
				}
				;

AssignExpr :	CondExpr {
					$$ = $1;
					$$->set_location(yylineno);
				}
				| LValueExpr'='AssignExpr {
					$$ = new AssignExpr($1, static_cast< Expr* >($3));

					$$->set_location(yylineno);
				}
				;

CondExpr :		OrExpr {
					$$ = $1;
					$$->set_location(yylineno);
				}
				| OrExpr '?' Expr ':' CondExpr {
					$$ = new TernExpr(static_cast< Expr* >($1), static_cast< Expr* >($3), static_cast< Expr* >($5));
					$$->set_location(yylineno);
				}
				;

OrExpr :		OrExpr OR AndExpr {
					$$ = new BinaryExpr(LOGICAL_OR, $1, $3);
					$$->set_location(yylineno);
				}
				| AndExpr {
					$$ = $1;
					$$->set_location(yylineno);
				}
				;

AndExpr	:		AndExpr "e" EqExpr {
					$$ = new BinaryExpr(LOGICAL_AND, $1, $3);
					$$->set_location(yylineno);
				}
				| EqExpr {
					$$ = $1;
					$$->set_location(yylineno);
				}
				;

EqExpr :		EqExpr EQUAL DesigExpr {
					$$ = new BinaryExpr(EQUALS, $1, $3);
					$$->set_location(yylineno);
				}
				| EqExpr DIF DesigExpr {
					$$ = new BinaryExpr(NOT_EQUAL, $1, $3);
					$$->set_location(yylineno);
				}
				| DesigExpr {
					$$ = $1;
					$$->set_location(yylineno);
				}
				;

DesigExpr : 	DesigExpr '<' AddExpr {
					$$ = new BinaryExpr(LESS, $1, $3);
					$$->set_location(yylineno);
				}
				| DesigExpr '>' AddExpr {
					$$ = new BinaryExpr(GREATER, $1, $3);
					$$->set_location(yylineno);
				}
				| DesigExpr GEQ AddExpr {
					$$ = new BinaryExpr(GREATER_EQUAL, $1, $3);
					$$->set_location(yylineno);
				}
				| DesigExpr LEQ AddExpr {
					$$ = new BinaryExpr(LESS_EQUAL, $1, $3);
					$$->set_location(yylineno);
				}
				| AddExpr {
					$$ = $1;
					$$->set_location(yylineno);
				}
				;

AddExpr :		AddExpr '+' MulExpr {
					$$ = new BinaryExpr(PLUS, $1, $3);
					$$->set_location(yylineno);
				}
				| AddExpr '-' MulExpr {
					$$ = new BinaryExpr(MINUS, $1, $3);
					$$->set_location(yylineno);
				}
				| MulExpr {
					$$ = $1;
					$$->set_location(yylineno);
				}
				;

MulExpr :		MulExpr '*' UnExpr {
					$$ = new BinaryExpr(TIMES, $1, $3);
					$$->set_location(yylineno);
				}
				| MulExpr '/' UnExpr {
					$$ = new BinaryExpr(DIVIDES, $1, $3);
					$$->set_location(yylineno);
				}
				| MulExpr '%' UnExpr {
					$$ = new BinaryExpr(MOD, $1, $3);
					$$->set_location(yylineno);
				}
				| UnExpr {
					$$ = $1;
					$$->set_location(yylineno);
				}
				;

UnExpr :		'-'PrimExpr {
					$$ = new UnaryExpr($2, NEG);
					$$->set_location(yylineno);
				}
				| '!'PrimExpr {
					$$ = new UnaryExpr($2, INV);
					$$->set_location(yylineno);
				}
				| PrimExpr {
					$$ = $1;
					$$->set_location(yylineno);
				}
				;

LValueExpr :	ID'['Expr']' {
					$$ = new Identifier($1, $3);
					$$->set_location(yylineno);
				}
				| ID {
					$$ = new Identifier($1);
					$$->set_location(yylineno);
				}
				;

PrimExpr :		ID '('ListExpr')' {
					$$ = new FuncCall($1, $3);
					$$->set_location(yylineno);	
				}
				| ID '('')' {
					$$ = new FuncCall($1);
					
					$$->set_location(yylineno);
				}
				| ID '['Expr']' {
					$$ = new Identifier($1, $3);

					$$->set_location(yylineno);
				}
				| ID {
					$$ = new Identifier($1);

					$$->set_location(yylineno);
				}
				| '('Expr')' { 
					$$ = $2;

					$$->set_location(yylineno);
				}
				| INTCONST {
					$$ = new ConstExpr(INT_T, $1);

					$$->set_location(yylineno);
				}
				| LITCHAR {
					$$ = new ConstExpr(CHAR_T, $1);

					$$->set_location(yylineno);
				}
				;

ListExpr :		AssignExpr {
					$$ = new ArgList();
					$$->add($1);
					
					$$->set_location(yylineno);
				}
				| ListExpr ',' AssignExpr {
					$$ = $1;
					$$->add($3);

					$$->set_location(yylineno);
				}
				;
%%

void yyerror(const char *s, int err_line ) {
	fprintf(stderr, "ERRO! Proximo a linha: %d - %s\n", err_line, s );
	exit(1);
}

void yyerror(const char *s) {
	fprintf(stderr, "ERRO! Linha: %d - %s\n", yylineno, s );
	exit(1);
}

int main(){

	yyparse();

	return 0;
}