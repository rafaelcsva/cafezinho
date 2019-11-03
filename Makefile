default: all

all:
	bison -o parser.cpp -y -d parser.y
	flex -o tokens.cpp tokens.l
	g++ parser.cpp tokens.cpp -O2 -o parser
	
clean:
	rm *.cpp *.hpp parser
	
debug:
	bison -d -o parser.cpp -y parser.y
	flex -o tokens.cpp tokens.l
	g++ -o parser parser.cpp tokens.cpp -DDBG_PRINT_TREE