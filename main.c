#include <stdio.h>
#include "asd.h"
extern int yyparse(void);
extern int yylex_destroy(void);
asd_tree_t *arvore = NULL;
int main (int argc, char **argv)
{
  (void)argc;
  (void)argv;
  int ret = yyparse();
  asd_print_graphviz(arvore);
  printf("\nCódigo ILOC gerado:\n");
  print_code(arvore->children[0]->code);
  printf("\n");
  asd_free(arvore);
  yylex_destroy();
  return ret;
}
