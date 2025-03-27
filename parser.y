%{
#include <stdio.h>
#include <stdlib.h>

int yyparse();
extern FILE *yyin;


void yyerror(const char *s) {
    fprintf(stderr, "Erro: %s\n", s);
}
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

%%
programa:
      lista_elementos ';'
    | ';'
    ;

lista_elementos:
      elemento
    | lista_elementos ',' elemento
    ;

elemento:
      definicao_funcao
    | declaracao_variavel
    ;

definicao_funcao:
      TK_ID TK_PR_RETURNS tipo TK_PR_IS bloco_comandos
    | TK_ID TK_PR_RETURNS tipo TK_PR_WITH TK_ID TK_PR_AS tipo TK_PR_IS bloco_comandos
    | TK_ID TK_PR_RETURNS tipo TK_PR_WITH parametros TK_PR_IS bloco_comandos
    ;

parametros:
      TK_ID TK_PR_AS tipo
    | parametros ',' TK_ID TK_PR_AS tipo
    ;

bloco_comandos:
      '*' /* Representa um bloco de comandos */
    ;

declaracao_variavel:
      TK_PR_DECLARE TK_ID TK_PR_AS tipo
    | TK_PR_DECLARE TK_ID TK_PR_AS tipo TK_PR_WITH valor
    ;

comando_atribuicao:
      TK_ID TK_PR_IS expressao
    ;

chamada_funcao:
      TK_ID '(' ')'
    | TK_ID '(' expressao ')'
    | TK_ID '(' lista_exp ')'
    ;

lista_exp:
      expressao
    | lista_exp ',' expressao
    ;

comando_retorno:
      TK_PR_RETURN expressao TK_PR_AS tipo
    ;

tipo:
      TK_PR_FLOAT
    | TK_PR_INT
    ;

expressao:
      TK_LI_INT
    | TK_LI_FLOAT
    | TK_ID
    ;

valor:
      TK_LI_INT
    | TK_LI_FLOAT
    ;

%%
