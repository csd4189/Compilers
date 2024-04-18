  #include <stdio.h>
  void  blue();
  void red();
  void yellow();
  void reset();
  void green();
  void cyan();
  
  
  
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
void cyan(){
    printf("\x1b[36m");
}


