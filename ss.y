%{

  #include "quads.h"

  #define YY_DECL int alpha_yylex(void *yylval)


  
  void yyerror(char* yaccProvideMessage);
int loopcount=0;
  extern int yylineno;
  extern char *yytext;
  extern unsigned programVarOffset;
  extern int functionlocalOffset;
  extern unsigned formalArgOffset;
  extern int scopeSpaceCounter ;
  int total_functionlocals=0;
  StackNode* loopcounterstack =NULL;
  int nonames=0;
  extern FILE* yyin;
  extern int yylex();
  

    unsigned int isFunc=0;
    unsigned function_local=0;
  SymTable* symbolTable;
  int current_scope=0;
  int func_op=0;
  int inside_loop=0;
void blue(){
  printf("\e[0;34m");
}
void red () {
  printf("\033[1;31m");
}

void yellow() {
  printf("\033[1;33m");
}

void reset () {
  printf("\033[0m");
}
void green(){
  printf("\e[0;32m");
}
void cyan() {
    printf("\033[0;36m");
}

void magenta() {
    printf("\033[0;35m");
}



void check_op_Func(SymbolTableEntry *check,int * func){
      if(strcmp(symbolTypeToString(check->type),"USERFUNC")==0 || strcmp(symbolTypeToString(check->type),"LIBFUNC")==0 ){

        *func=1;
        printf("Vrika to symbolo ayto  %s %d\n",check->name,*func);
      }else{
        *func=0;
        printf("Vrika to symbolo aytosss %s %d\n",check->name,*func);

      }


}




%}

/* %define parse.error verbose */
%start program

%union {
  char* stringValue;
  int   intValue; 
  float realValue;
  struct SymbolTableEntry* sym;
  unsigned labelquad;
 struct expr *expr;
 struct for_prefix *for_prefix;

 struct call_t *call; 
struct stmt_t *stmt;
}





%token  IF
%token  ELSE
%token  FOR
%token  WHILE
%token  RETURN
%token  FUNCTION
%token  BREAK
%token  CONTINUE
%token  AND
%token  NOT
%token  OR
%token  LOCAL
%token  TRUE 
%token  FALSE 
%token  NIL

%token  ASSIGN
%token  ADD
%token  MINUS
%token  MUL
%token  DIV
%token  PERCENT
%token  EQUAL 
%token  NOT_EQUAL 
%token  INCREMENT 
%token  DECREMENT
%token  GREATER_THAN
%token  LESS_THAN
%token  GREATER_EQUAL
%token  LESS_EQUAL
%token  LEFT_CURLY_BRACKET
%token  RIGHT_CURLY_BRACKET
%token  LEFT_BRACKET
%token  RIGHT_BRACKET
%token  RIGHT_PARENTHESIS
%token  LEFT_PARENTHESIS
%token  SEMICOLON
%token  COLON
%token  DOUBLE_COLON
%token  COMMA
%token  DOT
%token  DOUBLE_DOT
%type<stringValue> funcname
%type <expr> funprefix  
%type <intValue> M N 
%type <for_prefix> forprefix;
%token <intValue>    INT_CONST
%token <realValue>   REAL_CONST
%token <stringValue> STRING
%token <stringValue> IDENTIFIER 
%type <sym> funcdef
%type <intValue> ifprefix elseprefix
%type <labelquad> whilestart whilecond
%type <stmt> stmt loopstmt break continue stmts block stmt_opt whilestmt forstmt returnstmt ifstmt function
%type <expr> lvalue expr member primary call elist objectdef const term assignexpr indexed indexedelem indexedelem_list 
%type <call> normcall callsuffix methodcall 


%right ASSIGN
%left OR
%left AND
%nonassoc EQUAL NOT_EQUAL
%nonassoc  GREATER_THAN GREATER_EQUAL LESS_THAN LESS_EQUAL
%left ADD MINUS
%left MUL DIV PERCENT
%right NOT DECREMENT INCREMENT UMINUS
%left DOT DOUBLE_DOT
%left LEFT_BRACKET RIGHT_BRACKET
%left LEFT_PARENTHESIS RIGHT_PARENTHESIS



%%

program :  {insert_localfunc(-1);}   stmts 
               
              ;
            
stmts:        stmt {resettemp();}stmts{
  
printf("ssssss");
  

}
              |{printf("kenooo\n");$$= (struct stmt_t *)malloc(sizeof(struct  stmt_t));}
              
              ;

stmt:           expr SEMICOLON {printf("expr semicolon;\n");$$= (struct stmt_t *)malloc(sizeof(struct  stmt_t));}
              | ifstmt {printf("IF statement\n");$$=$1;}
              | whilestmt{printf("while statement\n");$$=$1;}
              | forstmt {printf("FOR statement\n");$$=$1;}
              | returnstmt{			printf("RETURN statement\n");$$=$1;}
              | break   { printf("Break semicolon\n");$$=$1;}
              | continue{printf("Continue semicolon\n");$$=$1;}
              | block{printf("Block\n");$$=$1;}
              | function{printf("function defintions\n");$$= (struct stmt_t *)malloc(sizeof(struct  stmt_t));}
              | SEMICOLON{printf("--> ; <--\n");$$= (struct stmt_t *)malloc(sizeof(struct  stmt_t));}
              ;


