#include<stdio.h>
// #include<conio.h>

void bubble_sort(int[], int);

int main() {
   int arr[30], num, i;

   printf("\nEnter no of elements :");
   scanf("%d", &num);

   printf("\nEnter array elements :");
   for (i = 0; i < num; i++)
      scanf("%d", &arr[i]);

   bubble_sort(arr, num);
   getchar();
   return 0;
}

void bubble_sort(int iarr[], int num) {
   int i, j, k, temp;

   printf("\nUnsorted Data:");
   for (k = 0; k < num; k++) {
      printf("%5d", iarr[k]);
   }

   for (i = 1; i < num; i++) {
      for (j = 0; j < num - 1; j++) {
         if (iarr[j] > iarr[j + 1]) {
            temp = iarr[j];
            iarr[j] = iarr[j + 1];
            iarr[j + 1] = temp;
         }
      }

      printf("\nAfter pass %d : ", i);
      for (k = 0; k < num; k++) {
         printf("%5d", iarr[k]);
      }
   }
}
