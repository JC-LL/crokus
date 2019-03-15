#include <stdio.h>

int main() {
  int first;
  int second;
  int add;
  int subtract;
  int multiply;
  float divide;
  printf("Enter two integers\n");
  scanf("%d%d", &first , &second );
  add = first+second;
  subtract = first-second;
  multiply = first*second;
  divide = first/(float) second;
  printf("Sum = %d\n",add);
  printf("Difference = %d\n",subtract);
  printf("Multiplication = %d\n",multiply);
  printf("Division = %.2f\n",divide);
  return 0;
}
