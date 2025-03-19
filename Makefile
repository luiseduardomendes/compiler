# Nomes: 
#   - Leonardo Kauer Leffa
#   - Luis Eduardo Pereira Mendes
# turma: B 
# Data: 18/03/2025

all:
	flex scanner.l
	gcc main.c lex.yy.c -lfl