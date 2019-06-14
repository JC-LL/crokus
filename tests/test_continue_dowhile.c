#include <stdio.h>

int main () {
   int a = 10;
   do {
      if( a == 15) {
         /* skip the iteration */
         a = a + 1;
         continue;
      }
      a++;
      printf("value of a: %d\n", a);
   } while( a < 20 );
   return 0;
}
