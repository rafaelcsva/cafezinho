%{
#include "parser.hpp"

void yyerror(const char *);
int tmp = 0;

%}

%x COMMENT CADEIA
%%
[ \t\n]                 {
						if(strcmp(yytext, "\n") == 0){
							yylineno++;
						}

						}

"("						 return *yytext;
")"						 return *yytext;
"["						 return *yytext;
"]"						 return *yytext;
"{"						 return *yytext;
"}"						 return *yytext;
">="						return GEQ;
"<="						 return LEQ;
">"						 return *yytext;
"<"						 return *yytext;
"=="						 return EQUAL;
"!="						 return DIF;
"+"						 return *yytext;
"-"						 return *yytext;
"/"						 return *yytext;
"!"						 return *yytext;
"%"						 return *yytext;
"*"						 return *yytext;
"e"						 return *yytext;
"ou"						 return OR;
"?"						 return *yytext;
":"						 return *yytext;
"="						 return *yytext;
"entao"						return ENTAO;
"se"					return SE;
"retorne"				return RETURN;
"senao"					return SENAO;
"leia"					return LEIA;
"escreva"				return ESCREVA;
"novalinha"				return NOVALINHA;
"enquanto"				return ENQUANTO;
"execute"				return EXECUTE;
";"						return *yytext;
"programa"				return PROGRAMA;
","						return *yytext;

"int"|"car"				return TIPO;

[a-zA-Z_][a-zA-Z0-9_]* 	return ID;
						

[0-9]+					return INTCONST;

\" 				{ BEGIN CADEIA;}
<CADEIA>\"		{ BEGIN INITIAL; return STRING; }
<CADEIA>\n		{ yylineno++; yyerror("CADEIA DE CARACTERES OCUPA MAIS DE UMA LINHA"); }
<CADEIA><<EOF>> { yyerror("STRING NAO TERMINA."); }
<CADEIA>.		{ }


"/*"			 { BEGIN COMMENT; }

<COMMENT>"*"+"/" { 	yylineno += tmp;
					tmp = 0;
					BEGIN INITIAL; }

<COMMENT>"*"+[^*/\n] {;}
<COMMENT>\n		 	{ tmp++; }
<COMMENT>[^*\n]	 	{;}
<COMMENT><<EOF>>	{ yyerror("COMENTARIO NAO TERMINA."); }

.                       {

							yyerror("CARACTERE INVÁLIDO.");
						}
%%

int yywrap(){ 
	return 1; 
}