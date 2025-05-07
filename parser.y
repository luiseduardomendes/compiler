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

    int get_line_number();
    int yylex(void);
    void yyerror (char const *mensagem);

    extern asd_tree_t *arvore;

    typedef struct {
      char *lexema;
      int line_number;
      int token_type;
   } valor_t;

%}

%{

// Add these helper functions
static void free_valor(valor_t *val) {
    if (val) {
        free(val->lexema);
        free(val);
    }
}

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

%union {
    asd_tree_t *no; 
    valor_t *valor_lexico;
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
%type<no> lista_parametros
%type<no> elementos_programa
%type<no> parametro
%type<no> sequencia_opcional_comandos
%type<no> bloco_comandos
%type<no> declaracao_variavel
%type<no> definicao_funcao

%type<no> declaracao_variavel_global
%type<no> cabecalho
%type<no> literal

%start programa

%%
//-----------------------------------------------------------------------------------------------------------------------
//  Programa na linguagem
//-----------------------------------------------------------------------------------------------------------------------
programa: 
    lista_elementos ';' { $$ = $1; arvore = $$; } | 
    /*epsilon*/         { $$ = NULL; arvore = $$; }
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
    TK_PR_FLOAT | 
    TK_PR_INT;

bloco_comandos: 
    '[' sequencia_opcional_comandos ']' { $$ = $2; };

literal: 
    TK_LI_INT   { $$ = asd_new($1->lexema); free_valor($1); } | 
    TK_LI_FLOAT { $$ = asd_new($1->lexema); free_valor($1); } ;
//-----------------------------------------------------------------------------------------------------------------------
// Definicao de Funcao
//-----------------------------------------------------------------------------------------------------------------------
definicao_funcao: 
    cabecalho bloco_comandos {
        $$ = $1;  
        if($2 != NULL){
            asd_add_child($$, $2);
        }
    };

cabecalho: 
    TK_ID TK_PR_RETURNS tipo TK_PR_IS                           { $$ = asd_new($1->lexema); free_valor($1); } | 
    TK_ID TK_PR_RETURNS tipo lista_opcional_parametros TK_PR_IS { $$ = asd_new($1->lexema); free_valor($1); } ;

lista_opcional_parametros:
    TK_PR_WITH lista_parametros ;

lista_parametros: 
    lista_parametros ',' parametro | 
    parametro;

parametro:
    TK_ID TK_PR_AS tipo{
        free_valor($1);
    };

//-----------------------------------------------------------------------------------------------------------------------
// Declaracao de variavel global
//-----------------------------------------------------------------------------------------------------------------------
declaracao_variavel_global: 
    TK_PR_DECLARE TK_ID TK_PR_AS tipo {
        $$ = asd_new($2->lexema);
        free_valor($2);
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
        $$ = asd_new("with");
        asd_add_child($$, $1);
        asd_add_child($$, $3);
    };

comando_atribuicao:
    TK_ID TK_PR_IS expressao {
        $$ = asd_new("is"); 
        asd_add_child($$, asd_new($1->lexema)); 
        asd_add_child($$, $3);
        free_valor($1);
    } ; 

chamada_funcao: 
    TK_ID '(' lista_argumentos ')'  { 
        char *func_name = safe_strconcat("call ", $1->lexema);
        $$ = asd_new(func_name);
        asd_add_child($$, $3);
        free(func_name);
        free_valor($1);
    } | 
    TK_ID '(' ')' {
        char *func_name = safe_strconcat("call ", $1->lexema);
        $$ = asd_new(func_name);
        free(func_name);
        free_valor($1);  
    } ;

comando_retorno:
    TK_PR_RETURN expressao TK_PR_AS tipo { 
        $$ = asd_new("return");
        asd_add_child($$, $2);
    };

lista_argumentos:
    argumento ',' lista_argumentos  { $$ = $1; asd_add_child($$, $3); } |
    argumento                       { $$ = $1; } ;

argumento:
    expressao { $$ = $1; };

comandos_controle_fluxo: 
    TK_PR_IF '(' expressao ')' bloco_comandos TK_PR_ELSE bloco_comandos { 
        $$ = asd_new("if");    
        asd_add_child($$, $3); 
        if($5 != NULL){
            asd_add_child($$, $5); 
        }
        asd_add_child($$, $7); 
    } |  
    TK_PR_IF '(' expressao ')' bloco_comandos { 
        $$ = asd_new("if");     
        asd_add_child($$, $3);
        if($5 != NULL){
            asd_add_child($$, $5); 
        }
    } |
    TK_PR_WHILE '(' expressao ')' bloco_comandos { 
        $$ = asd_new("while");  
        asd_add_child($$, $3);
        if($5 != NULL){
            asd_add_child($$, $5); 
        }
    } ;

termo:
    TK_ID {
        $$ = asd_new($1->lexema);
        free_valor($1);
    } |
    TK_LI_INT {
        $$ = asd_new($1->lexema);
        free_valor($1);
    } |
    TK_LI_FLOAT {
        $$ = asd_new($1->lexema);
        free_valor($1);
    } ;

expressao:  
    nivel7 { $$ = $1; };

nivel7:
    nivel6            { $$ = $1; } |
    nivel7 '|' nivel6 { $$ = asd_new("|"); asd_add_child($$, $1); asd_add_child($$, $3);} ;

nivel6:
    nivel5            { $$ = $1; } |
    nivel6 '&' nivel5 { $$ = asd_new("&"); asd_add_child($$, $1); asd_add_child($$, $3);} ;

nivel5:
    nivel4                 { $$ = $1; } |
    nivel5 TK_OC_EQ nivel4 { $$ = asd_new("=="); asd_add_child($$, $1); asd_add_child($$, $3);} |
    nivel5 TK_OC_NE nivel4 { $$ = asd_new("!="); asd_add_child($$, $1); asd_add_child($$, $3);} ;

nivel4:
    nivel3                 { $$ = $1; } |
    nivel4 '<' nivel3      { $$ = asd_new("<") ; asd_add_child($$, $1); asd_add_child($$, $3);} | 
    nivel4 '>' nivel3      { $$ = asd_new(">") ; asd_add_child($$, $1); asd_add_child($$, $3);} | 
    nivel4 TK_OC_LE nivel3 { $$ = asd_new("<="); asd_add_child($$, $1); asd_add_child($$, $3);} | 
    nivel4 TK_OC_GE nivel3 { $$ = asd_new(">="); asd_add_child($$, $1); asd_add_child($$, $3);} ;

nivel3:
    nivel2            { $$ = $1; } |
    nivel3 '+' nivel2 { $$ = asd_new("+"); asd_add_child($$, $1); asd_add_child($$, $3);} |
    nivel3 '-' nivel2 { $$ = asd_new("-"); asd_add_child($$, $1); asd_add_child($$, $3);} ;

nivel2:
    nivel1            { $$ = $1; } |
    nivel2 '*' nivel1 { $$ = asd_new("*"); asd_add_child($$, $1); asd_add_child($$, $3); } |
    nivel2 '/' nivel1 { $$ = asd_new("/"); asd_add_child($$, $1); asd_add_child($$, $3); } | 
    nivel2 '%' nivel1 { $$ = asd_new("%"); asd_add_child($$, $1); asd_add_child($$, $3); } ;
    
nivel1:
    nivel0     { $$ = $1; } |
    '+' nivel1 { $$ = asd_new("+"); asd_add_child($$, $2); } |
    '-' nivel1 { $$ = asd_new("-"); asd_add_child($$, $2); } |
    '!' nivel1 { $$ = asd_new("!"); asd_add_child($$, $2); } ;

nivel0:
    termo               { $$ = $1; } |
    chamada_funcao      { $$ = $1; } | 
    '(' expressao ')'   { $$ = $2; } ;

%%

    void yyerror(char const *mensagem) {
        printf("[Error] - line %d: %s\n", get_line_number(), mensagem);
    }
