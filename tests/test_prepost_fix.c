#include<stdio.h>

int main(int args,char ** argv){
  int i;
  int a=0;
  for(i=0;i<10;i++){
    a++;
    a--;
    ++a;
    --a;
  }
  printf("a=%d\n",a);
  return 0;
}
