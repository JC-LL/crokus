#include<stdio.h>

int main()
{
    int i;
    int j = 10;

    for( i = 0; i <= j; i++ )
    {
       if( i == 5 )
       {
          continue;
       }
       printf("Hello %d\n", i );
    }
    printf("end");
}
