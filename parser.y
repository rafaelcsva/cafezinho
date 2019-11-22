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
					root = $1;
					root->add($2);
				}
				;

DeclFuncVar :	TIPO ID DeclVar ';' DeclFuncVar {
					$$ = new DeclVar();
					static_cast< DeclVar* >($$)->setDataType($2);

					static_cast< DeclVar* >($$)->setDataType($2);
					$3->add_back(new DeclId($2));
					$$->add($3);

					if($5 != NULL){
						$$->add($5);
					}

					$$->set_location(yylineno);
				}
				| TIPO ID '['INTCONST']' DeclVar ';' DeclFuncVar {
					$$ = new DeclVar();
					static_cast< DeclVar* >($$)->setDataType($1);
					$6->add_back(new DeclId($2, $4));
					$$->add($6);

					if($8 != NULL){
						$$->add($8);
					}

					$$->set_location(yylineno);
				}
				| TIPO ID DeclFunc DeclFuncVar {
					$$ = new FuncDecl($1, $2);
					if($4 != NULL)
						$$->add($4);

					$$->set_location(yylineno);
				}
				| %empty { $$ = NULL;}
				;

DeclProg :		PROGRAMA Bloco {
					$$ = $2;
				}
				;

DeclVar :		',' ID DeclVar {
					if($3 != NULL){
						$$ = $3;
					}else{
						$$ = new ASTNode();
					}

					$$->add_back(new DeclId($2));

					$$->set_location(yylineno);
				}
				| ',' ID'['INTCONST']' DeclVar {
					if($6 != NULL){
						$$ = $6;
					}else{
						$$ = new ASTNode();
					}

					$$->add_back(new DeclId($2, $4));
					
					$$->set_location(yylineno);
				}
				| %empty { 
					$$ = NULL;
				}
				;

DeclFunc :		'('ListaParametros')' Bloco {
					if($2 != NULL){
						$$ = $2;
					}else{
						$$ = new DeclVar();
					}

					$$->add($4);

					$$->set_location(yylineno);
				}
				;

ListaParametros :	%empty { $$ = NULL; }
					| ListaParametrosCont {
						if($1 != NULL){
							$$ = $1;
						}else{
							$$ = new DeclVar();
						}

						$$->set_location(yylineno);
					}
					;

ListaParametrosCont :	TIPO ID {
							$$ = new DeclVar();
							static_cast< DeclVar* >($$)->setDataType($1);
							static_cast< DeclVar* >($$)->add(new DeclId($2));

							$$->set_location(yylineno);
						}
						| TIPO ID '['']' {
							$$ = new DeclVar();
							static_cast< DeclVar* >($$)->setDataType($1);
							static_cast< DeclVar* >($$)->add(new DeclId($2, 0));

							$$->set_location(yylineno);
						}
						| TIPO ID',' ListaParametrosCont {
							$$ = new DeclVar();
							static_cast< DeclVar* >($$)->setDataType($1);
							static_cast< DeclVar* >($$)->add(new DeclId($2));

							$$->add($4);

							$$->set_location(yylineno);
						}
						| TIPO ID'['']'',' ListaParametrosCont {
							$$ = new DeclVar();
							static_cast< DeclVar* >($$)->setDataType($1);
							static_cast< DeclVar* >($$)->add(new DeclId($2, 0));

							$$->add($6);

							$$->set_location(yylineno);
						}
						;

Bloco :			'{'ListaDeclVar ListaComando'}' {
					if($2 != NULL){
						$$ = $2;
					}else{
						$$ = new Cmd();
					}

					$$->add($3);

					$$->set_location(yylineno);
				}
				| '{'ListaDeclVar'}' {
					if($2 != NULL){
						$$ = $2;
					}else{
						$$ = new Cmd();
					}

					$$->set_location(yylineno);
				}
				;

ListaDeclVar :	%empty { $$ = NULL; }
				| TIPO ID DeclVar';'ListaDeclVar { 
					$$ = new DeclVar();
					static_cast< DeclVar* >($$)->setDataType($1);
					static_cast< DeclVar* >($$)->add(new DeclId($2));

					$$->add($3);
					$$->add($5);

					$$->set_location(yylineno);
				}
				| TIPO ID'['INTCONST']' DeclVar';' ListaDeclVar {
					$$ = new DeclVar();
					static_cast< DeclVar* >($$)->setDataType($1);

					$$->add(new DeclId($2, $4));
					$$->add($6);

					if($8 != NULL)
						$$->add($8);

					$$->set_location(yylineno);
				}
				;

ListaComando :	Comando {
					$$ = $1;
				}
				| Comando ListaComando {
					if($2 != NULL){
						$$ = $2;
					}else{
						$$ = new Cmd();
					}

					$$->add_back($1);
				}
				;

Comando :		';' { $$ = NULL; }
				| Expr ';' {
					if($1 != NULL){
						$$ = $1;
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
					if($1 != NULL){
						$$ = $1;
						$$->set_location(yylineno);
					}
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
					$$ = new AssignExpr($1, $3);
					$$->set_location(yylineno);
				}
				;

CondExpr :		OrExpr {
					$$ = $1;
					$$->set_location(yylineno);
				}
				| OrExpr '?' Expr ':' CondExpr {
					$$ = new TernExpr($1, $3, $5);
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
					$$ = new UnaryExpr($1);
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

void yyerror(const char *s) {
	fprintf(stderr, "ERRO! Linha: %d - %s\n", yylineno, s );
	exit(1);
}

int main(){

	yyparse();

	return 0;
}