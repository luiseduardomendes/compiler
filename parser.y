// Nomes: 
//   - Leonardo Kauer Leffa
//   - Luis Eduardo Pereira Mendes
// 
//   turma: B
//   

%{
    #include <stdio.h>
    #include "asd.h"
    int get_line_number();
    int yylex(void);
    void yyerror (char const *mensagem);

    extern asd_tree_t *arvore;
%}

%define parse.error verbose

%union {asd_tree_t no;};
// oiiiiii Leo!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

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
%token <no>TK_ID
%token <no>TK_LI_INT
%token <no>TK_LI_FLOAT
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
%type<no> lista_opcional_parametros
%type<no> lista_parametros
%type<no> elementos_programa
%type<no> parametro

%start programa

%%
//-----------------------------------------------------------------------------------------------------------------------
//  Programa na linguagem
//-----------------------------------------------------------------------------------------------------------------------
programa: 
    lista_elementos ';'
    | /*epsilon*/
    ;
                        
lista_elementos: 
    lista_elementos ',' elementos_programa
    | elementos_programa;

elementos_programa: 
    definicao_funcao 
    | declaracao_variavel_global;

//-----------------------------------------------------------------------------------------------------------------------
// Usados em toda a linguagem
//-----------------------------------------------------------------------------------------------------------------------
tipo: 
    TK_PR_FLOAT 
    | TK_PR_INT;

bloco_comandos: 
    '[' sequencia_opcional_comandos ']';

literal: 
    TK_LI_INT
    | TK_LI_FLOAT;
//-----------------------------------------------------------------------------------------------------------------------
// Definicao de Funcao
//-----------------------------------------------------------------------------------------------------------------------
definicao_funcao: 
    cabecalho bloco_comandos; 

cabecalho: 
    TK_ID TK_PR_RETURNS tipo TK_PR_IS                              // sem lista opcional de parâmetros 
    | TK_ID TK_PR_RETURNS tipo lista_opcional_parametros TK_PR_IS; // lista opcional de parâmetros com um ou mais elementos

lista_opcional_parametros:
    TK_PR_WITH lista_parametros;

lista_parametros: 
    lista_parametros ',' parametro
    | parametro;

parametro:
    TK_ID TK_PR_AS tipo;

//-----------------------------------------------------------------------------------------------------------------------
// Declaracao de variavel global
//-----------------------------------------------------------------------------------------------------------------------
declaracao_variavel_global: 
    TK_PR_DECLARE TK_ID TK_PR_AS tipo; 

//-----------------------------------------------------------------------------------------------------------------------
// Comandos Simples
//-----------------------------------------------------------------------------------------------------------------------
sequencia_opcional_comandos:
    sequencia_comandos
    | /*epsilon*/;

sequencia_comandos:
    comando_simples sequencia_comandos  { $$ = $1; asd_add_child($1, $2); } | 
    comando_simples                     { $$ = $1; };

comando_simples:
    bloco_comandos
    | declaracao_variavel
    | comando_atribuicao
    | comando_retorno
    | chamada_funcao
    | comandos_controle_fluxo;

declaracao_variavel:
    declaracao_variavel_global | 
    declaracao_variavel_global TK_PR_WITH literal;

comando_atribuicao:
    TK_ID TK_PR_IS expressao {$$ = asd_new("TK_PR_IS"); asd_add_child($$, $1) asd_add_child($$, $3) } ; 

chamada_funcao: 
    TK_ID '(' lista_argumentos ')'  {} | 
    TK_ID '(' ')'                   {} ;

comando_retorno:
    TK_PR_RETURN expressao TK_PR_AS tipo {} ;

lista_argumentos:
    argumento ',' lista_argumentos  {} |
    argumento                       { $$ = $1 } ;

argumento:
    expressao { $$ = $1 };

comandos_controle_fluxo: 
    TK_PR_IF '(' expressao ')' bloco_comandos TK_PR_ELSE bloco_comandos {} | 
    TK_PR_IF '(' expressao ')' bloco_comandos                           {} |  
    TK_PR_WHILE '(' expressao ')' bloco_comandos                        {} ;

termo: // TODO: im not sure it works
    TK_ID       { $$ = asd_new($1->valor_lexico); } |
    TK_LI_INT   { $$ = asd_new($1->valor_lexico); } |
    TK_LI_FLOAT { $$ = asd_new($1->valor_lexico); } ;

expressao:  
    nivel7 { $$ = $1 };

nivel7:
    nivel6            { $$ = $1; } |
    nivel7 '|' nivel6 { $$ = asd_new("|"); asd_add_child($$, $1) asd_add_child($$, $3)} ;

nivel6:
    nivel5            { $$ = $1; } |
    nivel6 '&' nivel5 { $$ = asd_new("&"); asd_add_child($$, $1) asd_add_child($$, $3)} ;

nivel5:
    nivel4                 { $$ = $1; } |
    nivel5 TK_OC_EQ nivel4 { $$ = asd_new("=="); asd_add_child($$, $1) asd_add_child($$, $3)} |
    nivel5 TK_OC_NE nivel4 { $$ = asd_new("!="); asd_add_child($$, $1) asd_add_child($$, $3)} ;

nivel4:
    nivel3                 { $$ = $1; } |
    nivel4 '<' nivel3      { $$ = asd_new("<") ; asd_add_child($$, $1) asd_add_child($$, $3)} | 
    nivel4 '>' nivel3      { $$ = asd_new(">") ; asd_add_child($$, $1) asd_add_child($$, $3)} | 
    nivel4 TK_OC_LE nivel3 { $$ = asd_new("<="); asd_add_child($$, $1) asd_add_child($$, $3)} | 
    nivel4 TK_OC_GE nivel3 { $$ = asd_new(">="); asd_add_child($$, $1) asd_add_child($$, $3)} ;

nivel3:
    nivel2            { $$ = $1; } |
    nivel3 '+' nivel2 { $$ = asd_new("+"); asd_add_child($$, $1) asd_add_child($$, $3)} |
    nivel3 '-' nivel2 { $$ = asd_new("-"); asd_add_child($$, $1) asd_add_child($$, $3)} ;

nivel2:
    nivel1            { $$ = $1; } |
    nivel2 '*' nivel1 { $$ = asd_new("+"); asd_add_child($$, $1); asd_add_child($$, $3); } |
    nivel2 '/' nivel1 { $$ = asd_new("-"); asd_add_child($$, $1); asd_add_child($$, $3); } | 
    nivel2 '%' nivel1 { $$ = asd_new("!"); asd_add_child($$, $1); asd_add_child($$, $3); } ;
    
nivel1:
    nivel0     { $$ = $1; } |
    '+' nivel1 { $$ = asd_new("+"); asd_add_child($$, $2); } |
    '-' nivel1 { $$ = asd_new("-"); asd_add_child($$, $2); } |
    '!' nivel1 { $$ = asd_new("!"); asd_add_child($$, $2); } ;

nivel0:
    termo |
    chamada_funcao | 
    '(' expressao ')';

%%

    void yyerror(char const *mensagem) {
        printf("[Error] - line %d: %s\n", get_line_number(), mensagem);
    }
