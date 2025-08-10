# Makefile for the lexical analyzer project
all: lexer

lexer: src/lexer.l
	flex -o src/lexer.cpp src/lexer.l
	g++ -o lexer src/lexer.cpp -lfl

clean:
	rm -f lexer src/lexer.cpp

