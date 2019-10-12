%{
	#include <cstdio>
	#include <iostream>
	#include <string>
	#include "cafezinho.h"

	extern int yylineno;
	extern int yylex();
	void yyerror(const char* s);
%}

%union {
	int *lex;
}

%token <token> ID TIPO INTCONST carconst cadeiaCaracteres SE SENAO LEIA ESCREVA NOVALINHA ENTAO OR EQUAL DIF GEQ LEQ EXECUTE ENQUANTO RETURN PROGRAMA STRING

%type <lex> DeclProg DeclFuncVar DeclVar Programa Bloco

%start Programa

%%

Programa :		DeclFuncVar DeclProg {printf("1\n");}
				;

DeclFuncVar :	TIPO ID DeclVar ';' DeclFuncVar {printf("2\n");}
				| TIPO ID '['INTCONST']' DeclVar ';' DeclFuncVar {printf("3\n");}
				| TIPO ID DeclFunc DeclFuncVar {printf("4\n");}
				| %empty {printf("5\n");}
				;

DeclProg :		PROGRAMA Bloco {printf("6\n");}
				;

DeclVar :		',' ID DeclVar {printf("7\n");}
				| ',' ID'['INTCONST']' DeclVar {printf("8\n");}
				| %empty {printf("9\n");}
				;

DeclFunc :		'('ListaParametros')' Bloco {printf("10\n");}
				;

ListaParametros :	%empty {printf("11\n");}
					| ListaParametrosCont {printf("12\n");}
					;

ListaParametrosCont :	TIPO ID {printf("13\n");}
						| TIPO ID '['']' {printf("14\n");}
						| TIPO ID',' ListaParametrosCont {printf("15\n");}
						| TIPO ID'['']'',' ListaParametrosCont {printf("16\n");}
						;

Bloco :			'{'ListaDeclVar ListaComando'}' {printf("17\n");}
				| '{'ListaDeclVar'}' {printf("18\n");}
				;

ListaDeclVar :	%empty {printf("19\n");}
				| TIPO ID DeclVar';'ListaDeclVar {printf("20\n");}
				| TIPO ID'['INTCONST']' DeclVar';' ListaDeclVar {printf("21\n");}
				;

ListaComando :	Comando {printf("22\n");}
				| Comando ListaComando {printf("23\n");}
				;

Comando :		';' {printf("24\n");}
				| Expr ';' {printf("25\n");}
				| RETURN Expr';' {printf("26\n");}
				| LEIA LValueExpr';' {printf("27\n");}
				| ESCREVA Expr';' {printf("28\n");}
				| ESCREVA STRING';' {printf("29\n");}
				| NOVALINHA ';' {printf("30\n");}
				| SE '(' Expr ')' ENTAO Comando {printf("31!\n");}
				| SE '(' Expr ')' ENTAO Comando SENAO Comando {printf("32!\n");}
				| ENQUANTO '('Expr')' EXECUTE Comando {printf("33\n");}
				| Bloco {printf("34\n");}
				;

Expr :			AssignExpr {printf("35\n");}
				;

AssignExpr :	CondExpr {printf("36\n");}
				| LValueExpr'='AssignExpr {printf("37\n");}
				;

CondExpr :		OrExpr {printf("38\n");}
				| OrExpr '?' Expr ':' CondExpr {printf("39\n");}
				;

OrExpr :		OrExpr OR AndExpr {printf("40\n");}
				| AndExpr {printf("41\n");}
				;

AndExpr	:		AndExpr "e" EqExpr {printf("42\n");}
				| EqExpr {printf("43\n");}
				;

EqExpr :		EqExpr EQUAL DesigExpr {printf("44\n");}
				| EqExpr DIF DesigExpr {printf("45\n");}
				| DesigExpr {printf("46\n");}
				;

DesigExpr : 	DesigExpr '<' AddExpr {printf("47\n");}
				| DesigExpr '>' AddExpr {printf("48\n");}
				| DesigExpr GEQ AddExpr {printf("49\n");}
				| DesigExpr LEQ AddExpr {printf("50\n");}
				| AddExpr {printf("51\n");}
				;

AddExpr :		AddExpr '+' MulExpr {printf("52\n");}
				| AddExpr '-' MulExpr {printf("53\n");}
				| MulExpr {printf("54\n");}
				;

MulExpr :		MulExpr '*' UnExpr {printf("55\n");}
				| MulExpr '/' UnExpr {printf("56\n");}
				| MulExpr '%' UnExpr {printf("57\n");}
				| UnExpr {printf("58\n");}
				;

UnExpr :		'-'PrimExpr {printf("59\n");}
				| '!'PrimExpr {printf("60\n");}
				| PrimExpr {printf("61\n");}
				;

LValueExpr :	ID'['Expr']' {printf("62");}
				| ID {printf("63\n");}
				;

PrimExpr :		ID '('ListExpr')' {printf("64\n");}
				| ID '('')' {printf("65\n");}
				| ID '['Expr']' {printf("66\n");}
				| ID {printf("67\n");}
				| '('Expr')' {printf("68\n");}
				| INTCONST
				;

ListExpr :		AssignExpr {printf("69\n");}
				| ListExpr ',' AssignExpr {printf("70\n");}
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