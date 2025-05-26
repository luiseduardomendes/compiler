// Nomes: 
//   - Leonardo Kauer Leffa
//   - Luis Eduardo Pereira Mendes
// 
//   turma: B
//   

%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "asd.h"
    #include "errors.h"
    #include "table.h"
    #include "valor_t.h"
    #include "parser.tab.h"
    #include "type.h"

    int get_line_number();
    int yylex(void);
    void yyerror (char const *mensagem);

%}

%{
    #include "table.h"
    extern asd_tree_t *arvore;
    table_stack_t *stack;
    
    type_t type_current_function;

    // Add these helper functions
    static char *safe_strconcat(const char *s1, const char *s2) {
        char *result;
        if (asprintf(&result, "%s%s", s1, s2) == -1) {
            yyerror("String concatenation failed");
            return NULL;
        }
        return result;
    }
%}

%define parse.error verbose

%code requires {
    #include "asd.h"
    #include "errors.h"
    #include "table.h"
    #include "parser.tab.h"
    #include "type.h"
    #include "valor_t.h"
}

%union {
    asd_tree_t *no; 
    valor_t *valor_lexico;
    args_t *args;
    type_t *type;
};

%token TK_PR_AS
%token TK_PR_DECLARE
%token TK_PR_ELSE
%token TK_PR_FLOAT
%token TK_PR_IF
%token TK_PR_INT
%token TK_PR_IS
%token TK_PR_RETURN
%token TK_PR_RETURNS
%token TK_PR_WHILE
%token TK_PR_WITH
%token TK_OC_LE
%token TK_OC_GE
%token TK_OC_EQ
%token TK_OC_NE

%token <valor_lexico>TK_ID
%token <valor_lexico>TK_LI_INT
%token <valor_lexico>TK_LI_FLOAT
%token TK_ER

%type<no> programa
%type<no> nivel0
%type<no> nivel1
%type<no> nivel2
%type<no> nivel3
%type<no> nivel4
%type<no> nivel5
%type<no> nivel6
%type<no> nivel7
%type<no> expressao
%type<no> termo
%type<no> argumento
%type<no> comando_atribuicao
%type<no> comando_retorno
%type<no> comando_simples
%type<no> comandos_controle_fluxo
%type<no> chamada_funcao
%type<no> sequencia_comandos
%type<no> lista_argumentos
%type<no> lista_elementos
//%type<no> lista_parametros
%type<no> elementos_programa
//%type<no> parametro
%type<no> sequencia_opcional_comandos
%type<no> bloco_comandos
%type<no> declaracao_variavel
%type<no> definicao_funcao
%type<no> declaracao_variavel_global
%type<no> cabecalho
%type<no> literal

%type<no> pop
%type<no> push

%type<type> tipo

%type<args> parametro
%type<args> lista_parametros
%type<args> lista_opcional_parametros

%destructor {
    if($$ != NULL && $$ != arvore){
        asd_free($$);
    }
    free_table_stack(stack);
} <no>;

%start programa

%%
//-----------------------------------------------------------------------------------------------------------------------
//  Programa na linguagem
//-----------------------------------------------------------------------------------------------------------------------
programa: 
    push lista_elementos pop ';' { $$ = $2; arvore = $$; stack = new_table_stack();} | 
    /*epsilon*/                  { $$ = NULL; arvore = $$; }
    ;
    
lista_elementos: 
    elementos_programa ',' lista_elementos {
        if ($1 != NULL && $3 != NULL) {
            asd_add_child($1, $3);
            $$ = $1;
        } else if ($1 != NULL) {
            $$ = $1;
        } else {
            $$ = $3;
        }
    } |
    elementos_programa {
        $$ = $1;
    };

elementos_programa: 
    definicao_funcao           { $$ = $1; } | 
    declaracao_variavel_global { asd_free($1); $$ = NULL; };


//-----------------------------------------------------------------------------------------------------------------------
// Usados em toda a linguagem
//-----------------------------------------------------------------------------------------------------------------------
tipo: 
    TK_PR_FLOAT {
        type_t *type = malloc(sizeof(type_t));
        *type = FLOAT;
        $$ = type;
    } | 
    TK_PR_INT {
        type_t *type = malloc(sizeof(type_t));
        *type = INT;
        $$ = type;
    };

// ToDo: verificar se tem algum tipo associado ao bloco_comandos
bloco_comandos: 
    '[' push sequencia_opcional_comandos pop ']' { $$ = $3; };

