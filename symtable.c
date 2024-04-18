#define HASH_MULTIPLIER 65599
#define BUCKETS 509

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include "symtable.h"

const char *libFunctions[12];
int noname = 0;

int SymTable_hash(const char *value)
{
    size_t ui;
    unsigned int uiHash = 0U;
    for (ui = 0U; value[ui] != '\0'; ui++)
        uiHash = uiHash * HASH_MULTIPLIER + value[ui];

    return uiHash % BUCKETS;
}

SymTable *SymTable_Init(void)
{
    SymTable *newTable = (SymTable *)malloc(sizeof(SymTable));
    SymbolTableEntry *dummy;
    newTable->table = (SymbolTableEntry **)malloc(BUCKETS * sizeof(SymbolTableEntry));
    newTable->scopetable = (SymbolTableEntry **)malloc(BUCKETS * sizeof(SymbolTableEntry));

    unsigned int i = 0;
    unsigned int j = 0;
    for (i = 0; i < BUCKETS; i++)
    {
        newTable->table[i] = NULL;
        newTable->scopetable[i] = NULL;
    }
    insert_symbol(newTable, true, "print", LIBFUNC, newFunction(), newVariable(), 0, 0);
    insert_symbol(newTable, true, "input", LIBFUNC, newFunction(), newVariable(), 0, 0);
    insert_symbol(newTable, true, "objectmemberkeys", LIBFUNC, newFunction(), newVariable(), 0, 0);
    insert_symbol(newTable, true, "objecttotalmembers", LIBFUNC, newFunction(), newVariable(), 0, 0);
    insert_symbol(newTable, true, "objectcopy", LIBFUNC, newFunction(), newVariable(), 0, 0);
    insert_symbol(newTable, true, "totalarguments", LIBFUNC, newFunction(), newVariable(), 0, 0);
    insert_symbol(newTable, true, "argument", LIBFUNC, newFunction(), newVariable(), 0, 0);
    insert_symbol(newTable, true, "typeof", LIBFUNC, newFunction(), newVariable(), 0, 0);
    insert_symbol(newTable, true, "strtonum", LIBFUNC, newFunction(), newVariable(), 0, 0);
    insert_symbol(newTable, true, "sqrt", LIBFUNC, newFunction(), newVariable(), 0, 0);
    insert_symbol(newTable, true, "cos", LIBFUNC, newFunction(), newVariable(), 0, 0);
    insert_symbol(newTable, true, "sin", LIBFUNC, newFunction(), newVariable(), 0, 0);
    dummy = newTable->scopetable[0];
    for (i = 0; i < 12; i++)
    {
        libFunctions[i] = dummy->name;
        dummy = dummy->next_scope;
    }
    free(dummy);
    return newTable;
}
Function *newFunction()
{
    Function *f = (Function *)malloc(sizeof(Function));
    f->numoflocals = 0;
    return f;
}
Variable *newVariable()
{
    Variable *f = (Variable *)malloc(sizeof(Variable));
    return f;
}

// Insert a symbol into the symbol table
SymbolTableEntry *insert_symbol(SymTable *newTable, bool active, char *name, enum SymbolType type, Function *F, Variable *V, int line, int scope)
{
    // Create a new symbol entry
    SymbolTableEntry *new_entry = (SymbolTableEntry *)malloc(sizeof(SymbolTableEntry));
    if (new_entry == NULL)
    {
        // Error: memory allocation failed
        return NULL;
    }

    // Set the values of the new symbol entry
    if (strcmp("$", name) == 0)
    {
        char *s = malloc(100 * sizeof(char));
        strcpy(s, name);
        sprintf(s, "%s%d", name, ++noname);
        new_entry->name = s;
    }
    else
    {
        new_entry->name = strdup(name);
    }
    new_entry->type = type;
    new_entry->line = line;
    new_entry->scope = scope;
    new_entry->isActive = active;
    new_entry->value.varVal = V;
    new_entry->value.funcVal = F;
    new_entry->next_symboltable = NULL;
    new_entry->next_scope = NULL;

    // Insert the new symbol entry at the end of the linked list in the hash table
    unsigned int hash_value = SymTable_hash(name);
    SymbolTableEntry *current = newTable->table[hash_value];
    if (current == NULL)
    {
        // Empty bucket, insert as the first element
        newTable->table[hash_value] = new_entry;
    }
    else
    {
        // Non-empty bucket, traverse to the end and insert
        while (current->next_symboltable != NULL)
        {
            current = current->next_symboltable;
        }
        current->next_symboltable = new_entry;
    }

    // Insert the new symbol entry at the end of the linked list for the same scope
    SymbolTableEntry *current_scope = newTable->scopetable[scope];
    if (current_scope == NULL)
    {
        // Empty list for the same scope, insert as the first element
        newTable->scopetable[scope] = new_entry;
    }
    else
    {
        // Non-empty list for the same scope, traverse to the end and insert
        while (current_scope->next_scope != NULL)
        {
            current_scope = current_scope->next_scope;
        }
        current_scope->next_scope = new_entry;
    }

    return new_entry; // Success
}

