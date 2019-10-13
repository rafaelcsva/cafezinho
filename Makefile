default: all

all:
	bison -d -o parser.cpp parser.y
	flex -o tokens.cpp tokens.l
	g++ -o parser parser.cpp tokens.cpp -lfl
	
clean:
	rm *.cpp *.hpp parser
	
debug:
	bison -d -o parser.cpp -y parser.y
	flex -o tokens.cpp tokens.l
	g++ -o parser parser.cpp tokens.cpp -DDBG_PRINT_TREE