literal: 
    TK_LI_INT   { $$ = asd_new($1->lexema, INT  ); free_valor($1); } | 
    TK_LI_FLOAT { $$ = asd_new($1->lexema, FLOAT); free_valor($1); } ;
//-----------------------------------------------------------------------------------------------------------------------
// Definicao de Funcao
//-----------------------------------------------------------------------------------------------------------------------
definicao_funcao: 
     cabecalho '[' sequencia_opcional_comandos ']' pop {
        $$ = $1;  
        if($3 != NULL){
            asd_add_child($$, $3);
        }
    };

cabecalho: 
    TK_ID TK_PR_RETURNS tipo push TK_PR_IS                           { 
        entry_t *entry = search_table(stack->top, $1->lexema);
        if (entry != NULL) {
            free_valor($1);
            free($3);
            printf("ERR_DECLARED\n: Line: %d\n", get_line_number());
            exit(ERR_DECLARED);
        }
        type_current_function = *($3); 
        entry = new_entry(get_line_number(), N_FUNC, *($3), $1, NULL);
        add_entry(stack->top, entry);
        $$ = asd_new($1->lexema, *($3)); 
        free_valor($1);
        free($3);
        } |
    TK_ID TK_PR_RETURNS tipo push lista_opcional_parametros TK_PR_IS { 
        entry_t *entry = search_table(stack->top, $1->lexema);
        if (entry != NULL) {
            free_valor($1);
            free($3);
            if ($5) { // <--- FREE PARAMETER LIST IF ERROR
                args_t *a = $5, *tmp;
                while (a) {
                    tmp = a->next_args;
                    if (a->value) {
                        free_valor(a->value);
                    }
                    free(a);
                    a = tmp;
                }
            }
            printf("ERR_DECLARED\n: Line: %d\n", get_line_number());
            exit(ERR_DECLARED);
        }
        type_current_function = *($3);
        entry = new_entry(get_line_number(), N_FUNC, *($3), $1, $5);
        add_entry(stack->top, entry);
        $$ = asd_new($1->lexema, *($3));
        free_valor($1);
        if ($5) free_args($5);
        free($3);
        } ;

lista_opcional_parametros:
    TK_PR_WITH lista_parametros {$$ = $2;};

lista_parametros: 
    parametro ',' lista_parametros{
        $$ = add_arg($1, $3->value, $3->type);
    }| 
    parametro{
        $$ = $1;
    };

parametro:
    TK_ID TK_PR_AS tipo{
        entry_t *entry;

        $$ = create_arg($1, *($3));
        entry = new_entry(get_line_number(), N_VAR, *($3), $1, NULL);

        add_entry(stack->top, entry);
        free_valor($1);
        free($3);
    };

//-----------------------------------------------------------------------------------------------------------------------
// Declaracao de variavel global
//-----------------------------------------------------------------------------------------------------------------------
declaracao_variavel_global: 
    TK_PR_DECLARE TK_ID TK_PR_AS tipo {
        entry_t *entry = search_table(stack->top, $2->lexema);
        if (entry != NULL){
            free_valor($2);
            free($4);
            printf("ERR_DECLARED: Line: %d\n", get_line_number());
            exit(ERR_DECLARED);
        } else {
            entry = new_entry(get_line_number(), N_VAR, *($4), $2, NULL);
            add_entry(stack->top, entry);
        }
        $$ = asd_new($2->lexema, *($4));
        free_valor($2);
        free($4);
    };

//-----------------------------------------------------------------------------------------------------------------------
// Comandos Simples
//-----------------------------------------------------------------------------------------------------------------------
sequencia_opcional_comandos:
    sequencia_comandos  { $$ = $1;   } |
    /*epsilon*/         { $$ = NULL; } ; 

sequencia_comandos:
    comando_simples {
        $$ = $1;
    } |
    comando_simples sequencia_comandos {
        if ($1 != NULL && $2 != NULL) {
            $$ = $1;
            asd_add_child($$, $2);
        } else if ($1 != NULL) {
            $$ = $1;
        } else {
            $$ = $2;
        }
    };

comando_simples:
    bloco_comandos          { $$ = $1; } | 
    declaracao_variavel     { $$ = $1; } | 
    comando_atribuicao      { $$ = $1; } | 
    comando_retorno         { $$ = $1; } | 
    chamada_funcao          { $$ = $1; } | 
    comandos_controle_fluxo { $$ = $1; } ;