void Print_SymTable(SymTable *st)
{
    unsigned int i = 0;
    for (; i < BUCKETS; i++)
    {
        if (st->scopetable[i] != NULL)
        {
            Print_Scope(st, i);
        }
    }
}

void Print_Scope(SymTable *st, int x)
{
    // printf("kaloumeeeeeee\n");
    unsigned int i = 0;
    printf("----------      SCOPE #%d      ----------\n", x);
    for (; i < BUCKETS; i++)
    {
        if (st->scopetable[i] != NULL)
        {
            SymbolTableEntry *tmp = st->scopetable[i];
            do
            {

                if (tmp->scope == x)
                {
                    printf("\"%s\"   [%s]   (line %d)   (scope %d) (offset:%s:%d numoflocals:%u)\n", tmp->name, symbolTypeToString(tmp->type), tmp->line, tmp->scope, symbolspace(tmp->space), tmp->offset, tmp->value.funcVal->numoflocals);
                }
                tmp = tmp->next_scope;
            } while (tmp);
        }
    }
    printf("\n\n");
}

SymbolTableEntry *look_up_function(char *name, SymTable *symtab, int scope)
{
    //  int pos = SymTable_hash(name);
    while (scope >= 0)
    {
        SymbolTableEntry *tmp = symtab->scopetable[scope];
        // printf("MPika me name %s %d\n",name,scope);
        while (tmp != NULL)
        {
            if (tmp->isActive == true)
            {
                if (strcmp(tmp->name, name) == 0)
                {
                    return tmp;
                }
            }
            tmp = tmp->next_scope;
        }
        scope--;
    }
    return NULL;
}

int lookGlobal(char *name, SymTable *symbol)
{

    int pos = SymTable_hash(name);
    SymbolTableEntry *tmp = symbol->table[pos];
    while (tmp != NULL)
    {
        if (tmp->scope == 0)
        {
            if (strcmp(tmp->name, name) == 0)
            {
                return 1;
            }
        }
        tmp = tmp->next_symboltable;
    }

    return 0;
}
const char *symbolspace(enum scopespace_t space)
{
    switch (space)
    {
    case programvar:
        return "programvar";
    case functionlocal:
        return "functionlocal";
    case formalarg:
        return "formalarg";
    default:
        break;
    }
}

const char *symbolTypeToString(enum SymbolType type)
{
    switch (type)
    {
    case GLOBAL:
        return "GLOBAL";
    case LOCALL:
        return "LOCAL";
    case FORMAL:
        return "FORMAL";
    case USERFUNC:
        return "USERFUNC";
    case LIBFUNC:
        return "LIBFUNC";
    default:
        return "UNKNOWN";
    }
}

void Hide(SymTable *st, int x)
{
    unsigned int i = 0;
    for (; i < BUCKETS; i++)
    {
        if (st->scopetable[i] != NULL)
        {
            SymbolTableEntry *tmp = st->scopetable[i];
            do
            {
                if (tmp->scope == x)
                {
                    tmp->isActive = false;
                }
                tmp = tmp->next_scope;
            } while (tmp);
        }
    }

    return;
}

int isLibFunc(char *input)
{
    unsigned int i = 0;
    for (; i < 12; i++)
    {
        if (!strcmp(input, libFunctions[i]))
        {
            return 1;
        }
    }

    return 0;
}
SymbolTableEntry *look_up_function_with_scope(char *name1, SymTable *symtab, int scope)
{

    SymbolTableEntry *tmp = symtab->scopetable[scope];
    // printf("tha psakso me scope %d,",scope);
    if (tmp == NULL)
    {
        /* code */
        return NULL;
    }

    while (tmp != NULL)
    {
        // printf("tha psakso to onoma  %s\n",tmp->name);
        if (strcmp(tmp->name, name1) == 0)
        {
            return tmp;
        }
        tmp = tmp->next_scope;
    }
    return NULL;
}
