bison -d -o parser.cpp parser.y
lex -o tokens.cpp tokens.l
g++ -o parser parser.cpp tokens.cpp -lfl