function:funcdef{$$= (struct stmt_t *)malloc(sizeof(struct  stmt_t));}







continue:CONTINUE SEMICOLON{
    if(loopcount==0){red();printf("Error:cannot use continue outside of a loop\n");reset();}
 $$= (struct stmt_t *)malloc(sizeof(struct  stmt_t));
make_stmt($$);
$$->contList = newlist(nextquadlabel());
 emit(jump,NULL,NULL,NULL,yylineno,0); 

}              
break: BREAK SEMICOLON{

              $$= (struct stmt_t *)malloc(sizeof(struct  stmt_t));
                 if(loopcount==0){red();printf("Error:cannot use break outside of a loop\n");reset();}
               make_stmt($$); 
               
             $$->breakList = newlist(nextquadlabel()); 
             
             emit(jump,NULL,NULL,NULL,yylineno,0); 
                
            

}
expr:          assignexpr {printf("Expr=Expr %d\n",yylineno);}
              |expr ADD expr {printf("Expr+Expr %d\n",yylineno);  
                                  $$ = newexpr(arithexpr_e);
                                  char *s=newtempname();
                                 $$->sym = insert_symbol(symbolTable,1,s,LOCALL,newFunction(),newVariable(),yylineno,current_scope);
                                  emit(add,$1,$3,$$,yylineno,0);}
              |expr MINUS expr {printf("Expr-Expr %d\n",yylineno);   $$ = newexpr(arithexpr_e);
                                $$->sym = insert_symbol(symbolTable,1,newtempname(),LOCALL,newFunction(),newVariable(),yylineno,current_scope); 
                                  emit(sub,$1,$3,$$,yylineno,0); }
              |expr MUL expr {printf("Expr*Expr %d\n",yylineno);     $$ = newexpr(arithexpr_e);
                                $$->sym = insert_symbol(symbolTable,1,newtempname(),LOCALL,newFunction(),newVariable(),yylineno,current_scope);
                                  emit(mul,$1,$3,$$,yylineno,0);} 
              |expr DIV expr {printf("Expr/Expr %d\n",yylineno);    $$ = newexpr(arithexpr_e);
                                $$->sym = insert_symbol(symbolTable,1,newtempname(),LOCALL,newFunction(),newVariable(),yylineno,current_scope); 
                                  emit(div1,$1,$3,$$,yylineno,0);}
              |expr PERCENT expr{printf("Expr%%Expr %d\n",yylineno);  
                 $$ = newexpr(arithexpr_e);
                                $$->sym = insert_symbol(symbolTable,1,newtempname(),LOCALL,newFunction(),newVariable(),yylineno,current_scope); 
                                  emit(mod,$1,$3,$$,yylineno,0);}
             
             
             
             
             
              |expr GREATER_THAN expr{
                printf("Expr>Expr %d\n",yylineno);
                 $$ = newexpr(boolexpr_e);
   $$->sym = insert_symbol(symbolTable,1,newtempname(),LOCALL,newFunction(),newVariable(),yylineno,current_scope); 
            emit(if_greater,$1,$3,NULL,yylineno,nextquadlabel()+3);
            emit(assign,newexpr_constbool(0),NULL,$$,yylineno,0);
            emit(jump,NULL,NULL,NULL,yylineno,nextquadlabel()+2);
            emit(assign,newexpr_constbool(1),NULL,$$,yylineno,0);
                
                
                
                
                }
              |expr GREATER_EQUAL expr{
                printf("Expr>=Expr %d\n",yylineno);
                 $$ = newexpr(boolexpr_e);
   $$->sym = insert_symbol(symbolTable,1,newtempname(),LOCALL,newFunction(),newVariable(),yylineno,current_scope); 
            emit(if_greatereq,$1,$3,NULL,yylineno,nextquadlabel()+3);
            emit(assign,newexpr_constbool(0),NULL,$$,yylineno,0);
            emit(jump,NULL,NULL,NULL,yylineno,nextquadlabel()+2);
            emit(assign,newexpr_constbool(1),NULL,$$,yylineno,0);
                }
              |expr LESS_THAN expr  {
                printf("Expr<Expr %d\n",yylineno);
             
                 $$ = newexpr(boolexpr_e);
   $$->sym = insert_symbol(symbolTable,1,newtempname(),LOCALL,newFunction(),newVariable(),yylineno,current_scope); 
            emit(if_less,$1,$3,NULL,yylineno,nextquadlabel()+3);
            emit(assign,newexpr_constbool(0),NULL,$$,yylineno,0);
            emit(jump,NULL,NULL,NULL,yylineno,nextquadlabel()+2);
            emit(assign,newexpr_constbool(1),NULL,$$,yylineno,0);
                
                }
              |expr LESS_EQUAL expr {
                printf("Expr<=Expr %d\n",yylineno);
                $$ = newexpr(boolexpr_e);
   $$->sym = insert_symbol(symbolTable,1,newtempname(),LOCALL,newFunction(),newVariable(),yylineno,current_scope); 
            emit(if_lesseq,$1,$3,NULL,yylineno,nextquadlabel()+3);
            emit(assign,newexpr_constbool(0),NULL,$$,yylineno,0);
            emit(jump,NULL,NULL,NULL,yylineno,nextquadlabel()+2);
            emit(assign,newexpr_constbool(1),NULL,$$,yylineno,0);
                
                }
              |expr EQUAL expr {
                printf("Expr==Expr %d\n",yylineno);
                 $$ = newexpr(boolexpr_e);
   $$->sym = insert_symbol(symbolTable,1,newtempname(),LOCALL,newFunction(),newVariable(),yylineno,current_scope); 
            emit(if_eq,$1,$3,NULL,yylineno,nextquadlabel()+3);
            emit(assign,newexpr_constbool(0),NULL,$$,yylineno,0);
            emit(jump,NULL,NULL,NULL,yylineno,nextquadlabel()+2);
            emit(assign,newexpr_constbool(1),NULL,$$,yylineno,0);
                
                
                }
              |expr NOT_EQUAL expr {
                printf("Expr!=Expr %d\n",yylineno);
                  $$ = newexpr(boolexpr_e);
                   $$->sym = insert_symbol(symbolTable,1,newtempname(),LOCALL,newFunction(),newVariable(),yylineno,current_scope); 
            emit(if_noteq,$1,$3,NULL,yylineno,nextquadlabel()+3);
            emit(assign,newexpr_constbool(0),NULL,$$,yylineno,0);
            emit(jump,NULL,NULL,NULL,yylineno,nextquadlabel()+2);
            emit(assign,newexpr_constbool(1),NULL,$$,yylineno,0);
                }
              |expr AND expr {
                printf("Expr AND expr %d\n",yylineno);
              $$ = newexpr(boolexpr_e);
              $$->sym = insert_symbol(symbolTable,1,newtempname(),LOCALL,newFunction(),newVariable(),yylineno,current_scope); 
              emit(and, $1 , $3, $$,yylineno,0);
              }
              |expr OR expr{
                printf("Expr or expr  %d \n ",yylineno);
                 printf("Expr AND expr %d\n",yylineno);
              $$ = newexpr(boolexpr_e);
              $$->sym = insert_symbol(symbolTable,1,newtempname(),LOCALL,newFunction(),newVariable(),yylineno,current_scope); 
              emit(or, $1 , $3, $$,yylineno,0);
                
                }
              |term{printf("Terminal %d\n",yylineno);$$=$1;$$=(struct expr*)malloc(sizeof(struct expr));}
              ;

