// Program to calculate the sum and average of maximum of 5 numbers
// If user enters negative number, the sum and average of previously entered positive numbers are displayed

#include <stdio.h>

int main()
{

    const int maxInput = 5;
    int i;
    double number, average, sum=0.0;

    for(i=1; i<=maxInput; ++i)
    {
        printf("%d. Enter a number: ", i);
        scanf("%lf",&number);

    // If user enters negative number, flow of program moves to label jump
        if(number < 0.0)
            goto jump;

        sum += number; // sum = sum+number;
    }

    jump:

    average=sum/(i-1);
    printf("Sum = %.2f\n", sum);
    printf("Average = %.2f", average);

    return 0;
}
