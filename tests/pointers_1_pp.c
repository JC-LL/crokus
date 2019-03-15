#include <stdio.h>

int main() {
  int * ptr1;
  int * ptr2;
  int * ptr2;
  int num;
  printf("\nEnter two numbers : ");
  scanf("%d %d",ptr1,ptr2);
  num = *ptr1+*ptr2;
  printf("Sum = %d",num);
  return 0;
}
