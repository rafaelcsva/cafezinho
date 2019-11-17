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

%token <tval> ID TIPO INTCONST carconst cadeiaCaracteres SE SENAO LEIA ESCREVA NOVALINHA ENTAO OR EQUAL DIF GEQ LEQ EXECUTE ENQUANTO RETURN PROGRAMA STRING

%type <node> DeclProg Programa Bloco
%type <decId> DeclVar
%type <decVar> DeclFuncVar

%start Programa

%%

Programa :		DeclFuncVar DeclProg 
				{
					root = $1;
					root->add($2);
				}
				;

DeclFuncVar :	TIPO ID DeclVar ';' DeclFuncVar {
					$$->setDataType($2);
					$3->add_back(new DeclId($2));
					$$->add($3);

					if($5 != NULL){
						$$->add($5);
					}

					$$->set_location(yylineno);
				}
				| TIPO ID '['INTCONST']' DeclVar ';' DeclFuncVar {
					$$->setDataType($1);
					$6->add_back(new DeclId($2, $4));
					$$->add($6);

					if($8 != NULL){
						$$->add($8);
					}

					$$->set_location(yylineno);
				}
				| TIPO ID DeclFunc DeclFuncVar {
					
				}
				| %empty { $$ = NULL;}
				;

DeclProg :		PROGRAMA Bloco {}
				;

DeclVar :		',' ID DeclVar {
					$$ = $3;
					$$->add_back(new DeclId($2));
					$$->set_location(yylineno);
				}
				| ',' ID'['INTCONST']' DeclVar {
					$$ = $6;
					$$->add_back(new DeclId($2, $4));
					$$->set_location(yylineno);
				}
				| %empty {}
				;

DeclFunc :		'('ListaParametros')' Bloco {}
				;

ListaParametros :	%empty {printf("11\n");}
					| ListaParametrosCont {}
					;

ListaParametrosCont :	TIPO ID {}
						| TIPO ID '['']' {}
						| TIPO ID',' ListaParametrosCont {}
						| TIPO ID'['']'',' ListaParametrosCont {}
						;

Bloco :			'{'ListaDeclVar ListaComando'}' {}
				| '{'ListaDeclVar'}' {}
				;

ListaDeclVar :	%empty {}
				| TIPO ID DeclVar';'ListaDeclVar {}
				| TIPO ID'['INTCONST']' DeclVar';' ListaDeclVar {}
				;

ListaComando :	Comando {}
				| Comando ListaComando {}
				;

Comando :		';' {}
				| Expr ';' {}
				| RETURN Expr';' {}
				| LEIA LValueExpr';' {}
				| ESCREVA Expr';' {}
				| ESCREVA STRING';' {}
				| NOVALINHA ';' {}
				| SE '(' Expr ')' ENTAO Comando {}
				| SE '(' Expr ')' ENTAO Comando SENAO Comando {}
				| ENQUANTO '('Expr')' EXECUTE Comando {}
				| Bloco {}
				;

Expr :			AssignExpr {}
				;

AssignExpr :	CondExpr {}
				| LValueExpr'='AssignExpr {}
				;

CondExpr :		OrExpr {}
				| OrExpr '?' Expr ':' CondExpr {}
				;

OrExpr :		OrExpr OR AndExpr {}
				| AndExpr {}
				;

AndExpr	:		AndExpr "e" EqExpr {}
				| EqExpr {}
				;

EqExpr :		EqExpr EQUAL DesigExpr {}
				| EqExpr DIF DesigExpr {}
				| DesigExpr {}
				;

DesigExpr : 	DesigExpr '<' AddExpr {}
				| DesigExpr '>' AddExpr {}
				| DesigExpr GEQ AddExpr {}
				| DesigExpr LEQ AddExpr {}
				| AddExpr {}
				;

AddExpr :		AddExpr '+' MulExpr {}
				| AddExpr '-' MulExpr {}
				| MulExpr {}
				;

MulExpr :		MulExpr '*' UnExpr {}
				| MulExpr '/' UnExpr {}
				| MulExpr '%' UnExpr {}
				| UnExpr {}
				;

UnExpr :		'-'PrimExpr {}
				| '!'PrimExpr {}
				| PrimExpr {}
				;

LValueExpr :	ID'['Expr']' {}
				| ID {}
				;

PrimExpr :		ID '('ListExpr')' {}
				| ID '('')' {}
				| ID '['Expr']' {}
				| ID {}
				| '('Expr')' {}
				| INTCONST
				;

ListExpr :		AssignExpr {}
				| ListExpr ',' AssignExpr {}
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