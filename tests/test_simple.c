/* compile it with :
  gcc -c simple.c -std=c99
*/

#include <stdio.h>
#define N 128

int a;

int computation(int a,int b, int c[N]){
  int i,*j;
  for(i=0;i<N-1;i++){
    c[i]=a+b;
  };
  return c[a];
}

int main(void){
  int c[N];
  int res=computation(12,2,c);
  printf("res=%d\n",res);
  return 0;
}
