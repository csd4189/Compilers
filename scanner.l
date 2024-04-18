%{
      #include <stdio.h>
      #include <string.h>
      #include <stdlib.h>
      #include <stdbool.h>
      #include "parser.h"


      #define MAX 10340

      #ifdef __linux__
      #	define end '\0'
      #else
      #	define end EOF
      #endif
      #define RED     "\033[31m"      /* Red */
      #define RESET   "\033[0m"

      typedef struct alpha_token_t {
            int numline;
            int numToken;
            char* content;
            char* type;
            char* name_type;
            char* type_of_content;
  
            struct alpha_token_t *next;
      }alpha_token;

      int token=0;
      alpha_token *head=NULL;

      void insert_node(int number, int counter,char *content,char *name_type, char * type, char* type_of_token){
    
            alpha_token *newnode=(alpha_token*)malloc(sizeof(alpha_token));
            newnode->numToken=counter;
     
            newnode->numline = number;
            newnode->content = strdup(content);
            newnode->type = strdup(type);
            newnode->name_type = strdup(name_type);
            newnode->type_of_content = strdup(type_of_token);
     
            if(head==NULL){
                  head=newnode;
                  newnode->next=NULL;
            }else{
                  alpha_token *cur=head;
                  while( cur->next!=NULL ){
                        cur=cur->next;                        
                  }
                  cur->next=newnode;
                  newnode->next=NULL;
            }
      }

      void  printtoken(){
            printf("\n-------------------------------------------------------LEXICAL ANALYSIS--------------------------------------------------------------------\n");
            alpha_token *cur=head;
            while (cur!=NULL){
                  if(!strcmp(cur->type,"STRING")){
                        printf("\n%d: \t\t #%d  \t\t\"%s\"\t\t%s \t\t%s \t\t\t<- %s ",cur->numline,cur->numToken,cur->content,cur->type, cur->name_type, cur->type_of_content);
                  }else{
                        printf("\n%d: \t\t #%d  \t\t\"%s\"\t\t%s \t\t%s \t\t\t<- %s ",cur->numline,cur->numToken,cur->content,cur->type, cur->name_type, cur->type_of_content);
                  }
                  cur=cur->next;
            }
            printf("\n");
      }
      
      //Update the input so that the escaped character can be placed correctly.
      void update_input(char* input, int index, char escaped_char){
            if(input == NULL){
                  printf("Error: In replace, input is NULL\n");
                  exit(-1);
            }
            input[index] = escaped_char;
      }

%}

/* Flex options */
%option yylineno

/* KEYWORDS */
IF   "if"
ELSE  "else"
WHILE "while"
FOR   "for"
RETURN      "return"
FUNCTION    "function"
BREAK "break"
CONTINUE    "continue"
AND   "and"
NOT   "not"
OR    "or"
LOCAL "local"
TRUE "true"
FALSE "false"
NIL "nil"

/* OPERATORS */
ASSIGN "\="
ADD "\+"
MINUS "\-"
MUL "\*"
DIV "/"
PERCENT "\%"
EQUAL "=="
NOT_EQUAL "!="
INCREMENT "++"
DECREMENT "--"
GREATER_THAN ">"
LESS_THAN "<"
GREATER_EQUAL ">="
LESS_EQUAL "<="

/* NUMBERS */
INT_CONST [0-9]+
REAL_CONST ([0-9]+)"."([0-9]+)

/* IDENTIFIER */
IDENTIFIER   [a-zA-Z_][a-zA-Z0-9_]*

/* PUNC */
LEFT_CURLY_BRACKET "\{"
RIGHT_CURLY_BRACKET "\}"
LEFT_BRACKET "\["
RIGHT_BRACKET "\]"
LEFT_PARENTHESIS "\("
RIGHT_PARENTHESIS "\)"
SEMICOLON "\;"
COLON "\:"
DOUBLE_COLON "\::"
COMMA "\,"
DOT "\."
DOUBLE_DOT "\.."

/* Comments */
SINGLE_LINE_COMMENT "//".*

NEW_LINE "\n"
TAB "\t"


%%

