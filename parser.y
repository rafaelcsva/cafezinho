%{
	#include <cstdio>
	#include <iostream>
	#include <string>

	extern int yylex();
    void yyerror(const char *s) { printf("ERROR: %s\n", s); }	
%}

%union {
	int *a;
}

%token <token> ID TIPO INTCONST carconst intconst cadeiaCaracteres

%type <block> Programa Bloco
%type <stmt> DeclProg DeclFuncVar DeclVar

%start Programa

%%

Programa :		DeclFuncVar DeclProg {printf("1\n");}
				;

DeclFuncVar :	TIPO ID DeclVar ';' DeclFuncVar {printf("2\n");}
				|TIPO ID '[' INTCONST ']' DeclVar ';' DeclFuncVar {printf("3\n");}
				|TIPO ID DeclFunc DeclFuncVar {printf("4\n");}
				| {printf("5\n");}
				;

DeclProg :		"programa" Bloco {printf("6\n");}
				;

DeclVar :		',' ID DeclVar {printf("7\n");}
				|',' ID'['INTCONST']' DeclVar {printf("8\n");}
				| {printf("9\n");}
				;

DeclFunc :		'('ListaParametros')' Bloco {printf("10\n");}
				;

ListaParametros :	{printf("11\n");}
					|ListaParametrosCont {printf("12\n");}
					;

ListaParametrosCont :	TIPO ID {printf("13\n");}
						|TIPO ID '['']' {printf("14\n");}
						|TIPO ID',' ListaParametrosCont {}
						|TIPO ID'['']'',' ListaParametrosCont {}
						;

Bloco :			'{'ListaDeclVar ListaComando'}' {}
				|'{'ListaDeclVar'}' {}
				;

ListaDeclVar :	{}
				|TIPO ID DeclVar';'ListaDeclVar {}
				|TIPO ID'['INTCONST']' DeclVar';' ListaDeclVar {}
				;

ListaComando :	Comando {}
				|Comando ListaComando {}
				;

Comando :		';' {}
				|Expr ';' {}
				|"retorne" Expr';' {}
				|"leia" LValueExpr';' {}
				|"escreva" Expr';' {}
				|"escreva" cadeiaCaracteres';' {}
				|"\n" {}
				|"se" '('Expr')' "entao" Comando {}
				|"se" '('Expr')' "entao" Comando "senao" Comando {}
				|"enquanto" '('Expr')' "execute" Comando {}
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

LValueExpr :	ID'['Expr']' {}
				|ID {}
				;

PrimExpr :		ID '('ListExpr')' {}
				|ID '(' ')' {}
				|ID '['Expr']' {}
				|ID {}
				|carconst {}
				|intconst {}
				|'('Expr')' {}
				;

ListExpr :		AssignExpr {}
				|ListExpr ',' AssignExpr {}
				;

%%