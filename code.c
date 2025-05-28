#include "code.h"
#include "label.h"
#include <string.h>
#include <stdlib.h>

// Global register counter
static int reg_counter = 0;

// Get a new temporary register
char* new_reg() {
    char* reg = malloc(16);
    sprintf(reg, "r%d", reg_counter++);
    return reg;
}

// Generate code for binary operations
char* gen_binary_op(const char* op, const char* instr, char* left_code, char* left_reg, 
                   char* right_code, char* right_reg) {
    char* code = strdup("");
    if (left_code) append_code(&code, left_code);
    if (right_code) append_code(&code, right_code);
    
    char* result_reg = new_reg();
    append_code(&code, instr);
    append_code(&code, " ");
    append_code(&code, left_reg);
    append_code(&code, ", ");
    append_code(&code, right_reg);
    append_code(&code, " => ");
    append_code(&code, result_reg);
    append_code(&code, "\n");
    
    return code;
}

// Generate code for unary operations
char* gen_unary_op(const char* op, const char* instr, char* child_code, char* child_reg) {
    char* code = strdup("");
    if (child_code) append_code(&code, child_code);
    
    char* result_reg = new_reg();
    append_code(&code, instr);
    append_code(&code, " ");
    append_code(&code, child_reg);
    append_code(&code, " => ");
    append_code(&code, result_reg);
    append_code(&code, "\n");
    
    return code;
}

// Generate code for constants
char* gen_const(int value) {
    char* code = strdup("");
    char* reg = new_reg();
    
    append_code(&code, "loadI ");
    char val_str[16];
    sprintf(val_str, "%d", value);
    append_code(&code, val_str);
    append_code(&code, " => ");
    append_code(&code, reg);
    append_code(&code, "\n");
    
    return code;
}

// Generate code for variables
char* gen_var(const char* var_name) {
    char* code = strdup("");
    char* reg = new_reg();
    
    append_code(&code, "load ");
    append_code(&code, var_name);
    append_code(&code, " => ");
    append_code(&code, reg);
    append_code(&code, "\n");
    
    return code;
}

// Generate code for assignment
char* gen_assign(const char* var_name, char* expr_code, char* expr_reg) {
    char* code = strdup("");
    if (expr_code) append_code(&code, expr_code);
    
    append_code(&code, "store ");
    append_code(&code, expr_reg);
    append_code(&code, " => ");
    append_code(&code, var_name);
    append_code(&code, "\n");
    
    return code;
}

// Generate code for if statement
char* gen_if(char* cond_code, char* cond_reg, char* then_code, char* else_code) {
    char* code = strdup("");
    char* else_label = new_label();
    char* end_label = new_label();
    
    // Condition code
    if (cond_code) append_code(&code, cond_code);
    
    // Conditional branch
    append_code(&code, "cbr ");
    append_code(&code, cond_reg);
    append_code(&code, " -> ");
    append_code(&code, else_label);
    append_code(&code, ", ");
    append_code(&code, end_label);
    append_code(&code, "\n");
    
    // Then block
    append_code(&code, else_label);
    append_code(&code, ":\n");
    if (then_code) append_code(&code, then_code);
    
    // Else block (if exists)
    if (else_code && strlen(else_code) > 0) {
        append_code(&code, "jumpI -> ");
        append_code(&code, end_label);
        append_code(&code, "\n");
        append_code(&code, end_label);
        append_code(&code, ":\n");
        append_code(&code, else_code);
    } else {
        append_code(&code, end_label);
        append_code(&code, ":\n");
    }
    
    return code;
}

// Generate code for while loop
char* gen_while(char* cond_code, char* cond_reg, char* body_code) {
    char* code = strdup("");
    char* start_label = new_label();
    char* end_label = new_label();
    
    // Start label
    append_code(&code, start_label);
    append_code(&code, ":\n");
    
    // Condition code
    if (cond_code) append_code(&code, cond_code);
    
    // Conditional branch
    append_code(&code, "cbr ");
    append_code(&code, cond_reg);
    append_code(&code, " -> ");
    append_code(&code, end_label);
    append_code(&code, ", ");
    append_code(&code, start_label);
    append_code(&code, "\n");
    
    // Body code
    append_code(&code, end_label);
    append_code(&code, ":\n");
    if (body_code) append_code(&code, body_code);
    
    // Jump back to start
    append_code(&code, "jumpI -> ");
    append_code(&code, start_label);
    append_code(&code, "\n");
    
    return code;
}

// Helper function to append code
void append_code(char** dest, const char* src) {
    if (!src || !*src) return;
    
    if (!*dest) {
        *dest = strdup(src);
    } else {
        char* new_str = malloc(strlen(*dest) + strlen(src) + 1);
        sprintf(new_str, "%s%s", *dest, src);
        free(*dest);
        *dest = new_str;
    }
}