\" { 
      //Second solution. Read every character until \" or EOF to print error message.

      /* After the first quote, we have to locate the second one,
      and if there is escaped character, we have to adjust the string. If 
      input string is not valid, inform the user and end the program.*/
      char* content = (char*) yyalloc(sizeof(char));
      int c=0, index=0;
      bool closed = false;
      
      //Run until EOF or the input character is \". 
      while( (c=input()) != EOF && c!=0){
            /* If character is \" break, else backslash, go check the next character.*/
            if(c == '\"'){
                  closed=true;
                  break;
            }else if(c==92){
                  /*Check the next character for n,t,\.
                  If c is one them, call replace to make the change. 
                  Otherwise just continue until \".*/ 
                  switch(c=input()){
                        case 'n':
                              update_input(content, index, '\n');
                              break;
                        case 't':
                              update_input(content, index, '\t');
                              break;
                        case '\\':
                              update_input(content, index, '\\');
                              break;
                        case '\"':
                              update_input(content, index, '\"');
                              break;
                        default:
                              printf("Error: Invalid escaped character \\%c\n", c);
                              //content[index] = c;
                              exit(-1);
                              break;
                  }
            }else{ //Regular character
                  content[index] = c;
            }
            /*Increase allocated memory for the next character. 
            Also,increase the index in order to update the content array. */ 
            content = realloc(content, (++index)+1);
      }
      //Check if string is valid or not.
      if( closed == true ){
            //Add the null-terminated character
            content[index] = '\0'; 
            insert_node(yylineno,++token, content, "STRING", "STRING", "char*");
         
            yylval.stringValue=strdup(content);
            return STRING; 
            free(content);
      }else if( closed == false ){
            printf("Error: Invalid string.Check your input.\n");
            exit(-1);
      }else if ( c==0 ){
          
            exit(0);
      }
}


{INT_CONST} {yylval.intValue=atoi(yytext); return  INT_CONST;}
{REAL_CONST} { yylval.realValue = atof(yytext); return  REAL_CONST; }

{IF} {insert_node(yylineno,++token,yytext,"IF","KEYWORD","ENUMERATED");return IF;}
{ELSE} {insert_node(yylineno,++token,yytext,"ELSE","KEYWORD","ENUMERATED"); return ELSE;}
{WHILE} {insert_node(yylineno,++token,yytext,"WHILE","KEYWORD","ENUMERATED");return WHILE;}
{FOR} {insert_node(yylineno,++token,yytext,"FOR","KEYWORD","ENUMERATED"); return   FOR;}
{FUNCTION} {insert_node(yylineno,++token,yytext,"FUNCTION","KEYWORD","ENUMERATED");return FUNCTION;}
{BREAK} {insert_node(yylineno,++token,yytext,"BREAL","KEYWORD","ENUMERATED");return BREAK;}
{CONTINUE} {insert_node(yylineno,++token,yytext,"CONTINUE","KEYWORD","ENUMERATED");return CONTINUE;}
{RETURN} {insert_node(yylineno,++token,yytext,"RETURN","KEYWORD","ENUMERATED");return RETURN;}
{OR} {insert_node(yylineno,++token,yytext,"OR","KEYWORD","ENUMERATED");return OR;}
{AND} {insert_node(yylineno,++token,yytext,"AND","KEYWORD","ENUMERATED");return AND;}
{NOT} {insert_node(yylineno,++token,yytext,"NOT","KEYWORD","ENUMERATED");return NOT;}
"&&" {insert_node(yylineno,++token,yytext,"AND","KEYWORD","ENUMERATED");return AND;}
"||" {insert_node(yylineno,++token,yytext,"OR","KEYWORD","ENUMERATED");return OR;}
{LOCAL} {insert_node(yylineno,++token,yytext,"LOCAL","KEYWORD","ENUMERATED");return LOCAL;}
{TRUE} {insert_node(yylineno,++token,yytext,"TRUE","KEYWORD","ENUMERATED");return TRUE;}
{FALSE} {insert_node(yylineno,++token,yytext,"FALSE","KEYWORD","ENUMERATED");return FALSE;}
{NIL} {insert_node(yylineno,++token,yytext,"NIL","KEYWORD","ENUMERATED");return NIL;}


{ASSIGN} {insert_node(yylineno,++token,yytext,"ASSIGN","OPERATOR","ENUMERATED");return ASSIGN;}
{ADD} {insert_node(yylineno,++token,yytext,"PLUS","OPERATOR","ENUMERATED");return ADD;}
{MINUS} {insert_node(yylineno,++token,yytext,"MINU","OPERATOR","ENUMERATED");return MINUS;}
{MUL}   {insert_node(yylineno,++token,yytext,"MULTI","OPERATOR","ENUMERATED");return MUL;}
{DIV}   {insert_node(yylineno,++token,yytext,"DIV","OPERATOR","ENUMERATED");return DIV;}
{PERCENT}   {insert_node(yylineno,++token,yytext,"MOD","OPERATOR","ENUMERATED");return PERCENT;}
{EQUAL}   {insert_node(yylineno,++token,yytext,"EQUAL","OPERATOR","ENUMERATED");return EQUAL;}
{NOT_EQUAL}   {insert_node(yylineno,++token,yytext,"NOT_EQUAL","OPERATOR","ENUMERATED");return NOT_EQUAL;}
{INCREMENT}   {insert_node(yylineno,++token,yytext,"PLUS_PLUS","OPERATOR","ENUMERATED");return INCREMENT;}
{DECREMENT}   {insert_node(yylineno,++token,yytext,"MINUS_MINUS","OPERATOR","ENUMERATED");return DECREMENT;}
{GREATER_THAN}   {insert_node(yylineno,++token,yytext,"GREATER_THAN","OPERATOR","ENUMERATED");return GREATER_THAN;}
{LESS_THAN}   {insert_node(yylineno,++token,yytext,"LESS_THAN","OPERATOR","ENUMERATED");return LESS_THAN;}
{GREATER_EQUAL}   {insert_node(yylineno,++token,yytext,"GREATER_EQUAL","OPERATOR","ENUMERATED");return GREATER_EQUAL;}
{LESS_EQUAL}   {insert_node(yylineno,++token,yytext,"<=","LESS_EQUAL","ENUMERATED");return LESS_EQUAL;}