term:         LEFT_PARENTHESIS expr RIGHT_PARENTHESIS{ printf("( expression )\n"); $<expr>$=$<expr>2; }





              |MINUS expr %prec UMINUS  { 
                                          printf("-expression\n");
                                          if(check_arith($2)==0){                  
                                            $<expr>$ = newexpr(arithexpr_e);
                                            $<expr>$->sym = newtemp();
                                            emit(uminus,$2, NULL, $$,yylineno,0);  
                                          }else{
                                            red();
                                            printf("ERROR: Illegal (non arithmetic) expression used in line  %d",yylineno);
                                            reset();
                                          }
                                        }
              |NOT expr{ printf("!expression\n");
              
              $$ = newexpr(boolexpr_e);
              $$->sym = newtemp();
             emit(not,$2, NULL, $$,yylineno,0);

              
              }
              |INCREMENT lvalue  {
                                    printf("Incremenet value %d\n", func_op);
                                    if (func_op == 1)
                                    {
                                      red();
                                      printf("Error function operator\n");
                                    }
                                    reset();
                                    check_arith($<expr>2);
                                    // $<expr>$ = newexpr(var_e);
                                    // $<expr>$->sym = newtemp();
                                    if ($<expr>2->type == tableitem_e){
                                      // expr *val = emit_iftableitem($<expr>2);
                                      //emit(assign, val, NULL, $<expr>$,yylineno);
                                      $$ = emit_iftableitem($2);
                                      emit(add, $<expr>$, newexpr_constnum(1), $<expr>$,yylineno,0);
                                      emit(tablesetelem, $<expr>2, $<expr>2->index, $<expr>$,yylineno,0);
                                    }else{
                                      emit(add, $<expr>2, newexpr_constnum(1), $<expr>2,yylineno,0);
                                      $<expr>$ = newexpr(arithexpr_e);
                                      $<expr>$->sym = newtemp();
                                      emit(assign, $<expr>2, NULL, $<expr>$,yylineno,0);
                                    }
                                  }
              |lvalue INCREMENT {
                                  printf("lvalue ++ (func_op=%d)\n",func_op);
                                  if(func_op==1){
                                    red();
                                    printf("Error function operator\n");
                                  }
                                  reset(); 
                                  check_arith($1);
                                  $$ = newexpr(var_e);
                                  $$->sym = newtemp();
                                  if(tableitem_e == $1->type){
                                    expr* val = emit_iftableitem($1);
                                    emit(assign, val, NULL, $$, yylineno,0);
                                    emit(add, val, newexpr_constnum(1), val,yylineno,0);
                                    emit(tablesetelem, $1, $1->index, val,yylineno,0);
                                  }else{
                                    emit(assign, $1, NULL, $$,yylineno,0);
                                    emit(add, $1, newexpr_constnum(1), $1,yylineno,0);
                                  }
                                }
              |DECREMENT lvalue {
                                  printf("-- value (func_op=%d)\n",func_op);
                                  if(func_op==1){
                                    red();
                                    printf("Error function operator\n");
                                  }
                                  reset(); 
                                  check_arith($<expr>2);
                                  if ($2->type == tableitem_e){
                                    $$ = emit_iftableitem($2);
                                    emit(sub, $$, newexpr_constnum(1), $$,yylineno,0);
                                    emit(tablesetelem, $2, $2->index, $$,yylineno,0);
                                  }else{
                                    emit(sub, $2, newexpr_constnum(1), $2,yylineno,0);
                                    $$ = newexpr(arithexpr_e);
                                    $$->sym = newtemp();
                                    emit(assign, $2, NULL, $$,yylineno,0);
                                  }
                                }
              |lvalue DECREMENT { 
                                  printf("lvalue -- (func_op=%d)\n",func_op);
                                  if(func_op==1){
                                    red();
                                    printf("Error function operator\n");
                                  }
                                  reset(); 
                                  check_arith($1);
                                  $$ = newexpr(var_e);
                                  $$->sym = newtemp();
                                  if(tableitem_e == $1->type){
                                    expr* val = emit_iftableitem($1);
                                    emit(assign, val, NULL, $$, yylineno,0);
                                    emit(sub, val, newexpr_constnum(1), val,yylineno,0);
                                    emit(tablesetelem, $1, $1->index, val,yylineno,0);
                                  }else{
                                    emit(assign, $1, NULL, $$,yylineno,0);
                                    emit(sub, $1, newexpr_constnum(1), $1,yylineno,0);
                                  }
                                }
              |primary{ $$=$1;}    
              ;
