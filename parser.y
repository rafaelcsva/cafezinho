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

%type <node> DeclProg Programa DeclFuncVar DeclFunc ListaParametros ListaParametrosCont Bloco ListaDeclVar ListaComando
%type <decId> DeclVar

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
				| %empty { $$ = NULL; }
				;

DeclFunc :		'('ListaParametros')' Bloco {
					$$ = $2;
					$$->add($4);
				}
				;

ListaParametros :	%empty { $$ = NULL; }
					| ListaParametrosCont {
						$$ = $1;
					}
					;

ListaParametrosCont :	TIPO ID {
							$$ = new DeclVar();
							static_cast< DeclVar* >($$)->setDataType($1);
							static_cast< DeclVar* >($$)->add(new DeclId($2));
						}
						| TIPO ID '['']' {
							$$ = new DeclVar();
							static_cast< DeclVar* >($$)->setDataType($1);
							static_cast< DeclVar* >($$)->add(new DeclId($2, 0));
						}
						| TIPO ID',' ListaParametrosCont {
							$$ = new DeclVar();
							static_cast< DeclVar* >($$)->setDataType($1);
							static_cast< DeclVar* >($$)->add(new DeclId($2));

							$$->add($4);
						}
						| TIPO ID'['']'',' ListaParametrosCont {
							$$ = new DeclVar();
							static_cast< DeclVar* >($$)->setDataType($1);
							static_cast< DeclVar* >($$)->add(new DeclId($2, 0));

							$$->add($6);
						}
						;

Bloco :			'{'ListaDeclVar ListaComando'}' {
					$$ = $2;
					$$->add($3);
				}
				| '{'ListaDeclVar'}' {
					$$ = $2;
				}
				;

ListaDeclVar :	%empty { $$ = NULL; }
				| TIPO ID DeclVar';'ListaDeclVar { 
					$$ = new DeclVar();
					static_cast< DeclVar* >($$)->setDataType($1);
					static_cast< DeclVar* >($$)->add(new DeclId($2));

					$$->add($3);
					$$->add($5);
				}
				| TIPO ID'['INTCONST']' DeclVar';' ListaDeclVar {
					$$ = new DeclVar();
					static_cast< DeclVar* >($$)->setDataType($1);

					$$->add(new DeclId($2, $4));
					$$->add($6);

					if($8 != NULL)
						$$->add($8);
				}
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