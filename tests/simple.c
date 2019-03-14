/* compile it with :
  gcc -c simple.c -std=c99
*/

#include <stdio.h>
#define N 128

int computation(int a,int b, int c[N]){
  int *j;
  for(int i=0;i<N-1;i++){
    c[i]=a+b;
  };
  return 0;
}
