/* compile it with :
  gcc -c simple.c -std=c99
*/

#include <stdio.h>
#define N 128

int a;
int b[];
int c[100];

int computation(int a,int b, int c[N]){
  int i,*j;
  int k;
  k=12+42;
  int l;
  for(i=0;i<N-1;i++){
    c[i]=a+b;
  };
  return c[a];
}

int main(void){
  int c[N];
  int res;
  res=computation(12,2,c);
  printf("res=%d\n",res);
  return 0;
}
