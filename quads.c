#include "quads.h"

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
quad *quads = (quad *)0;
struct stack_localfunction *headStack;
struct stack_localfunction *headStack2;
 StackNode* loopcounterstack =NULL;
unsigned total = 0;
unsigned int currQuad = 0;
unsigned programVarOffset = 0;
unsigned functionlocalOffset = 0;
unsigned formalArgOffset = 0;
unsigned scopeSpaceCounter = 1;
int tempcounter = 0;
extern int yylineno;
extern int current_scope;
extern void red();
extern void green();
extern void yellow();
extern void reset();
extern void blue();
extern void magenta();
extern void cyan();


void expand()
{

    assert(total == currQuad);
    quad *p = (quad *)malloc(NEW_SIZE);
    if (quads)
    {
        memcpy(p, quads, CURR_SIZE);
        free(quads);
    }
    quads = p;
    total += EXPAND_SIZE;
}

void emit(iopcode op, expr *arg1, expr *arg2, expr *result, unsigned line, unsigned label)
{
    if (currQuad == total)
        expand();

    quad *p = quads + currQuad++;
    p->op = op;
    p->arg1 = arg1;
    p->arg2 = arg2;
    p->result = result;
    p->line = line;
    p->label = label;
}

scopespace_t currscopespace(void)
{
    if (scopeSpaceCounter == 1)
        return programvar;
    else if (scopeSpaceCounter % 2 == 0)
        return formalarg;
    else
        return functionlocal;
}

unsigned currscopeoffset(void)
{
    switch (currscopespace())
    {
    case programvar:
        return programVarOffset;
    case functionlocal:
        return functionlocalOffset;
    case formalarg:
        return formalArgOffset;
    default:
        assert(0);
    }
}

void inccurrscopeoffset()
{
    switch (currscopespace())
    {
    case /* constant-expression */ programvar:
        /* code */

        ++programVarOffset;
        break;

    case functionlocal:
        ++functionlocalOffset;
        break;
        ;

    case formalarg:
        ++formalArgOffset;
        break;
    default:
        assert(0);
    }
}
void enterscopespace(void)
{
    ++scopeSpaceCounter;
    printf("Total in %d\n", scopeSpaceCounter);
}
void exitscopespace(void)
{
    assert(scopeSpaceCounter > 1);
    --scopeSpaceCounter;
    printf("Total exitscope %d\n", scopeSpaceCounter);
}
void resetformalarg()
{
    formalArgOffset = 0;
}
void resetlocalfuncarg()
{
    functionlocalOffset = 0;
}
char *newtempname()
{

    char *t = (char *)malloc(sizeof(char) * 100); // allocate memory for the string

    sprintf(t, "t_%d", tempcounter);
    tempcounter++;
    // printf("Exo thema %s %d\n", t,tempcounter);
    return t;
}

SymbolTableEntry *newtemp()
{
    // printf("Geiaaaaaaaaaa\n");
    extern SymTable *symbolTable;

    char *name = newtempname();
    SymbolTableEntry *tmp = NULL;

    if (tmp == NULL)
    {
        tmp = insert_symbol(symbolTable, true, name, LOCALL, newFunction(), newVariable(), yylineno, current_scope);
        // tempcounter++;
        return tmp;
    }
    return NULL;
}

void resettemp() { tempcounter = 0; }
void insert_localfunc(unsigned offset)
{
    stack_localfunction *new = (stack_localfunction *)malloc(sizeof(stack_localfunction));
    new->offset = offset;
    new->next = headStack;
    headStack = new;
      printf("!!!!!!!!!!!!!!!!!!!!!molis evala sthn stoiva:%d kai exw top:%d\n",offset,top_localfunc());
    return;
}

unsigned pop_localfunc()
{
    if (headStack == NULL)
    {
        printf("Stack is empty.\n");
        return 0;
    }
    stack_localfunction *temp = headStack;
    unsigned offset = temp->offset;
    headStack = temp->next;
    free(temp);
      printf("######################KANW POP ME OFFSET: %d\n", offset);
    return offset;
}

unsigned top_localfunc()
{
    if (headStack == NULL)
    {
        printf("Stack is empty.\n");
        return 0;
    }
    return headStack->offset;
}
int isempty_localfunc()
{
    if (headStack == NULL)
        return 1;
    return 0;
}
void insert_localfunc2(unsigned offset)
{
    stack_localfunction *new = (stack_localfunction *)malloc(sizeof(stack_localfunction));
    new->offset = offset;
    new->next = headStack2;
    headStack2 = new;
    // printf("!!!!!!!!!!!!!!!!!!!!!molis evala sthn stoiva:%d kai exw top:%d\n",offset,top_localfunc());
    return;
}