declaracao_variavel:
    declaracao_variavel_global { asd_free($1); $$ = NULL; } | 
    declaracao_variavel_global TK_PR_WITH literal { 
        $$ = asd_new("with", $3->type);
        if ($1->type != $3->type){
            printf("ERR_WRONG_TYPE: Line: %d\nType <%s> does not match <%s>\n", get_line_number(), dcd_type($1->type), dcd_type($3->type));
            exit(ERR_WRONG_TYPE);}
        if ($1 != NULL){
            asd_add_child($$, $1);
        }
        if ($3 != NULL){
            asd_add_child($$, $3);
        }
    };

comando_atribuicao:
    TK_ID TK_PR_IS expressao {
        entry_t *entry_id = search_table_stack(stack, $1->lexema);

        if(entry_id == NULL){
            printf("ERR_UNDECLARED: \nLine: %d\nVariable: %s\n", get_line_number(), $1->lexema);
            free_valor($1);
            exit(ERR_UNDECLARED);
        }
        if (entry_id->nature == N_FUNC){
            free_valor($1);
            printf("ERR_FUNCTION: Line: %d\n", get_line_number());
            exit(ERR_FUNCTION);
        }
        if (entry_id->type != $3->type){
            free_valor($1);
            printf("ERR_WRONG_TYPE: Line: %d\nType <%s> does not match <%s>\n", get_line_number(), dcd_type(entry_id->type), dcd_type($3->type));
            exit(ERR_WRONG_TYPE);
        }
        
        $$ = asd_new("is", entry_id->type); 
        if ($1 != NULL){
            asd_add_child($$, asd_new(entry_id->value->lexema, entry_id->type)); 
        }
        if ($3 != NULL){
            asd_add_child($$, $3); 
        }
        free_valor($1);
    } ; 

chamada_funcao: 
    TK_ID '(' lista_argumentos ')'  { 
        entry_t *entry = search_table_stack(stack, $1->lexema);
        if (entry == NULL){
            printf("ERR_UNDECLARED: Line: %d\nFunction: %s\n", get_line_number(), $1->lexema);
            free_valor($1);
            exit(ERR_UNDECLARED);
        }
        if (entry->nature == N_VAR){
            free_valor($1);
            printf("ERR_VARIABLE\n");
            exit(ERR_VARIABLE);
        }
        char *func_name = safe_strconcat("call ", $1->lexema);

        switch(compare_args(entry->args, $3)){
            case ERR_WRONG_TYPE_ARGS: 
                free(func_name);
                free_valor($1);
                printf("ERR_WRONG_TYPE_ARGS: Line: %d\n", get_line_number());
                exit(ERR_WRONG_TYPE_ARGS);
            case ERR_MISSING_ARGS: 
                free(func_name);
                free_valor($1);
                printf("ERR_MISSING_ARGS: Line: %d\n", get_line_number());
                exit(ERR_MISSING_ARGS);
            case ERR_EXCESS_ARGS: 
                free(func_name);
                free_valor($1);
                printf("ERR_EXCESS_ARGS: Line: %d\n", get_line_number());
                exit(ERR_EXCESS_ARGS);
            case 0: break;
        }
        
        $$ = asd_new(func_name, entry->type);
        if ($3 != NULL){
            asd_add_child($$, $3); 
        }
        free(func_name);
        free_valor($1);
    } | 
    TK_ID '(' ')' {
        entry_t *entry = search_table_stack(stack, $1->lexema);
        if (entry == NULL){
            printf("ERR_UNDECLARED: Line: %d\nFunction: %s\n", get_line_number(), $1->lexema);
            free_valor($1);
            exit(ERR_UNDECLARED);
        }
        if (entry->nature == N_VAR){
            free_valor($1);
            printf("ERR_VARIABLE: Line: %d\n", get_line_number());
            exit(ERR_VARIABLE);
        }
        char *func_name = safe_strconcat("call ", $1->lexema);
        $$ = asd_new(func_name, entry->type);
        free(func_name);
        free_valor($1);
    } ;

lista_argumentos:
    argumento ',' lista_argumentos  { 
        $$ = $1; 
        asd_add_child($$, $3); } |
    argumento                       { $$ = $1; } ;

argumento:
    expressao { $$ = $1; };

comando_retorno:
    TK_PR_RETURN expressao TK_PR_AS tipo { 
        if(type_current_function != *($4)){
            free($4);
            printf("ERR_WRONG_TYPE: Line: %d\nType <%s> does not match <%s>\n", get_line_number(), dcd_type(type_current_function), dcd_type(*($4)));
            exit(ERR_WRONG_TYPE);
        }
        if(type_current_function != $2->type){
            free($4);
            printf("ERR_WRONG_TYPE: Line: %d\nType <%s> does not match <%s>\n", get_line_number(), dcd_type(type_current_function), dcd_type($2->type));
            exit(ERR_WRONG_TYPE);
        }
        $$ = asd_new("return", type_current_function);
        if ($2 != NULL){
            asd_add_child($$, $2); 
        }
        free($4);
    };

