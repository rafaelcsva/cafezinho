%{
	#include <cstdio>
	#include <iostream>
	#include <string>

	extern int yylex();
    void yyerror(const char *s) { printf("ERROR: %sn", s); }	
%}

%union {
	int *a;
}

%token <token> ID TIPO INTCONST carconst intconst cadeiaCaracteres

%type <block> Programa Bloco
%type <stmt> DeclProg DeclVar DeclFuncVar

%start Programa

%%

Programa :		DeclFuncVar DeclProg {}
				;

DeclFuncVar : 	TIPO ID DeclVar';' DeclFuncVar {}
				| {}
				;

DeclVar :		',' ID DeclVar {}
				|',' ID '['INTCONST']' DeclVar';' DeclFuncVar {}
				|TIPO ID DeclFunc DeclFuncVar {}
				| {}
				;

DeclProg :		"programa" Bloco {}
				;

DeclVar :		','ID DeclVar {}
				|','ID '['INTCONST']' DeclVar {}
				| {}
				;

DeclFunc :		'('ListaParametros')' Bloco {}
				;

ListaParametros :	{}
					|ListaParametrosCont {}
					;

ListaParametrosCont :	TIPO ID {}
						|TIPO ID '['']' {}
						|TIPO ID',' ListaParametrosCont {}
						|TIPO ID'['']'',' ListaParametrosCont {}
						;

Bloco :			'{'ListaDeclVar ListaComando'}' {}
				|'{'ListaDeclVar'}' {}
				;

ListaDeclVar :	{}
				|TIPO ID DeclVar';'ListaDeclVar {}
				|TIPO ID '['INTCONST']' DeclVar';' ListaDeclVar {}
				;

ListaComando :	Comando {}
				|Comando ListaComando {}
				;

Comando :		';' {}
				|Expr ';' {}
				|"retorne" Expr ';' {}
				|"leia" LValueExpr ';' {}
				|"escreva" Expr ';' {}
				|"escreva" cadeiaCaracteres ';' {}
				|"\n" {}
				|"se" '(' Expr ')' "entao" Comando {}
				|"se" '(' Expr ')' "entao" Comando "senao" Comando {}
				|"enquanto" '(' Expr ')' "execute" Comando {}
				|Bloco {}
				;

Expr :			AssignExpr {}
				;

AssignExpr :	CondExpr {}
				|LValueExpr'='AssignExpr {}
				;

CondExpr :		OrExpr {}
				|OrExpr '?' Expr ':' CondExpr {}
				;

OrExpr :		OrExpr "ou" AndExpr {}
				|AndExpr {}
				;

AndExpr	:		AndExpr "e" EqExpr {}
				|EqExpr {}
				;

EqExpr :		EqExpr "==" DesigExpr {}
				|EqExpr "!=" DesigExpr {}
				|DesigExpr {}
				;

DesigExpr : 	DesigExpr '<' AddExpr {}
				|DesigExpr '>' AddExpr {}
				|DesigExpr ">=" AddExpr {}
				|DesigExpr "<=" AddExpr {}
				|AddExpr {}
				;

AddExpr :		AddExpr '+' MulExpr {}
				|AddExpr '-' MulExpr {}
				|MulExpr {}
				;

MulExpr :		MulExpr '*' UnExpr {}
				|MulExpr '/' UnExpr {}
				|MulExpr '%' UnExpr {}
				|UnExpr {}
				;

UnExpr :		'-'PrimExpr {}
				|'!'PrimExpr {}
				|PrimExpr {}
				;

LValueExpr :	ID '[' Expr ']' {}
				|ID {}
				;

PrimExpr :		ID '(' ListExpr ')' {}
				|ID '(' ')' {}
				|ID '['Expr']' {}
				|ID {}
				|carconst {}
				|intconst {}
				|'(' Expr ')' {}
				;

ListExpr :		AssignExpr {}
				|ListExpr ',' AssignExpr {}
				;

%%