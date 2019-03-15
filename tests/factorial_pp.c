#include <stdio.h>

int main() {
  int c;
  int n;
  int fact = 1;
  printf("Enter a number to calculate it's factorial\n");
  scanf("%d", &n );
  for(c = 1;c<=n;c++)
    fact = fact*c;
  printf("Factorial of %d = %d\n",n,fact);
  return 0;
}