comandos_controle_fluxo: 
    TK_PR_IF '(' expressao ')' push bloco_comandos pop TK_PR_ELSE push bloco_comandos pop { 
        if ($6 != NULL && $10 != NULL && $6->type != $10->type){
            printf("ERR_WRONG_TYPE: Line: %d\nType <%s> does not match <%s>\n", get_line_number(), dcd_type($6->type), dcd_type($10->type));
            exit(ERR_WRONG_TYPE);
        }

        $$ = asd_new("if", $3->type); 
        
        if($3 != NULL){
            asd_add_child($$, $3); 
        }
        if($6 != NULL){
            asd_add_child($$, $6); 
        }
        if($10 != NULL){
            asd_add_child($$, $10); 
        }
    } |  
    TK_PR_IF '(' expressao ')' push bloco_comandos pop { 
        $$ = asd_new("if", $3->type);     

        if($3 != NULL){
            asd_add_child($$, $3); 
        }
        if($6 != NULL){
            asd_add_child($$, $6); 
        }
    } |
    TK_PR_WHILE '(' expressao ')' push bloco_comandos pop { 
        $$ = asd_new("while", $3->type);  
        if($3 != NULL){
            asd_add_child($$, $3); 
        }
        if($6 != NULL){
            asd_add_child($$, $6); 
        }
    } ;

termo:
    TK_ID {
        entry_t *entry = search_table_stack(stack, $1->lexema);
        if (entry == NULL){
            printf("ERR_UNDECLARED: Line: %d\nVariable: %s\n", get_line_number(), $1->lexema);
            free_valor($1);
            exit(ERR_UNDECLARED);
        }
        if (entry->nature != N_VAR){
            free_valor($1);
            printf("ERR_FUNCTION: Line: %d\n", get_line_number());
            exit(ERR_FUNCTION);
        }
        $$ = asd_new($1->lexema, entry->type);
        free_valor($1);
    } |
    TK_LI_INT {
        $$ = asd_new($1->lexema, INT);
        free_valor($1);
    } |
    TK_LI_FLOAT {
        $$ = asd_new($1->lexema, FLOAT);
        free_valor($1);
    } ;

expressao:  
    nivel7 { $$ = $1; };

nivel7:
    nivel6            { $$ = $1; } |
    nivel7 '|' nivel6 {
        if ($1->type != $3->type) {printf("ERR_WRONG_TYPE: Line: %d\nType <%s> does not match <%s>\n", get_line_number(), dcd_type($1->type), dcd_type($3->type));exit(ERR_WRONG_TYPE);}
        $$ = asd_new("|", $1->type); asd_add_child($$, $1); asd_add_child($$, $3);
    } ;

nivel6:
    nivel5            { $$ = $1; } |
    nivel6 '&' nivel5 {
        if ($1->type != $3->type) {printf("ERR_WRONG_TYPE: Line: %d\nType <%s> does not match <%s>\n", get_line_number(), dcd_type($1->type), dcd_type($3->type));exit(ERR_WRONG_TYPE);}
        $$ = asd_new("&", $1->type); asd_add_child($$, $1); asd_add_child($$, $3);} ;

nivel5:
    nivel4                 { $$ = $1; } |
    nivel5 TK_OC_EQ nivel4 { 
        if ($1->type != $3->type) {printf("ERR_WRONG_TYPE: Line: %d\nType <%s> does not match <%s>\n", get_line_number(), dcd_type($1->type), dcd_type($3->type));exit(ERR_WRONG_TYPE);}
        $$ = asd_new("==", $1->type); asd_add_child($$, $1); asd_add_child($$, $3);} |
    nivel5 TK_OC_NE nivel4 { 
        if ($1->type != $3->type) {printf("ERR_WRONG_TYPE: Line: %d\nType <%s> does not match <%s>\n", get_line_number(), dcd_type($1->type), dcd_type($3->type));exit(ERR_WRONG_TYPE);}
        $$ = asd_new("!=", $1->type); asd_add_child($$, $1); asd_add_child($$, $3);} ;

