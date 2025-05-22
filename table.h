#include "valor_t.h"

typedef struct{
    int line;
    nature_t nature;
    type_t type;
    args_t *args;
    valor_t *value;
}entry_t;

typedef struct list_args{
    type_t type;
    valor_t *value;
    struct list_args *next_args;
}args_t;

typedef struct{
    entry_t **entries;
    int num_entries;
}table_t;

typedef struct table_stack{
    table_t *top;
    struct table_stack *next;
}table_stack_t;

// Entries
entry_t* new_entry(int line, nature_t nature, type_t type, valor_t *value, args_t *args);

// Tables
table_t *new_table();
void add_entry(table_t *table, entry_t *entry);
entry_t *search_table(table_t *table, char *label);
void free_table(table_t *table);

// Stack
table_stack_t *new_table_stack();
void push_table(table_stack_t **table_stack, table_t *new_table);
void pop_table(table_stack_t **table_stack);
entry_t *search_table_stack(table_stack_t *table_stack, char *label);
void free_table_stack(table_stack_t *table_stack);