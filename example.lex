%{
#include "y.tab.h"
%}

TIPO	"int"|"car"
%%
{TIPO}	printf("TIPO");
%%

main()
{
  yylex();
}