assignexpr:   lvalue ASSIGN expr{
          if(strcmp("tableitem_e",expr_t_to_string($1->type))==0){
            printf("Vrika ayto to symbolo %s",expr_t_to_string($1->type));
                        emit(tablesetelem,$1,$1->index,$3,yylineno,0);
            $$=emit_iftableitem($1);
            $$->type=assignexpr_e;
          }else{
            emit(assign,$3,NULL, $1,yylineno,0);
            $$=newexpr(assignexpr_e);
            $$->sym=newtemp();
              emit(assign,$1,NULL,$$,yylineno,0);
          }

 };










primary:      lvalue{
                          $$ = emit_iftableitem($1); }
              |call{printf("Call\n");}
              |objectdef{printf("Object definition\n"); $$=$1;}
              |LEFT_PARENTHESIS funcdef RIGHT_PARENTHESIS{printf("(Function definition)\n");}
              |const{printf("Constant  %s\n",expr_t_to_string($1->type)); $$=$1;}
              ;
lvalue:       IDENTIFIER                      {
                                        
                                               printf("Identifier\n");
                                               SymbolTableEntry* doesExist = NULL;

                                                doesExist = look_up_function($1, symbolTable,current_scope);
                                                if(doesExist==NULL){
                                                  if(current_scope==0){

                                                  green();
                                                 doesExist=insert_symbol(symbolTable, true, $1, GLOBAL,newFunction(),newVariable(), yylineno, 0);
                                                 doesExist->space= currscopespace();
                                                  doesExist->offset= top_localfunc()+1;
                                                  pop_localfunc();
                                                  insert_localfunc(doesExist->offset);
                                                  total_functionlocals=doesExist->offset;
                                                  inccurrscopeoffset();
                                                     $$=newexpr(var_e);
                                                    $$->sym = doesExist;
                                                    printf("The symbol with %s inserted in line %d\n",$1,yylineno);
                                                    reset();
                                                  }else{
                                                  doesExist=insert_symbol(symbolTable, true, $1, LOCALL,newFunction(),newVariable(), yylineno, current_scope);
                                                  doesExist->space= currscopespace();
                                                   doesExist->offset= top_localfunc()+1;
                                                  pop_localfunc();
                                                  insert_localfunc(doesExist->offset);
                                                  total_functionlocals=doesExist->offset;
                                                  $$=newexpr(var_e);
                                                  $$->sym = doesExist;
                                                  
                              
                                                  inccurrscopeoffset();       
                                                  green();
                                                  printf("The symbol with %s inserted in line %d\n",$1,yylineno);
                                                  reset();
                                                  }
                                                }else{
                                                  
                                                      yellow();
                                                      printf(" %d WE find the symbol with this index is  name:  %s  , line : %d , scope : %d, type: %s  %d \n",yylineno,doesExist->name,doesExist->line, doesExist->scope,symbolTypeToString(doesExist->type),isFunc);
                                                   //   $$->sym = doesExist;
                                                   
                                                      reset();
                                                  if(isLibFunc($1)){ 
                                                    blue();
                                                    printf("I ve the id symbol with refers to library function %s \n" ,doesExist->name);
                                                    reset();
                                                      $$=newexpr(libraryfunc_e);
                                                      $$->sym = doesExist;
                                                      printf("FInd  this %s",$$->sym->name);
                                                  
                                                  }
                                                 else if(doesExist->scope==0){
                                                    blue();
                                                    printf(" %d You have access is  name:  %s  , line : %d , scope : %d, type: %s   \n",yylineno,doesExist->name,doesExist->line, doesExist->scope,symbolTypeToString(doesExist->type));
                                                    
                                                    $$=newexpr(var_e);
                                                    $$->sym = doesExist;
                                                    
                                                    
                                                    
                                                    
                                                    reset();
                                                  }else if(isFunc>1 && doesExist->scope<current_scope && (strcmp(symbolTypeToString(doesExist->type),"LOCAL")==0 || strcmp(symbolTypeToString(doesExist->type),"FORMAL")==0 )){
                                                     red();
                                                     printf("Error in line   %d refeers to symbol  %s  in line %d %s with scope %d (isfunccounter=%d)(current_scope=%d)\n",yylineno,doesExist->name,doesExist->line,symbolTypeToString(doesExist->type),doesExist->scope,isFunc,current_scope);
                                                     reset();
                                                     }
                                                      else if(strcmp(symbolTypeToString(doesExist->type),"FORMAL")==0 ){
                                                      $$=newexpr(var_e);
                                                      
                                                  $$->sym = doesExist;
                                                     }
                                                     else if(strcmp(symbolTypeToString(doesExist->type),"LOCAL")==0){
                                                           $$=newexpr(var_e);
                                                      
                                                  $$->sym = doesExist;
                                                     }
                                                  if(strcmp(symbolTypeToString(doesExist->type),"USERFUNC")==0){
                                                    yellow();
                                                    printf("You try to aceess to a function in line %d\n",yylineno);
                                                    reset();
                                                    $$=newexpr(programmfunc_e);
                                                    $$->sym=doesExist;
                                                    
                                                  }
                                                  check_op_Func(doesExist,&func_op);  
                                                } 
                                                     
                                              }
              |LOCAL IDENTIFIER               
                                                {
                                                    printf("local idenitfier\n");
                                                 SymbolTableEntry* doesExist ;
                                                doesExist=look_up_function_with_scope($2,symbolTable,current_scope);
                                                if(doesExist==NULL&& !isLibFunc($2) ){
                                                    if(current_scope==0 ){
                                                      green();
                                                      doesExist= insert_symbol(symbolTable, true, $2, GLOBAL,newFunction(),newVariable(), yylineno, 0);
                                                        doesExist->space= currscopespace();
                                                  doesExist->offset=currscopeoffset();
                                                  inccurrscopeoffset();
                                                       printf("Inserted completed with name  %s\n",$2);
                                                         reset();
                                                         $$ = newexpr(var_e);
                                                          $$->sym = doesExist;
                                                       }else{
                                                    doesExist=insert_symbol(symbolTable, true, $2, LOCALL,newFunction(),newVariable(), yylineno, current_scope);
                                                      doesExist->space= currscopespace();
                                                      doesExist->offset=currscopeoffset();
                                                      inccurrscopeoffset();
                                                      green();
                                                      printf("Inserted completed with name %s\n",$2);
                                                      reset();
                                                      
                                                        $$ = newexpr(var_e);
                                                        $$->sym = doesExist;
                                                     }
                                                
                                                }else if(isLibFunc($2) && current_scope!=0){
                                                  red();
                                                   printf("Error %d you try to shadow  a library function  in line \n",yylineno);
                                                  reset();
                                                }else if(doesExist->isActive==false && (strcmp("USERFUNC",symbolTypeToString(doesExist->type))!=0)&&(strcmp("LIBFUNC",symbolTypeToString(doesExist->type))!=0))
                                                
                                                    {
                                                    doesExist=  insert_symbol(symbolTable, true, $2, LOCALL,newFunction(),newVariable(), yylineno, current_scope);
                                                      doesExist->space= currscopespace();
                                                  doesExist->offset=currscopeoffset();
                                                  inccurrscopeoffset();
                                                    $$ = newexpr(var_e);
                                                          $$->sym = doesExist;
                                                      blue();
                                                      printf("Inserted completed with name %s\n",$2);
                                                      reset();
                                                    }
                                           
                                                 
                                               
                                               }
                                               
                                               
                                              
              |DOUBLE_COLON IDENTIFIER        { 
                                            // $$=$1;
                                                    
                                                 SymbolTableEntry* doesExist = look_up_function($2,symbolTable,0);
                                                if(doesExist){
                                            
                                                  printf("\e[0;34m Found it, continue.\e[m \n ");
                                                    $$ = newexpr(var_e);
                                                    $$->sym = doesExist;
                                                }else {
                                                  red();
                                           
                                                  printf("\e[0;31m Error. Not in global scope.in line %d \e[m",yylineno);
                                                  reset();
                                                }
                                              }
              |member{$$=$1;}
            
              ;
