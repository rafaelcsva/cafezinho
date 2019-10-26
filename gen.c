#include <stdio.h>

int T = 25;
int linha = 0;
char s[][100] = {"(", ")", "[", "]", "{", "}", ">=", "<=", ">", "<", "==", "!=", "+", "-", "/", "!", "%", "*", "e", "ou", "?", ":", "=", "entao", "se"};

int main(){
	for(int i = 0 ; i < T ; i++){
		printf("\"%s\"\t\t\t\t\t\t printf(\"%s\"); return *yytext;\n", s[i], s[i]);
	}
}