unsigned pop_localfunc2()
{
    if (headStack == NULL)
    {
        printf("Stack is empty.\n");
        return 0;
    }
    stack_localfunction *temp = headStack2;
    unsigned offset = temp->offset;
    headStack2 = temp->next;
    free(temp);
    //  printf("######################KANW POP ME OFFSET: %d\n", offset);
    return offset;
}

unsigned top_localfunc2()
{
    if (headStack2 == NULL)
    {
        printf("Stack is empty.\n");
        return 0;
    }
    return headStack2->offset;
}
int isempty_localfunc2()
{
    if (headStack2 == NULL)
        return 1;
    return 0;
}

expr *newexpr(expr_t name)
{
    expr *newnode = (expr *)malloc(sizeof(expr));
    memset(newnode, 0, sizeof(expr));
    newnode->type = name;
    return newnode;
}

expr *member_item(expr *lv, char *name)
{
    printf("%s ",name);
    lv = emit_iftableitem(lv);       // Emit code if r-value use of table item
    expr *ti = newexpr(tableitem_e); // Make a new expression
    ti->sym = lv->sym;
    ti->index = newexpr_conststring(name);
    return ti;
}

expr *emit_iftableitem(expr *e)
{
    //printf("EImai edo eimai edo re malaka me onoma \n");

    if (strcmp("tableitem_e", expr_t_to_string(e->type)) != 0)
    {
        printf("EImai edo eimai edo re malaka me onoma %s\n", e->sym->name);
        return e;
    }
    else
    {

       // printf("mipos eimai edo  me onoma  %s\n", e->sym->name);
        expr *result = newexpr(var_e);
        result->sym = newtemp();
        emit(tablegetelem, e, e->index, result, yylineno, 0);
        return result;
    }
}
unsigned nextquadlabel()
{
    return currQuad+1;
}

call_t *newCall()
{
    call_t *new_call = (call_t *)malloc(sizeof(call));
    memset(new_call, 0, sizeof(call_t));
    return new_call;
}

expr *make_call(expr *lv, expr *reversed_elist)
{
    expr *func = emit_iftableitem(lv);
    printf("Vgika\n");
    //  printf("%s ", lv->sym->name);
    while (reversed_elist != NULL)
    {
        emit(param, reversed_elist, NULL, NULL, yylineno, 0);
        reversed_elist = reversed_elist->next;
    }

    emit(call, func, NULL, NULL, yylineno, 0);

    expr *result = newexpr(var_e);
    result->sym = newtemp();

    emit(getretval, NULL, NULL, result, yylineno, 0);
    return result;
}

const char *expr_t_to_string(expr_t value)
{
    switch (value)
    {
    case var_e:
        return "var_e";
    case tableitem_e:
        return "tableitem_e";
    case programmfunc_e:
        return "programmfunc_e";
    case libraryfunc_e:
        return "libraryfunc_e";
    case arithexpr_e:
        return "arithexpr_e";
    case boolexpr_e:
        return "boolexpr_e";
    case assignexpr_e:
        return "assignexpr_e";
    case newtable_e:
        return "newtable_e";
    case constnum_e:
        return "constnum_e";
    case constbool_e:
        return "constbool_e";
    case conststring_e:
        return "conststring_e";
    case nil_e:
        return "nil_e";
    default:
        return "Unknown enum value";
    }
}
void printQuads()
{
    //  printf("Quad\tOpcode\t\tResult\t\tArg1\tArg2\tLabel\n");
    for (int i = 0; i < currQuad; i++)
    {
        red();
        printf("Quad%d:\t", i+1);
        if(strcmp(opcode_to_str(quads[i].op),"if_eq")==0)
        green();
        printf( "%s\t", opcode_to_str(quads[i].op));
        if( strcmp(opcode_to_str(quads[i].op),"jump")==0) {
            printf("%d", quads[i].label);
            cyan();
        printf("\t\t[Line] %d\n",quads[i].line);
        }
        
        else{
        yellow();
        printf("Result: ");
        printExprColumn(quads[i].result);
        green();
        printf("arg1:");
        printExprColumn(quads[i].arg1);
        blue();
        printf("arg2:");
 
        printExprColumn(quads[i].arg2);
magenta();
        
        cyan();
        printf("label:%d", quads[i].label);
        printf("\t\t[Line] %d\n",quads[i].line);
        }
    }
}

