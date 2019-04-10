#include<stdio.h>
#define M 50

struct state {
   char name[50];
   int population;
   float literacyRate;
   float income;
} st[M]; /* array of structure */

int main() {
   int i, n, ml, mi, maximumLiteracyRate, maximumIncome;
   float rate;
   ml = -1;
   mi = -1;
   maximumLiteracyRate = 0;
   maximumIncome = 0;

   printf("Enter how many states:");
   scanf("%d", &n);

   for (i = 0; i < n; i++) {
      printf("\nEnter state %d details :", i);

      printf("\nEnter state name : ");
      scanf("%s", &st[i].name);

      printf("\nEnter total population : ");
      scanf("%ld", &st[i].population);

      printf("\nEnter total literary rate : ");
      scanf("%f", &rate);
      st[i].literacyRate = rate;

      printf("\nEnter total income : ");
      scanf("%f", &st[i].income);
   }

   for (i = 0; i < n; i++) {
      if (st[i].literacyRate >= maximumLiteracyRate) {
         maximumLiteracyRate = st[i].literacyRate;
         ml++;
      }
      if (st[i].income > maximumIncome) {
         maximumIncome = st[i].income;
         mi++;
      }
   }

   printf("\nState with highest literary rate :%s", st[ml].name);
   printf("\nState with highest income :%s", st[mi].name);

   return (0);
}
