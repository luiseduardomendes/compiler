#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "table.h"
#include "valor_t.h"

entry_t new_entry(int line, int nature, int type, valor_t value, args_t *args)
{
    entry_t entry;
    entry.line = line;
    entry.nature = nature;
    entry.type = type;
    entry.value = value;
    entry.args = args;
    return entry;
}

void add_function_arg(entry_t *entry, valor_t value, int type){
    if (entry == NULL) 
        return;

    args_t *new_arg = malloc(sizeof(args_t));
    if (new_arg == NULL) 
        return;

    new_arg->type = type;
    new_arg->value = value;
    new_arg->next_args = NULL;
        
    if (entry->args == NULL) {
        entry->args = new_arg;
    } 
    else {
        args_t *args_aux = entry->args;
        while (args_aux->next_args != NULL) {
            args_aux = args_aux->next_args;
        }
        args_aux->next_args = new_arg;
    }
}

table_t *new_table()
{
    table_t *table = NULL;
    table = calloc(1, sizeof(table_t));
    if (table != NULL)
    {
        table->entries = NULL;
        table->num_entries = 0;
    }
    return table;
}

void add_entry(table_t *table, entry_t *entry)
{
    if (table == NULL || entry == NULL)
        return;

    table->num_entries++;
    table->entries = realloc(table->entries, table->num_entries * sizeof(entry_t));
    table->entries[table->num_entries - 1] = entry;

    entry->value.token_value = strdup(entry->value.token_value);
}

entry_t *search_table(table_t *table, char *label)
{
    if (table == NULL)
        return NULL;

    for (int i = 0; i < table->num_entries; i++)
    {
        entry_t *entry = table->entries[i];
        if (!strcmp(entry->value.token_value, label))
            return entry;
    }
    return NULL;
}

void free_table(table_t *table)
{
    if (table == NULL)
        return;

    int i;
    args_t *args = NULL;
    args_t *args_aux = NULL;
    for (i = 0; i < table->num_entries; i++)
    {
        free(table->entries[i]->value.token_value);
        free(table->entries[i]);

        if(table->entries[i]->args != NULL){
            args = table->entries[i]->args;
            args_aux = table->entries[i]->args->next_args;
            while (args != NULL){
                free(args);
                args = args_aux;
                args_aux = args_aux->next_args;
            }
        }
    }
    free(table->entries);
    free(table);
}

table_stack_t *new_table_stack()
{
    table_stack_t *table_stack = NULL;
    table_stack = calloc(1, sizeof(table_stack_t));
    if (table_stack != NULL)
    {
        table_stack->top = NULL;
        table_stack->next = NULL;
    }
    return table_stack;
}

void push_table(table_stack_t **table_stack, table_t *new_table)
{
    if (new_table == NULL)
        return;

    if (*table_stack == NULL)
    {
        *table_stack = new_table_stack();
    }
    if ((*table_stack)->top != NULL)
    {
        table_stack_t *next = new_table_stack();
        next->top = (*table_stack)->top;
        next->next = (*table_stack)->next;
        (*table_stack)->next = next;
    }
    (*table_stack)->top = new_table;
}

void pop_table(table_stack_t **table_stack)
{
    if (table_stack == NULL)
        return;

    free_table((*table_stack)->top);
    if ((*table_stack)->next != NULL)
    {
        table_stack_t *aux = (*table_stack)->next;
        (*table_stack)->top = aux->top;
        (*table_stack)->next = aux->next;
        free(aux);
    }
    else
    {
        free((*table_stack));
        (*table_stack) = NULL;
    }
}

entry_t *search_table_stack(table_stack_t *table_stack, char *label)
{
    if (table_stack == NULL)
        return NULL;

    table_stack_t *aux = table_stack;
    while (aux != NULL)
    {
        entry_t *entry = search_table(aux->top, label);
        if (entry != NULL)
            return entry;
        aux = aux->next;
    }
    return NULL;
}

void free_table_stack(table_stack_t *table_stack)
{
    if (table_stack == NULL)
        return;

    free_table_stack(table_stack->next);
    free_table(table_stack->top);
    free(table_stack);
}