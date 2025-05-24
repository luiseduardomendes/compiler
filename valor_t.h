#ifndef VALOR_T_H_
#define VALOR_T_H_

typedef struct {
   char *lexema;
   int line_number;
   int token_type;
} valor_t;

void set_valor_lexico(int token, char* value);
// Removed prototype for static function: static void free_valor(valor_t *val);

#endif // VALOR_T_H_