#include "valor_t.h"

static void free_valor(valor_t *val) {
    if (val) {
        free(val->lexema);
        free(val);
    }
}

void set_valor_lexico(int token, char* value){
    valor_t *aux = NULL;
    aux = malloc(sizeof(valor_t));
 
    // Checks malloc error
    if(aux == NULL){
       fprintf(stderr, "Erro de alocação de memória para valor_t\n");
       exit(1);
    }
 
    aux->line_number = get_line_number();
    aux->token_type = token;
    aux->lexema = strdup(value);

    if(aux->lexema == NULL){
      fprintf(stderr, "Erro de alocação de memória para lexema\n");
      free(aux);
      exit(1);
    }
 
    yylval.valor_lexico = aux;
}