member:       lvalue DOT IDENTIFIER{printf("lvalue.ID\n"); $$=member_item($1,$3); printf("Telos \n");}	
              |lvalue LEFT_BRACKET expr RIGHT_BRACKET{
                                    printf("lvalue[expr]\n"); 
                                          $1= emit_iftableitem($1);
                                          $$ = newexpr(tableitem_e);
                                    
                                         $$->sym = $1->sym;
                                        printf("Tha anaferrhtsei se ayto  %s\n",$$->sym->name);
                                        $$->index = $3; 
              
              
              
              
                                                    }
              |call DOT IDENTIFIER{printf("call.id\n");}
              |call LEFT_BRACKET expr RIGHT_BRACKET{printf("Call[expr]\n");}
              ;
call:         call LEFT_PARENTHESIS elist RIGHT_PARENTHESIS{ $$ = make_call($1, $3); 





}
              |lvalue callsuffix{
                printf("lvalue callsuffix\n");
                      $1 = emit_iftableitem($1); 
                      if ($2->method){

                    expr* t = $1;
                    $1 = emit_iftableitem(member_item(t, $2->name));
                    $2->elist->next = t; 
                    }
                      $$ = make_call($1, $2->elist);

              }
              |LEFT_PARENTHESIS funcdef RIGHT_PARENTHESIS LEFT_PARENTHESIS elist RIGHT_PARENTHESIS {printf("(funcdef)(Elist)\n");
              
                expr* func = newexpr(programmfunc_e);
                func->sym = $2;
                $$ = make_call(func, $5);}
              
        
