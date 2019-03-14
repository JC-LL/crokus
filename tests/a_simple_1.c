#include<stdio.h>

int f(int a,int b){
  return a+b;
}

int main(void){
  int res=3+f(1,2);
  printf("a=%d",res);
  return 0;
}
