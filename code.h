#ifndef __CODE_H__
#define __CODE_H__

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Function prototypes for code generation

// Binary operations
char* gen_binary_op(const char* op, const char* instr, 
                   char* left_code, char* left_reg,
                   char* right_code, char* right_reg);

// Unary operations
char* gen_unary_op(const char* op, const char* instr, 
                  char* child_code, char* child_reg);

// Constants and variables
char* gen_const(int value);
char* gen_var(const char* var_name);

// Assignment
char* gen_assign(const char* var_name, char* expr_code, char* expr_reg);

// Control structures
char* gen_if(char* cond_code, char* cond_reg, 
            char* then_code, char* else_code);
char* gen_while(char* cond_code, char* cond_reg, char* body_code);

// Helper functions
void append_code(char** dest, const char* src);
char* new_reg();  // For temporary register allocation

#endif // __CODE_H__