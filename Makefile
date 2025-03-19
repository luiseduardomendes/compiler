all:
	flex scanner.l
	gcc main.c lex.yy.c -lfl