callsuffix:   normcall{printf("Normall call\n"); $$=$1;}
	| methodcall		{printf("Method call\n"); $$=$1;  };
  ;

normcall:     LEFT_PARENTHESIS elist RIGHT_PARENTHESIS {printf("(Elist)\n"); 
                  $$=(call_t*)malloc(sizeof(call_t)); 
                $$->elist=$2;
              $$->method=0;
            $$->name=NULL;
}
              ;
methodcall:   DOUBLE_DOT IDENTIFIER LEFT_PARENTHESIS elist RIGHT_PARENTHESIS	{
                  printf("|..ID(Elist)\n");
                  $$=newCall();
                  $$->elist=$4;
                  $$->method=1;
                  $$->name=strdup($2);}
              ;

              ;
elist:         expr {printf("expr sketo  \n"); $$ = $1; $$->next = NULL; }
              |elist COMMA expr {printf("Elist , expr\n");  
                
                $3->next = $1;
                $$ = $3;
                 
                
               
                }
              |{$$=NULL;}
              ;
objectdef:    LEFT_BRACKET elist RIGHT_BRACKET	{

                        expr *t = newexpr(newtable_e);
                          t->sym = newtemp();
                          printf("DOse mot to onoma %s",t->sym->name);
                          emit(tablecreate, NULL, NULL, t,yylineno,0);
                         // printf
                          int i=0;
                            for ( i = 0; $2;   $2 = $2->next){
                              
                              emit(tablesetelem,t , newexpr_constnum(i++), $2,yylineno,0);
                     

                    }
                          $$ = t;
                           
                   
}
              | LEFT_BRACKET indexed RIGHT_BRACKET
              
              {
                expr* t = newexpr(newtable_e);
                t->sym = newtemp();
                emit(tablecreate, t, NULL, NULL,yylineno,0);
                printf("sss");
                int i=0;
                for ( i = 0; $2;   $2 = $2->next){
                              
                emit(tablesetelem,t , $2, $2->index,yylineno,0);
               
               }
               $$ = t;
              }
              ;
indexed:      indexedelem indexedelem_list{$$ = $1; $$->next = $2;}
              ;

indexedelem_list:
              COMMA indexedelem indexedelem_list {$$ = $2; $$->next = $3;}
					    | {$$ = NULL;}
					    ;

indexedelem:  LEFT_CURLY_BRACKET expr COLON expr RIGHT_CURLY_BRACKET	{$$ = $4; $$->index = $2};






block:        LEFT_CURLY_BRACKET{++current_scope; printf("LEft curly  bracket\n");} RIGHT_CURLY_BRACKET{Hide(symbolTable, current_scope--); printf("{ Statement }\n");$$=( stmt_t*)malloc(sizeof( stmt_t));  printf("Right curly bracket\n");
}; 
              | LEFT_CURLY_BRACKET{++current_scope ; } stmt_opt RIGHT_CURLY_BRACKET {Hide(symbolTable, current_scope--);printf("Right curly bracket\n");$$=$3;} 
              ;


loopstart:{loopcount++;};
loopend:{loopcount--;}
loopstmt:loopstart{printf("loopstart\n");} stmt loopend{$$=$3;}
;






stmt_opt:     stmt_opt stmt{

 //$1=(struct stmt_t *)malloc(sizeof(struct  stmt_t));
  //$2=(struct stmt_t *)malloc(sizeof(struct  stmt_t));
  //$$= (struct stmt_t *)malloc(sizeof(struct  stmt_t));
  $$->breakList = mergelist($1->breakList, $2->breakList);
$$->contList = mergelist($1->contList, $2->contList);
//$$=$2;



}
              | { $$=( stmt_t*)malloc(sizeof( stmt_t));printf("keno");}
              ;
