#include <stdio.h>
#include <stdlib.h>

int main() {
  #<Code:0x0000000002433990> * ptr;
  int i;
  int n;
  printf("Enter n: ");
  scanf("%d", &n );
  ptr = (#<Code:0x00000000024313e8> *) malloc(n*sizeof(#<Code:0x0000000002430858>));
  for(i = 0;i<n;++i){
    printf("Enter string and integer respectively:\n");
    scanf("%s%d", &ptr+i->c , &ptr+i->a );
    }
  printf("Displaying Infromation:\n");
  for(i = 0;i<n;++i){
    printf("%s\t%d\t\n",ptr+i->c,ptr+i->a);
    }
  return 0;
}
