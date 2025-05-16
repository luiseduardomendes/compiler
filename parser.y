// Nomes: 
//   - Leonardo Kauer Leffa
//   - Luis Eduardo Pereira Mendes
// 
//   turma: B
//   

%{
    #include <stdio.h>
    int get_line_number();
    int yylex(void);
    void yyerror (char const *mensagem);
%}

%define parse.error verbose

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
%token TK_ID
%token TK_LI_INT
%token TK_LI_FLOAT
%token TK_ER

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
    sequencia_comandos comando_simples
    | comando_simples;

comando_simples:
    bloco_comandos
    | declaracao_variavel
    | comando_atribuicao
    | comando_retorno
    | chamada_funcao
    | comandos_controle_fluxo;

declaracao_variavel:
     declaracao_variavel_global
    | declaracao_variavel_global TK_PR_WITH literal;

comando_atribuicao:
    TK_ID TK_PR_IS expressao;

chamada_funcao: 
    TK_ID '(' lista_argumentos ')'
    | TK_ID '(' ')'
    ;

comando_retorno:
    TK_PR_RETURN expressao TK_PR_AS tipo;

lista_argumentos:
    argumento ',' lista_argumentos | argumento

argumento:
    expressao


comandos_controle_fluxo: 
    TK_PR_IF '(' expressao ')' bloco_comandos TK_PR_ELSE bloco_comandos 
    | TK_PR_IF '(' expressao ')' bloco_comandos
    | TK_PR_WHILE '(' expressao ')' bloco_comandos
    ;

expressao:  
    nivel7;

nivel0:
    termo |
    chamada_funcao | 
    '(' expressao ')';
    
termo:
    TK_ID |
    TK_LI_INT |
    TK_LI_FLOAT;

nivel1:
    nivel0 |
    '+' nivel1 |
    '-' nivel1 |
    '!' nivel1 ;

nivel2:
    nivel1 |
    nivel2 '*' nivel1 |
    nivel2 '/' nivel1 | 
    nivel2 '%' nivel1 ;

nivel3:
    nivel2 |
    nivel3 '+' nivel2 |
    nivel3 '-' nivel2;

nivel4:
    nivel3 |
    nivel4 '<' nivel3 | 
    nivel4 '>' nivel3 | 
    nivel4 TK_OC_LE nivel3 | 
    nivel4 TK_OC_GE nivel3;

nivel5:
    nivel4 |
    nivel5 TK_OC_EQ nivel4|
    nivel5 TK_OC_NE nivel4;

nivel6:
    nivel5 |
    nivel6 '&' nivel5;

nivel7:
    nivel6 |
    nivel7 '|' nivel6;


%%

    void yyerror(char const *mensagem) {
        printf("[Error] - line %d: %s\n", get_line_number(), mensagem);
    }