nivel4:
    nivel3                 { $$ = $1; } |
    nivel4 '<' nivel3      { 
        if ($1->type != $3->type) {printf("ERR_WRONG_TYPE: Line: %d\nType <%s> does not match <%s>\n", get_line_number(), dcd_type($1->type), dcd_type($3->type));exit(ERR_WRONG_TYPE);}
        $$ = asd_new("<", $1->type) ; asd_add_child($$, $1); asd_add_child($$, $3);} | 
    nivel4 '>' nivel3      { 
        if ($1->type != $3->type) {printf("ERR_WRONG_TYPE: Line: %d\nType <%s> does not match <%s>\n", get_line_number(), dcd_type($1->type), dcd_type($3->type));exit(ERR_WRONG_TYPE);}
        $$ = asd_new(">", $1->type) ; asd_add_child($$, $1); asd_add_child($$, $3);} | 
    nivel4 TK_OC_LE nivel3 { 
        if ($1->type != $3->type) {printf("ERR_WRONG_TYPE: Line: %d\nType <%s> does not match <%s>\n", get_line_number(), dcd_type($1->type), dcd_type($3->type));exit(ERR_WRONG_TYPE);}
        $$ = asd_new("<=", $1->type); asd_add_child($$, $1); asd_add_child($$, $3);} | 
    nivel4 TK_OC_GE nivel3 { 
        if ($1->type != $3->type) {
            printf("ERR_WRONG_TYPE: Line: %d\nType <%s> does not match <%s>\n", get_line_number(), dcd_type($1->type), dcd_type($3->type));exit(ERR_WRONG_TYPE);}
        $$ = asd_new(">=", $1->type); asd_add_child($$, $1); asd_add_child($$, $3);} ;

nivel3:
    nivel2            { $$ = $1; } |
    nivel3 '+' nivel2 { 
        if ($1->type != $3->type) {printf("ERR_WRONG_TYPE: Line: %d\nType <%s> does not match <%s>\n", get_line_number(), dcd_type($1->type), dcd_type($3->type));exit(ERR_WRONG_TYPE);}
        $$ = asd_new("+", $1->type); asd_add_child($$, $1); asd_add_child($$, $3);} |
    nivel3 '-' nivel2 { 
        if ($1->type != $3->type) {printf("ERR_WRONG_TYPE: Line: %d\nType <%s> does not match <%s>\n", get_line_number(), dcd_type($1->type), dcd_type($3->type));exit(ERR_WRONG_TYPE);}
        $$ = asd_new("-", $1->type); asd_add_child($$, $1); asd_add_child($$, $3);} ;

nivel2:
    nivel1            { $$ = $1; } |
    nivel2 '*' nivel1 { 
        if ($1->type != $3->type) {printf("ERR_WRONG_TYPE: Line: %d\nType <%s> does not match <%s>\n", get_line_number(), dcd_type($1->type), dcd_type($3->type));exit(ERR_WRONG_TYPE);}$$ = asd_new("*", $1->type); asd_add_child($$, $1); asd_add_child($$, $3); } |
    nivel2 '/' nivel1 { 
        if ($1->type != $3->type) {printf("ERR_WRONG_TYPE: Line: %d\nType <%s> does not match <%s>\n", get_line_number(), dcd_type($1->type), dcd_type($3->type));exit(ERR_WRONG_TYPE);}$$ = asd_new("/", $1->type); asd_add_child($$, $1); asd_add_child($$, $3); } | 
    nivel2 '%' nivel1 { 
        if ($1->type != $3->type) {printf("ERR_WRONG_TYPE: Line: %d\nType <%s> does not match <%s>\n", get_line_number(), dcd_type($1->type), dcd_type($3->type));exit(ERR_WRONG_TYPE);}$$ = asd_new("%", $1->type); asd_add_child($$, $1); asd_add_child($$, $3); } ;
    
nivel1:
    nivel0     { $$ = $1; } |
    '+' nivel1 { $$ = asd_new("+", $2->type); asd_add_child($$, $2); } |
    '-' nivel1 { $$ = asd_new("-", $2->type); asd_add_child($$, $2); } |
    '!' nivel1 { $$ = asd_new("!", $2->type); asd_add_child($$, $2); } ;

nivel0:
    termo               { $$ = $1; } |
    chamada_funcao      { $$ = $1; } | 
    '(' expressao ')'   { $$ = $2; } ;

push: {   
    table_t *table = new_table();
    push_table(&stack, table);
    $$ = NULL;
};
pop: {
    pop_table(&stack);
    $$ = NULL;
};

%%

    void yyerror(char const *mensagem) {
        printf("[Error] - line %d: %s\n", get_line_number(), mensagem);
    }
