#include <stdio.h>

void setArray(int array[],int index,int value) {
  array[index] = value;
}

int main(void) {
  int a[1] = {1};
  setArray(a,0,2);
  printf("a[0]=%d\n",a[0]);
  return 0;
}
