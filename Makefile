## Compiler and flags
#CC = gcc
#CFLAGS = -Wall -Wextra -g
#LEX = flex
#BISON = bison

## Source files
#LEX_FILE = scanner.l
#BISON_FILE = parser.y
#SRC = main.c lex.yy.c parser.tab.c
#OBJ = main.o lex.yy.o parser.tab.o

## Output binary
#TARGET = etapa2

## Rules
#all: $(TARGET)

#$(TARGET): $(OBJ)
#	$(CC) $(CFLAGS) -o $@ $^ -lfl

#lex.yy.c: $(LEX_FILE)
#	$(LEX) -o $@ $<

#parser.tab.c parser.tab.h: $(BISON_FILE)
#	$(BISON) -d -o parser.tab.c $<

#main.o: main.c
#	$(CC) $(CFLAGS) -c $< -o $@

#lex.yy.o: lex.yy.c
#	$(CC) $(CFLAGS) -c $< -o $@

#parser.tab.o: parser.tab.c
#	$(CC) $(CFLAGS) -c $< -o $@

#clean:
#	rm -f $(OBJ) lex.yy.c parser.tab.c parser.tab.h $(TARGET)

#.PHONY: all clean

all:
	bison -d parser.y 
	flex scanner.l 
	gcc -c lex.yy.c parser.tab.c main.c -fsanitize=address
	gcc -fsanitize=address lex.yy.o parser.tab.o main.o -lfl -o etapa2