{IDENTIFIER}   { yylval.stringValue = strdup(yytext); return IDENTIFIER; }

{LEFT_CURLY_BRACKET}   {insert_node(yylineno,++token,yytext,"LEFT_CURLY_BRACKET","PUNCUATION","ENUMERATED");return LEFT_CURLY_BRACKET;}
{RIGHT_CURLY_BRACKET}   {insert_node(yylineno,++token,yytext,"RIGHT_CURLY_BRACKET","PUNCUATION","ENUMERATED");return RIGHT_CURLY_BRACKET;}
{LEFT_BRACKET}  {insert_node(yylineno,++token,yytext,"LEFT_BRACKET","PUNCUATION","ENUMERATED");return LEFT_BRACKET;}
{RIGHT_BRACKET}  {insert_node(yylineno,++token,yytext,"RIGHT_BRACKET","PUNCUATION","ENUMERATED");return RIGHT_BRACKET;}
{LEFT_PARENTHESIS} {insert_node(yylineno,++token,yytext,"LEFT_PARENTHESIS","PUNCUATION","ENUMERATED");return LEFT_PARENTHESIS;}
{RIGHT_PARENTHESIS} {insert_node(yylineno,++token,yytext,"RIGHT_PARENTHESIS","PUNCUATION","ENUMERATED");return   RIGHT_PARENTHESIS;}
{SEMICOLON}          {insert_node(yylineno,++token,yytext,"SEMICOLON","PUNCUATION","ENUMERATED");return SEMICOLON;}
{COLON}  {insert_node(yylineno,++token,yytext,":","COLON","ENUMERATED");return COLON;}
{DOUBLE_COLON} {insert_node(yylineno,++token,yytext,"DOUBLE_COLON","PUNCUATION","ENUMERATED"); return DOUBLE_COLON;}
{COMMA} {insert_node(yylineno,++token,yytext,"COMMA","PUNCUATION","ENUMERATED");return COMMA;}
{DOT} {insert_node(yylineno,++token,yytext,"DOT","PUNCUATION","ENUMERATED");return DOT;}
{DOUBLE_DOT} {insert_node(yylineno,++token,yytext,"DOUBLE_DOT","PUNCUATION","ENUMERATED");return DOUBLE_DOT;}
{SINGLE_LINE_COMMENT} {insert_node(yylineno,++token,"","LINE_COMMENT","COMMENT","ENUMERATED");}

{NEW_LINE}  { }
{TAB} { }
" "   { }

"/*" {
      int start[99999];
      start[0]=yylineno;
      int c=input();
      //char str[MAX];
      char* str = (char*) yyalloc(sizeof(char));
      int open=1;
      int index=0;
      int nested=0;
      while(c!=end){
            if(c=='/'){
                  c=input();
                  if(c=='*'){
                        open++;
                        nested=1;
                        index++;
                        start[index]=yylineno;
                  }else if(c=='/'){
                        continue;
                  }
            }else if(c=='*'){
                  c=input();
                  if(c=='/'){
                        open--;
                        str = realloc(str, strlen(str)+1);
                        if(!nested||index==0) {
                              sprintf(str,"%d-%d",start[0],yylineno);
                              insert_node(start[0],++token,str,"BLOCK COMMENT","COMMENT","enumerated");
                              break;
                        }
                        sprintf(str,"%d-%d",start[index],yylineno);
                        insert_node(start[index],++token,str,"NESTED_BLOCK_COMMENT","COMMENT","enumerated");
                        index--;
                  }else if(c=='*'){
                        continue;
                  }
            }
            c=input();
      }

      if(open>0){
            fprintf(stderr,RED);
            fprintf(stderr,"ERROR:%d comment(s) did not close\n",open);
            fprintf(stderr,RESET);
            exit(-1);
      }	
}


. {fprintf(stderr,"Cannot match character %s with any rule\n",yytext);}

%%
