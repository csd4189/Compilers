

#include "symtable.h"

#define EXPAND_SIZE 1024
#define CURR_SIZE (total*sizeof(quad))
#define NEW_SIZE (EXPAND_SIZE*sizeof(quad)+CURR_SIZE)


typedef enum iopcode{
    assign,add,sub,
    mul,div1,mod,
    uminus, and ,or,
    not , if_eq, if_noteq,
    if_lesseq,if_greatereq, if_less,
    if_greater,call, param,
    ret, getretval ,funcstart,
    funcend,tablecreate,tablegetelem ,tablesetelem,jump


  
}iopcode;
typedef enum expr_t {
    var_e,
    tableitem_e,
    programmfunc_e,
    libraryfunc_e,
    arithexpr_e,
    boolexpr_e,
    assignexpr_e,
    newtable_e,
    constnum_e,
    constbool_e,
    conststring_e,
    nil_e

}expr_t;
typedef struct expr{
    expr_t type;
    SymbolTableEntry* sym;
    struct  expr* index;
    double NumConst;
    int IntConst;
    char * strConst;
    unsigned char  boolConst;
    struct expr* next;
}expr;

typedef struct  quad
{
    iopcode op;
    expr * result;
    expr * arg1;
    expr * arg2;
unsigned int label;
unsigned int line;

}quad;

typedef enum symbol_t
{
    var_s,
    programfuno_s,
    libraryfuno_s
} symbol_t;

typedef struct call_t {
    expr* elist;
    unsigned char method;
    char * name;

} call_t; 
typedef struct stack_localfunction{
    unsigned offset;
   struct stack_localfunction * next;


}stack_localfunction;


typedef struct for_prefix{
    int test;
    int enter;

}for_prefix;





typedef struct stmt_t {
int breakList, contList;
}stmt_t;

typedef struct StackNode {
    int data;
    struct StackNode* next;
} StackNode;

StackNode* createNode(int data);
int isEmpty(StackNode* root);
void push(StackNode** root, int data);
int pop(StackNode** root);
int mergelist (int l1, int l2);
int newlist (int i);

void make_stmt (stmt_t* s);
int newlist (int (i));
void emit(iopcode op, expr *arg1, expr *arg2, expr *result, unsigned line,unsigned label);
extern struct stack_localfunction *headStack;
extern struct stack_localfunction *headStack2;
void insert_localfunc(unsigned offset);
unsigned pop_localfunc();
unsigned top_localfunc();
int isempty_localfunc();



scopespace_t currscopespace(void);
void inccurrscopeoffset();
unsigned currscopeoffset(void);
void enterscopespace();
void printQuads();
char *expr_to_str(expr *e);
char *opcode_to_str(iopcode op);
unsigned nextquadlabel();

void exitscopespace();
void resetformalarg();
void resetlocalfuncarg();

SymbolTableEntry* newtemp();
char *newtempname();
void resettemp();
expr * newexpr(expr_t name);
expr  *emit_iftableitem(expr* e);
expr * member_item (expr* lv, char* name);
call_t *newCall();
expr *make_call(expr *lv, expr *reversed_elist);
expr *newexpr_conststring(char * name);
const char* expr_t_to_string(expr_t value);

void printExprColumn(expr *expression);
expr *newexpr_constnum(int i);

int check_arith(expr *e);
expr *newexpr_constbool(unsigned int b);
void patchlabel(unsigned quadNo, unsigned label);
void patchlist (int list, int label);