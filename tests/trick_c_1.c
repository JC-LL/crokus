#include<stdio.h>

int main(void){
  int a=1,b=1,c=1,y;
  printf("a=%d b=%d c=%d  y=%d\n",a,b,c,y);
  y=a++ * b++;
  printf("a=%d b=%d c=%d  y=%d\n",a,b,c,y);
  return 0;
}
