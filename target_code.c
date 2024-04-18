#ifndef _T_CODE_GEN_H_
#define _T_CODE_GEN_H_

typedef struct vmarg vmarg;
typedef struct instruction instruction;
typedef struct userfunc userfunc;
typedef struct incomplete_jump incomplete_jump;

typedef enum avm_opcode{
    assign_v, add_v, sub_v,
    mul_v, div_v, mod_v,
    uminus_v, and_v, or_v,
    not_v, jeq_v, jne_v,
    jle_v, jge_v, jlt_v,
    jgt_v, call_v, pusharg_v,
    funcenter_v, funcexit_v, newtable_v,
    tablegetelem_v, tablesetelem_v, nop_v , jump_v
}avm_opcode;

typedef enum vmarg_t{
    label_a = 0,
    global_a = 1,
    formal_a = 2,
    local_a = 3,
    number_a = 4,
    string_a = 5,
    bool_a = 6,
    nil_a = 7,
    userfunc_a = 8,
    libfunc_a = 9,
    retval_a = 10
}vmarg_t;

struct vmarg{
    vmarg_t type;
    unsigned val;
};

struct instruction{
    avm_opcode opcode;
    vmarg result;
    vmarg arg1;
    vmarg arg2;
    unsigned srcLine;
};

struct userfunc{
    unsigned address;
    unsigned localSize;
    char* id;
};



typedef struct incomplete_jump{
    unsigned instrNo;
    unsigned iaddress;
    struct incomplete_jump* next;
}incomplete_jump;

