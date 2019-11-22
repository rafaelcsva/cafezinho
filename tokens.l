%{
#include "ast/ast.h"
#include "parser.hpp"

void yyerror(const char *);
int tmp = 0;
std::string buf;

%}

%x COMMENT CADEIA RCHAR ESCP ENDCHAR

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

"int"|"car"				{yylval.tval = new std::string(yytext); return TIPO;}

[a-zA-Z_][a-zA-Z0-9_]* 	{yylval.tval = new std::string(yytext); return ID;}

[0-9]+					{yylval.tval = new std::string(yytext); return INTCONST;}

\" 				{ BEGIN CADEIA; buf = "";}
<CADEIA>\"		{ BEGIN INITIAL; yylval.tval = new std::string(buf); return STRING; }
<CADEIA>\n		{ yylineno++; yyerror("CADEIA DE CARACTERES OCUPA MAIS DE UMA LINHA"); }
<CADEIA>{
	"\\n"		{ buf += '\n'; }
	"\\t"		{ buf += '\t'; }
	"\\a"		{ buf += '\a'; }
	"\\r"		{ buf += '\r'; }
	"\\b"		{ buf += '\b'; }
	"\\f"		{ buf += '\f'; }
	"\\\""		{ buf += '\\'; }
}
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

'				{ BEGIN RCHAR; }
<RCHAR>\\		{ BEGIN ESCP; }
<RCHAR>.		{ buf = ""; buf += *yytext; BEGIN ENDCHAR; }
<ESCP>{
	[0ntarbf\\']	{ buf = "\\"; buf += *yytext; BEGIN ENDCHAR; }
}
<ESCP>.			{ yyerror( "FALTANDO DELIMITADOR ' EM CONSTANTE TIPO char." ); }

<ENDCHAR>'		{ BEGIN INITIAL; yylval.tval = new std::string(yytext); return LITCHAR; }
<ENDCHAR>.		{ yyerror( "FALTANDO DELIMITADOR ' EM CONSTANTE TIPO char." ); };

.                       {

							yyerror("CARACTERE INVÁLIDO.");
						}


%%

int yywrap(){ 
	return 1; 
}