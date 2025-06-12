#include "code.h"
#include "label.h"
#include "iloc.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

// Global register counter
static int reg_counter = 0;

// Get a new temporary register
char* new_reg() {
    char* reg = malloc(16);
    sprintf(reg, "r%d", reg_counter++);
    return reg;
}

// Generate code for binary operations
iloc_list_t* gen_binary_op(const char* op, const char* instr, iloc_list_t* left_code, char* left_reg, 
                          iloc_list_t* right_code, char* right_reg, char** result_reg) {
    iloc_list_t* code = new_iloc_list();
    if (left_code) code = concat_iloc(code, left_code);
    if (right_code) code = concat_iloc(code, right_code);

    *result_reg = new_reg();
    append_iloc(code, make_iloc(NULL, instr, left_reg, right_reg, *result_reg));
    return code;
}

// Generate code for unary operations
iloc_list_t* gen_unary_op(const char* op, const char* instr, iloc_list_t* child_code, char* child_reg, char** result_reg) {
    iloc_list_t* code = new_iloc_list();
    if (child_code) code = concat_iloc(code, child_code);

    *result_reg = new_reg();
    append_iloc(code, make_iloc(NULL, instr, child_reg, NULL, *result_reg));
    return code;
}

// Generate code for constants
iloc_list_t* gen_const(int value, char** result_reg) {
    iloc_list_t* code = new_iloc_list();
    *result_reg = new_reg();
    char val_str[16];
    sprintf(val_str, "%d", value);
    append_iloc(code, make_iloc(NULL, "loadI", val_str, NULL, *result_reg));
    return code;
}

// Generate code for variables
iloc_list_t* gen_var(const char* var_name, char** result_reg) {
    iloc_list_t* code = new_iloc_list();
    *result_reg = new_reg();
    append_iloc(code, make_iloc(NULL, "load", var_name, NULL, *result_reg));
    return code;
}

// Generate code for assignment
iloc_list_t* gen_assign(const char* var_name, iloc_list_t* expr_code, char* expr_reg) {
    iloc_list_t* code = new_iloc_list();
    if (expr_code) code = concat_iloc(code, expr_code);
    append_iloc(code, make_iloc(NULL, "store", expr_reg, NULL, var_name));
    return code;
}

// Generate code for if statement
iloc_list_t* gen_if(iloc_list_t* cond_code, char* cond_reg, iloc_list_t* then_code, iloc_list_t* else_code) {
    iloc_list_t* code = new_iloc_list();
    char* else_label = new_label();
    char* end_label = new_label();

    if (cond_code) code = concat_iloc(code, cond_code);
    append_iloc(code, make_iloc(NULL, "cbr", cond_reg, else_label, end_label));
    append_iloc(code, make_iloc(else_label, NULL, NULL, NULL, NULL));
    if (then_code) code = concat_iloc(code, then_code);

    if (else_code) {
        append_iloc(code, make_iloc(NULL, "jumpI", NULL, NULL, end_label));
        append_iloc(code, make_iloc(end_label, NULL, NULL, NULL, NULL));
        code = concat_iloc(code, else_code);
    } else {
        append_iloc(code, make_iloc(end_label, NULL, NULL, NULL, NULL));
    }
    return code;
}

// Generate code for while loop
iloc_list_t* gen_while(iloc_list_t* cond_code, char* cond_reg, iloc_list_t* body_code) {
    iloc_list_t* code = new_iloc_list();
    char* start_label = new_label();
    char* end_label = new_label();

    append_iloc(code, make_iloc(start_label, NULL, NULL, NULL, NULL));
    if (cond_code) code = concat_iloc(code, cond_code);
    append_iloc(code, make_iloc(NULL, "cbr", cond_reg, end_label, start_label));
    append_iloc(code, make_iloc(end_label, NULL, NULL, NULL, NULL));
    if (body_code) code = concat_iloc(code, body_code);
    append_iloc(code, make_iloc(NULL, "jumpI", NULL, NULL, start_label));
    return code;
}