funcdef:     funprefix
              
          

          
              LEFT_PARENTHESIS idlist RIGHT_PARENTHESIS { insert_localfunc(-1); enterscopespace(); resetformalarg();}
              funcblockstart block {
                printf("Function block11\n");
             
              
      SymbolTableEntry *tmp=  look_up_function_with_scope($1->sym->name,symbolTable,current_scope);
                //tmp->value.funcVal->numoflocals=pop_localfunc()+1;
         tmp->value.funcVal->numoflocals=pop_localfunc()+1;
         tmp->value.funcVal->iadress=nextquadlabel();
                if(isempty_localfunc()){
                 
                  insert_localfunc(-1);
                }
                
             //  $$ = newexpr(var_e);
                  exitscopespace();
                  exitscopespace();
                   resetlocalfuncarg();
                                     isFunc--;
                                     //$$ = $1; 
                                    emit(funcend, $1, NULL, NULL,yylineno,0);
                                    

                       }
                       funcblockend{
                        
                       }
                       
            
              ;   
funcblockstart:{push(&loopcounterstack, loopcount); loopcount=0;}
funcblockend:{ loopcount = pop(&loopcounterstack); }

funprefix: FUNCTION{ printf("Function keyword\n"); isFunc=isFunc+1;
     
           enterscopespace();} 
          funcname {
 
   
                        int flag=isLibFunc($3);
                                    
                                    if(flag==0){
                                      
                                      SymbolTableEntry *tmp=look_up_function_with_scope($3,symbolTable,current_scope);
                                      if(tmp==NULL){
                                 tmp=insert_symbol(symbolTable,true,$3,USERFUNC,newFunction(),newVariable(),yylineno,current_scope);
                                  tmp->value.funcVal->iadress=nextquadlabel();
                                    $$=newexpr(var_e);
                                    $$->sym=tmp;
                                  
                                   emit(funcstart,$$,NULL,NULL,yylineno,0);
                                
                                      
                                        green();
                                        printf("Inserted the function  with id %s in line  %d",$3,yylineno);
                                        reset();
                                      }else{
                                      red();
                                      printf ("You try to declare a function %s and in the scope %d and line :%d\n",tmp->name,current_scope,yylineno);
                                      reset();
                                        
                                      }
                                    }else{
                                      red();
                                      printf ("You try to declare a library function  in line %d\n",yylineno);
                                      reset();
                                      break;
                                    }}

funcname:        IDENTIFIER{$$=$1;}
              |
              {
        
              char *s = malloc(4 * sizeof(char));
              strcpy(s, "_f");
              sprintf(s,"%s%d",s,++nonames);
              $$=s;
              
              
              }
              ;
                        
const:        INT_CONST{{printf("|NUMBER %s\n",yytext);}
                 $$ = newexpr(arithexpr_e);

                
			            $$->IntConst = $1;
                  red();
          //          printf("SSSSS%s\n", expr($$->type));
                reset();
                }
              |REAL_CONST{{printf("|REALNUMBER %s\n",yytext);}
                $$ = newexpr(arithexpr_e);
			          $$->NumConst = $1;
            //  ..  printf("SSSSS%f",$$->NumConst);
                
                }
              |STRING{
               // $$=$1;
              printf("|STRING %s\n",$1);
               $$ = newexpr(conststring_e);
			          $$->strConst = $1;




                }
              |NIL{{printf("|NIL\n");}	$$ = newexpr(nil_e);}
              |TRUE{{printf("|TRUE\n");}	$$ = newexpr(constbool_e); 			$$->boolConst = true;
}
              |FALSE {{printf("|FALSE\n");}		$$ = newexpr(constbool_e);	$$->boolConst = false;
}


















              ;
idlist:       IDENTIFIER {
                    SymbolTableEntry* check=look_up_function_with_scope($1,symbolTable,current_scope+1);
                    if(!check){
                   if(!isLibFunc($1) ){
                       check=insert_symbol(symbolTable,true,$1,FORMAL,newFunction(),newVariable(),yylineno,current_scope+1);
                       check->space= currscopespace();
                          check->offset=currscopeoffset();
                          inccurrscopeoffset();
                          printf("The formal argument wiht name %s has inserted\n",check->name);
                      
                        }else{

                          red();
                        printf("Error you try to declare a library function in line %d \n",yylineno);     
                                             reset();
                        }
                  }else if(check->isActive==false){

                          check=  insert_symbol(symbolTable,true,$1,FORMAL,newFunction(),newVariable(),yylineno,current_scope+1);
                          check->space= currscopespace();
                          check->offset=currscopeoffset();
                          inccurrscopeoffset();
                          
                       

                  }else{
                          red();
                         
                          printf("Error Formal Redeclaration %s in line %d\n",check->name ,yylineno );
                          reset();

                  }}ids
              | 
              ;

