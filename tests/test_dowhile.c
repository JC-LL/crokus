#include <stdio.h>

int main(void)
{
    int i = 10;

    do {
       printf("Hello %d\n", i );
       i = i -1;
    } while ( i > 0 );
}
