#   Nomes: 
#   - Leonardo Kauer Leffa
#   - Luis Eduardo Pereira Mendes

#   turma: B
  
#   Data: 18/03/2025

# Compiler and flags
CC = gcc
CFLAGS = -Wall -Wextra -g
LEX = flex

# Source files
LEX_FILE = scanner.l
SRC = main.c lex.yy.c
OBJ = main.o lex.yy.o

# Output binary
TARGET = etapa1

# Rules
all: $(TARGET)

$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^ -lfl

lex.yy.c: $(LEX_FILE)
	$(LEX) -o $@ $<

main.o: main.c
	$(CC) $(CFLAGS) -c $< -o $@

lex.yy.o: lex.yy.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJ) lex.yy.c $(TARGET)

.PHONY: all clean