ids:          COMMA IDENTIFIER{
                    SymbolTableEntry* check=look_up_function_with_scope($2,symbolTable,current_scope+1);
                    if(check==NULL){

                        if(!isLibFunc($2)){
                        check  =insert_symbol(symbolTable,true,$2,FORMAL,newFunction(),newVariable(),yylineno,current_scope+1);
                           check->space= currscopespace();
                          check->offset=currscopeoffset();
                          inccurrscopeoffset();
                          
                       
                        }else{
                          red();
                          printf("Error  %d you try to declare a library function in line \n",yylineno);
                          reset();
                        }
                      
                        
                }else{
                          red();
                          printf("Error %d Formal Redeclaration %s\n",yylineno ,check->name );
                          reset();

                  }
                } ids
              | 
              ;

ifstmt:		ifprefix stmt {
  patchlabel($1, nextquadlabel());

  $$=( stmt_t*)malloc(sizeof( stmt_t)); 
//$$=$2 ;


} %prec NOT_EQUAL
	        | ifprefix stmt elseprefix	stmt{
            patchlabel($1, $3 + 1);
              patchlabel($3, nextquadlabel());
             // $$=$4;
             $$=( stmt_t*)malloc(sizeof( stmt_t)); 
          }
          ;
ifprefix:IF LEFT_PARENTHESIS expr RIGHT_PARENTHESIS{
emit( if_eq,newexpr_constbool(1),$3,NULL,yylineno, nextquadlabel() + 2);
$$ = nextquadlabel();
emit(jump, NULL, NULL,NULL,yylineno, 0);
}
elseprefix: ELSE {
  $$ = nextquadlabel();
  emit(jump, NULL, NULL,NULL,yylineno, 0);
}
whilestmt: whilestart whilecond loopstmt{
 
      //  $3=( stmt_t*)malloc(sizeof( stmt_t)); //vazei to breaklist se 0 pou den mas volevei
       
       printf("ekeii:%d\n",$3->breakList);
        emit(jump,NULL,NULL,NULL,yylineno,$1);
       
        patchlabel($2, nextquadlabel());
        
        printf("nextquadlab:%d\n",nextquadlabel());
        patchlist($3->breakList, nextquadlabel());
        //printf("cont:%d\n",$3->contList);
      //  printQuads();
        patchlist($3->contList, $1);
       $$=$3;
            
      





  }
              ;



whilestart:WHILE{
  printf("whilestart\n");
   $$=nextquadlabel();
}
;




whilecond:  LEFT_PARENTHESIS expr RIGHT_PARENTHESIS {
  emit(if_eq, $2,newexpr_constbool(1),NULL,yylineno,nextquadlabel()+2);
  $$ = nextquadlabel();
emit(jump, NULL, NULL, NULL,yylineno,0);

  
}
;


N:          {
                $$ = nextquadlabel();
                emit(jump, NULL, NULL, NULL,yylineno,nextquadlabel());
                
            }
            ;
M:          {
                $$ = nextquadlabel();
            }
            ;
forprefix: FOR LEFT_PARENTHESIS elist SEMICOLON M expr SEMICOLON{
                $$=(struct for_prefix*)malloc(sizeof(struct for_prefix));
                $$->test=$5;
                $$->enter=nextquadlabel();
                emit(if_eq,$6,newexpr_constbool(1),NULL,yylineno,0);
}
forstmt:    forprefix N  elist RIGHT_PARENTHESIS N loopstmt N{
              patchlabel($1->enter,$5+1);
               printf("%d %d \n",$2,nextquadlabel());
                patchlabel($2,nextquadlabel());
              patchlabel($5,$1->test);
             
             patchlabel($7,$2+1);
              $6=(struct stmt_t*)malloc(sizeof(struct stmt_t));
              patchlist($6->breakList,nextquadlabel());
              patchlist($6->contList,$2+1);
              $$=( stmt_t*)malloc(sizeof( stmt_t));
}
             ;

returnstmt:  RETURN expr SEMICOLON {$$=( stmt_t*)malloc(sizeof( stmt_t));emit(ret,NULL,NULL,$2,yylineno,0); }
             | RETURN SEMICOLON {$$=( stmt_t*)malloc(sizeof( stmt_t));emit(ret,NULL,NULL,NULL,yylineno,0);}
             ;
%%
void yyerror(char* yaccProvideMessage){
  printf("Error on line %d: %s\n", yylineno, yaccProvideMessage);
 // exit(0);
}



int yywrap(void) {
    return 1;
}

int main(int argc, char *argv[]) {

    symbolTable = SymTable_Init();

    FILE *input_file;
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        return 1;
    }

    input_file = fopen(argv[1], "r");
    if (!input_file) {
        fprintf(stderr, "Error: cannot open input file '%s'\n", argv[1]);
        return 1;
    }

    // Set the input file for the parser to read from
    yyin = input_file;

    // Call the Bison parser to parse the input
    if (yyparse() != 0) {
        fprintf(stderr, "Error: parsing failed\n");
        return 1;
    }

    Print_SymTable(symbolTable);
  printQuads();
   
    fclose(input_file);
    return 0;
}