void printExprColumn(expr *expression)
{
    if (expression == NULL)
    {
        printf("    \t");
        return;
    }

    switch (expression->type)
    {
    case var_e:
        printf("[%s]\t", expression->sym->name);
        break;
    case tableitem_e:
        printf("[%s]\t", expression->sym->name);
        break;
    case programmfunc_e:
        printf("[%s]\t", expression->sym->name);
        break;
    case libraryfunc_e:
        printf("[%s]\t", expression->sym->name);
        break;
    case arithexpr_e:
        printf("%s\t", expression->sym->name);

        break;
    case boolexpr_e:
 printf("%s\t", expression->sym->name);
        break;
    case assignexpr_e:
        printf("%s\t", expression->sym->name);
        break;
    case newtable_e:
        printf("%s\t", expression->sym->name);
        break;
    case constnum_e:
        printf("[ %f]\t", expression->NumConst);
        break;
    case constbool_e:
        if (/* condition */expression->boolConst==1)
        {
            /* code */
             printf("true\t\t");
        }else{
            printf("false\t\t");
        }
        
       
        break;
    case conststring_e:
        printf("[%s]\t", expression->strConst);
        break;
    case nil_e:
        printf("nil");
        break;
    }
}

char *opcode_to_str(iopcode op)
{
    switch (op)
    {
    case assign:
        return "assign";
    case add:
        return "add";
    case sub:
        return "sub";
    case mul:
        return "mul";
    case div1:
        return "div";
    case mod:
        return "mod";
    case uminus:
        return "uminus";
    case and:
        return "and";
    case or:
        return "or";
    case not:
        return "not";
    case if_eq:
        return "if_eq";
    case if_noteq:
        return "if_noteq";
    case if_lesseq:
        return "if_lesseq";
    case if_greatereq:
        return "if_greatereq";
    case if_less:
        return "if_less";
    case if_greater:
        return "if_greater";
    case call:
        return "call";
    case param:
        return "param";
    case ret:
        return "ret";
    case getretval:
        return "getretval";
    case funcstart:
        return "funcstart";
    case funcend:
        return "funcend";
    case tablecreate:
        return "tablecreate";
    case tablegetelem:
        return "tablegetelem";
    case tablesetelem:
        return "tablesetelem";
    case jump:
        return "jump";
    default:
        return "unknown";
    }
}
expr *newexpr_constnum(int i)
{
    expr *e = newexpr(constnum_e);
    e->NumConst = i;
    return e;
}

int check_arith(expr *e)
{
    if (e->type == constbool_e ||
        e->type == conststring_e ||
        e->type == nil_e ||
        e->type == newtable_e ||
        e->type == programmfunc_e ||
        e->type == libraryfunc_e ||
        e->type == boolexpr_e)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}
expr *newexpr_conststring(char *name)
{
    expr *e = newexpr(conststring_e);
    e->strConst = strdup(name);
    return e;
}
void patchlabel(unsigned quadNo, unsigned label)
{
    printf("patchlabel\n");
   // assert(quadNo-1 < currQuad&& !quads[quadNo-1].label );//&& !quads[quadNo-1].label
    quads[quadNo-1].label = label;
}
void make_stmt (stmt_t* s)
{ s->breakList = s->contList = 0; }

int newlist (int i)
{ quads[i-1].label = 0; return i; }
expr *newexpr_constbool(unsigned int b)
{
    expr *e = newexpr(constbool_e);
    e->boolConst = !!b;
    return e;
}

void patchlist(int list, int label)
{ printf("mpika pats me list:%d,labe:%d",list,label);
    while (list)
    {
        int next = quads[list-1].label;
        quads[list-1].label = label;
        list = next;
    }
}

int mergelist (int l1, int l2) {
    
if (!l1){ 
return l2;}
else
if (!l2){
return l1;}
else {
    
int i = l1;
while (quads[i-1].label)
i = quads[i-1].label;
quads[i-1].label = l2;
return l1;
}
}



StackNode* createNode(int data) {
    StackNode* newNode = (StackNode*)malloc(sizeof(StackNode));
    newNode->data = data;
    newNode->next = NULL;
    return newNode;
}

int isEmpty(StackNode* root) {
    return !root;
}

void push(StackNode** root, int data) {
    StackNode* newNode = createNode(data);
    newNode->next = *root;
    *root = newNode;
    printf("Pushed %d onto the stack.\n", data);
}

int pop(StackNode** root) {
    if (isEmpty(*root)) {
        printf("Stack is empty. Cannot pop element.\n");
        return -1;
    }

    StackNode* temp = *root;
    *root = (*root)->next;
    int popped = temp->data;
    free(temp);
    printf("Popped %d from the stack.\n", popped);
    return popped;
}