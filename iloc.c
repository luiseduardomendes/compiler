#include "iloc.h"
#include <stdlib.h>
#include <string.h>

iloc_instr_t* make_iloc(const char *label, const char *opcode, const char *arg1, const char *arg2, const char *result) {
    iloc_instr_t *instr = malloc(sizeof(iloc_instr_t));
    instr->label = label ? strdup(label) : NULL;
    instr->opcode = strdup(opcode);
    instr->arg1 = arg1 ? strdup(arg1) : NULL;
    instr->arg2 = arg2 ? strdup(arg2) : NULL;
    instr->result = result ? strdup(result) : NULL;
    instr->next = NULL;
    return instr;
}

iloc_list_t* new_iloc_list() {
    iloc_list_t *list = malloc(sizeof(iloc_list_t));
    list->head = list->tail = NULL;
    return list;
}

void append_iloc(iloc_list_t *list, iloc_instr_t *instr) {
    if (!list->head) {
        list->head = list->tail = instr;
    } else {
        list->tail->next = instr;
        list->tail = instr;
    }
}

iloc_list_t* concat_iloc(iloc_list_t *a, iloc_list_t *b) {
    if (!a->head) return b;
    if (!b->head) return a;
    a->tail->next = b->head;
    a->tail = b->tail;
    free(b);
    return a;
}

void free_iloc_list(iloc_list_t *list) {
    if (!list) return;
    iloc_instr_t *curr = list->head;
    while (curr) {
        iloc_instr_t *next = curr->next;
        if (curr->label) free(curr->label);
        if (curr->opcode) free(curr->opcode);
        if (curr->arg1) free(curr->arg1);
        if (curr->arg2) free(curr->arg2);
        if (curr->result) free(curr->result);
        free(curr);
        curr = next;
    }
    free(list);
}