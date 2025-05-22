enum {
  TK_PR_AS=0x100,
  TK_PR_DECLARE,
  TK_PR_ELSE,
  TK_PR_FLOAT,
  TK_PR_IF,
  TK_PR_INT,
  TK_PR_IS,
  TK_PR_RETURN,
  TK_PR_RETURNS,
  TK_PR_WHILE,
  TK_PR_WITH
};

enum {
  TK_OC_LE=0x200,
  TK_OC_GE,
  TK_OC_EQ,
  TK_OC_NE
};

enum{
  TK_ID=0x300,
  TK_LIT_INT,
  TK_LIT_FLOAT
};

enum {
  TK_OP_NOT='!',
  TK_OP_MULT='*',
  TK_OP_DIV='/',
  TK_OP_MOD='%',
  TK_OP_ADD='+',
  TK_OP_SUB='-',
  TK_OP_LESS='<',
  TK_OP_GREATER='>',
  TK_SYM_OP_SQBR='[',
  TK_SYM_CL_SQBR=']',
  TK_SYM_OP_BR='(',
  TK_SYM_CL_BR=')',
  TK_SYM_ATTR='=',
  TK_SYM_COMMA=',',
  TK_SYM_SEMIC=';',
  TK_OP_BIT_AND='&',
  TK_OP_BIT_OR='|',
};