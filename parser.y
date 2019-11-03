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
	int *lex;
	ASTNode* node;
}

%token <token> ID TIPO INTCONST carconst cadeiaCaracteres SE SENAO LEIA ESCREVA NOVALINHA ENTAO OR EQUAL DIF GEQ LEQ EXECUTE ENQUANTO RETURN PROGRAMA STRING

%type <node> DeclProg DeclFuncVar DeclVar Programa Bloco

%start Programa

%%

Programa :		DeclFuncVar DeclProg 
				{
					root = $1;
					root->add($2);
				}
				;

DeclFuncVar :	TIPO ID DeclVar ';' DeclFuncVar {}
				| TIPO ID '['INTCONST']' DeclVar ';' DeclFuncVar {}
				| TIPO ID DeclFunc DeclFuncVar {}
				| %empty {}
				;

DeclProg :		PROGRAMA Bloco {}
				;

DeclVar :		',' ID DeclVar {}
				| ',' ID'['INTCONST']' DeclVar {}
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