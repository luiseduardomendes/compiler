typedef struct {
   char *lexema;
   int line_number;
   int token_type;
} valor_t;

static void free_valor(valor_t *val);
void set_valor_lexico(int token, char* value);
