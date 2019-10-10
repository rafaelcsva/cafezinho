%{
#include "parser.hpp"
extern "C" int yywrap() { }
%}

%%
[ \t\n]                 printf("text = %s\n", yytext);
"int"|"car"				printf("TIPO"); return TIPO;
[a-zA-Z_][a-zA-Z0-9_]* 	printf("ID"); return ID;
[0-9]*					return INTCONST;
[a-zA-Z]				return carconst;
[a-zA-Z]*				return cadeiaCaracteres;
[0-9]					return intconst;
.                       printf("Unknown token!n"); yyterminate();
%%

main()
{
  yyparse();
}

