%{
#include <stdio.h>
#include "parser.tab.h"

int line_number = 1; 

int get_line_number(void) {
    return line_number;
}
%}

%option noyywrap 

%%

\n                                      { line_number++;}

"as"                                    {return TK_PR_AS;}
"declare"                               {return TK_PR_DECLARE;}
"else"                                  {return TK_PR_ELSE;}
"float"                                 {return TK_PR_FLOAT;}
"if"                                    {return TK_PR_IF;}
"int"                                   {return TK_PR_INT;}
"is"                                    {return TK_PR_IS;}
"return"                                {return TK_PR_RETURN;}
"returns"                               {return TK_PR_RETURNS;}
"while"                                 {return TK_PR_WHILE;}
"with"                                  {return TK_PR_WITH;}
[0-9]*\.[0-9]+                          {
                                            valor_t *aux = NULL;
                                            aux = malloc(sizeof(valor_t));
                                            if(aux == NULL){
                                                exit(0);
                                            }
                                            aux->lexema = strdup(yytext);
                                            yylval.valor_lexico = aux;
                                            return TK_LI_FLOAT;
                                        }
[0-9]+                                  {
                                            valor_t *aux = NULL;
                                            aux = malloc(sizeof(valor_t));
                                            if(aux == NULL){
                                                exit(0);
                                            }
                                            aux->lexema = strdup(yytext);
                                            yylval.valor_lexico = aux;
                                            return TK_LI_INT;
                                        }
[a-z_][a-z0-9_]*                        {
                                            valor_t *aux = NULL;
                                            aux = malloc(sizeof(valor_t));
                                            if(aux == NULL){
                                                exit(0);
                                            }
                                            aux->lexema = strdup(yytext);
                                            yylval.valor_lexico = aux;
                                            return TK_ID;
                                        }
"<="                                    {return TK_OC_LE;}
">="                                    {return TK_OC_GE;}
"=="                                    {return TK_OC_EQ;}
"!="                                    {return TK_OC_NE;}
[\!\*\/\%\+\-\<\>\[\]\(\)\=\,\;\&\|]    {return yytext[0];}
"//".*                                  {}
[ \t\s]                                 {}
.                                       {return TK_ER;}
%%
