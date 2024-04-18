#define HASH_MULTIPLIER 65599
#define BUCKETS 509

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <stdbool.h>
 
typedef struct Variable
{  
    void *value;
   
} Variable;

enum SymbolType
{
    GLOBAL,
    LOCALL,
    FORMAL,
    USERFUNC,
    LIBFUNC
};
typedef enum scopespace_t
{
	programvar,
	functionlocal,
	formalarg
} scopespace_t;

typedef struct Function
{
    int numoflocals;
    int iadress;
   
} Function;

typedef struct SymbolTableEntry
{
     char *name;
    int line;
    int scope;
    bool isActive;
    union
    {
        Variable *varVal;
        Function *funcVal;
    } value;
    unsigned offset;
  
    enum SymbolType type;
    enum scopespace_t space;

    
    struct SymbolTableEntry *next_symboltable;
    struct SymbolTableEntry *next_scope;

    // unsigned-int
} SymbolTableEntry;

typedef struct Symtable
{
    int size;
    struct SymbolTableEntry **table;
    struct SymbolTableEntry **scopetable;
} SymTable;

// Επιστρέφει ποιο bucket θα χρησιμοποιήσουμε
int SymTable_hash(const char *value);

// Κάνει initialize τον Πίνακα Συμβόλων
SymTable *SymTable_Init(void);

// Κάνει εισαγωγή νέου συμβόλου στον Symbol Table
 SymbolTableEntry*  insert_symbol(SymTable* newTable, bool active, char* name, enum SymbolType type,Function *F,Variable *V , int line, int scope);
// Εκτυπώνει τον Πίνακα Συμβόλων.
void Print_SymTable(SymTable *st);

// Εκτυπώνει την λίστα του scope x
void Print_Scope(SymTable *st, int x);

// Ελέγχει εάν υπάρχει ένα σύμβολο με όνομα name στον πίνακα συμβόλων
SymbolTableEntry* look_up_function(char *name, SymTable *symtab,int scope);

int lookGlobal(char* name, SymTable *symbol);
//int look_up_function(char *name, SymTable *symtab, int scope);

// Επιστρέφει την αναπαράσταση string του τύπου τηου συμβόλου
const char *symbolTypeToString(enum SymbolType type);

// Αλλάζει το πεδίο isActive σε 0
void Hide(SymTable *st, int x);

//
int isLibFunc(char *input);
SymbolTableEntry* look_up_function_with_scope(char *name, SymTable *symtab,int scope);
const char *symbolspace( enum scopespace_t space);

Variable* newVariable();
Function* newFunction();