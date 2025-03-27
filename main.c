/*
Função principal para realização da análise sintática.
*/
#include <stdio.h>
#include "parser.tab.h" //arquivo gerado com bison -d parser.y
                        //inclua tal comando no teu workflow (Makefile)
extern int yylex_destroy(void);
/*
int main (int argc, char **argv)
{
  int ret = yyparse();
  yylex_destroy();
  return ret;
}
*/

int main(int argc, char **argv) {
  if (argc < 2) {
      printf("Uso: %s <arquivo_de_entrada>\n", argv[0]);
      return 1;
  }
  
  FILE* yyin = fopen(argv[1], "r");
  if (!yyin) {
      perror("Erro ao abrir arquivo");
      return 1;
  }
  
  if (yyparse() == 0) {
      printf("Entrada válida de acordo com a gramática.\n");
  } else {
      printf("Erro na análise sintática.\n");
  }
  
  fclose(yyin);
  return 0;
}