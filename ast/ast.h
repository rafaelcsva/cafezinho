#include <vector>
#include <iostream>
#include <algorithm>
#include <string>
#include <map>
#include <stack>
#include <set>
#include <sstream>

void yyerror(const char *);
void yyerror(const char *, int);

class Identifier;
class FuncDecl;
class ConstExpr;

class ASTNode {
	protected:
		std::vector< ASTNode* > child;
		int node_location;
	public:
		ASTNode() { child.clear(); }
		
		virtual void add(ASTNode* node) { child.push_back(node); }
		
		void set_location(int lineno) { node_location = lineno; }
		
		void reverse() { std::reverse(child.begin(), child.end()); }
		
		virtual void walk(int depth) {
			#ifdef DBG_PRINT_TREE
				INDENT( depth )
				std::cout << " em um ASTNode qualquer.." << std::endl;
			#endif
			for( size_t i = 0; i < child.size(); i++ ) child[i]->walk( depth+1 );
		}
};