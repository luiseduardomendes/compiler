%{
#include <stdio.h>
#include "tokens.h"
%}

%%
"as"                          {printf("TK_PR_AS:          %s", yytext);printf(" (0x%x)\n", TK_PR_AS);}
"declare"                     {printf("TK_PR_DECLARE:     %s", yytext);printf(" (0x%x)\n", TK_PR_DECLARE);}
"else"                        {printf("TK_PR_ELSE:        %s", yytext);printf(" (0x%x)\n", TK_PR_ELSE);}
"float"                       {printf("TK_PR_FLOAT:       %s", yytext);printf(" (0x%x)\n", TK_PR_FLOAT);}
"if"                          {printf("TK_PR_IF:          %s", yytext);printf(" (0x%x)\n", TK_PR_IF);}
"int"                         {printf("TK_PR_INT:         %s", yytext);printf(" (0x%x)\n", TK_PR_INT);}
"is"                          {printf("TK_PR_IS:          %s", yytext);printf(" (0x%x)\n", TK_PR_IS);}
"return"                      {printf("TK_PR_RETURN:      %s", yytext);printf(" (0x%x)\n", TK_PR_RETURN);}
"returns"                     {printf("TK_PR_RETURNS:     %s", yytext);printf(" (0x%x)\n", TK_PR_RETURNS);}
"while"                       {printf("TK_PR_WHILE:       %s", yytext);printf(" (0x%x)\n", TK_PR_WHILE);}
"with"                        {printf("TK_PR_WITH:        %s", yytext);printf(" (0x%x)\n", TK_PR_WITH);}
[0-9]*\.[0-9]*                {printf("TK_LIT_FLOAT:      %s", yytext);printf(" (0x%x)\n", TK_LIT_FLOAT);}
[0-9]+                        {printf("TK_LIT_INT:        %s", yytext);printf(" (0x%x)\n", TK_LIT_INT);}
[a-zA-Z_][a-zA-Z0-9_]*        {printf("TK_ID:             %s", yytext);printf(" (0x%x)\n", TK_ID);}
"<="                          {printf("TK_OC_LE:          %s", yytext);printf(" (0x%x)\n", TK_OC_LE);}
">="                          {printf("TK_OC_GE:          %s", yytext);printf(" (0x%x)\n", TK_OC_GE);}
"=="                          {printf("TK_OC_EQ:          %s", yytext);printf(" (0x%x)\n", TK_OC_EQ);}
"!="                          {printf("TK_OC_NE:          %s", yytext);printf(" (0x%x)\n", TK_OC_NE);}
\!                            {printf("TK_OP_NOT:         %s", yytext);printf(" (0x%x)\n", TK_OP_NOT);}
\*                            {printf("TK_OP_MULT:        %s", yytext);printf(" (0x%x)\n", TK_OP_MULT);} 
\/                            {printf("TK_OP_DIV:         %s", yytext);printf(" (0x%x)\n", TK_OP_DIV);} 
\%                            {printf("TK_OP_MOD:         %s", yytext);printf(" (0x%x)\n", TK_OP_MOD);} 
\+                            {printf("TK_OP_ADD:         %s", yytext);printf(" (0x%x)\n", TK_OP_ADD);} 
\-                            {printf("TK_OP_SUB:         %s", yytext);printf(" (0x%x)\n", TK_OP_SUB);} 
\<                            {printf("TK_OP_LESS:        %s", yytext);printf(" (0x%x)\n", TK_OP_LESS);} 
\>                            {printf("TK_OP_GREATER:     %s", yytext);printf(" (0x%x)\n", TK_OP_GREATER);} 
\[                            {printf("TK_SYM_OP_SQBR:    %s", yytext);printf(" (0x%x)\n", TK_SYM_OP_SQBR);} 
\]                            {printf("TK_SYM_CL_SQBR:    %s", yytext);printf(" (0x%x)\n", TK_SYM_CL_SQBR);} 
\(                            {printf("TK_SYM_OP_BR:      %s", yytext);printf(" (0x%x)\n", TK_SYM_OP_BR);} 
\)                            {printf("TK_SYM_CL_BR:      %s", yytext);printf(" (0x%x)\n", TK_SYM_CL_BR);} 
\=                            {printf("TK_SYM_ATTR:       %s", yytext);printf(" (0x%x)\n", TK_SYM_ATTR);} 
\,                            {printf("TK_SYM_COMMA:      %s", yytext);printf(" (0x%x)\n", TK_SYM_COMMA);} 
\;                            {printf("TK_SYM_SEMIC:      %s", yytext);printf(" (0x%x)\n", TK_SYM_SEMIC);} 
\&                            {printf("TK_OP_BIT_AND:     %s", yytext);printf(" (0x%x)\n", TK_OP_BIT_AND);} 
\|                            {printf("TK_OP_BIT_OR:      %s", yytext);printf(" (0x%x)\n", TK_OP_BIT_OR);}

[ \t\s]                       {}
%%

int main() {
  yylex();
}