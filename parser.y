%token <token> TPLUS TMINUS TMUL TDIV

%type <block> programa

%%
programa : TPLUS { printf("asdf\n"); }
			;
%%

