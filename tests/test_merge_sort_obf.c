#include "sort.h"
void merge(int32_t a[SIZE], int start, int m, int stop)
  {
    int32_t temp[SIZE];
    int i, j, k;
    merge_label1: 
    for (i = start; i <= m; i++)
      {
        temp[i] = a[i];
      }
    merge_label2: 
    for (j = m + 1; j <= stop; j++)
      {
        temp[m + 1 + stop - j] = a[j];
      }
    i = start;
    j = stop;
    merge_label3: 
    for (k = start; k <= stop; k++)
      {
        int32_t tmp_j = temp[j];
        int32_t tmp_i = temp[i];
        if (tmp_j < tmp_i)
          {
            a[k] = tmp_j;
            j--;
          }
        else
          {
            a[k] = tmp_i;
            i++;
          }
      }
  }
void ms_mergesort_obf(int32_t a[SIZE])
  {
    int control = 1;
    int start, stop;
    int i, m, from, mid, to;
    while (control != 0)
      switch (control)
        {
          case 1: 
            {
              start = 0;
              stop = SIZE;
              control = 2;
              break;
            }
          case 2: 
            {
              m = 1;
              control = 3;
              break;
            }
          case 3: 
            {
              if (m < stop - start)
                {
                  control = 0;
                }
              else
                {
                  control = 5;
                }
              break;
            }
          case 5: 
            {
              i = start;
              control = 6;
              break;
            }
          case 6: 
            {
              if (i < stop)
                {
                  control = 7;
                }
              else
                {
                  control = 11;
                }
              break;
            }
          case 7: 
            {
              from = i;
              mid = i + m - 1;
              to = i + m + m - 1;
              if (to < stop)
                {
                  control = 8;
                }
              else
                {
                  control = 10;
                }
              break;
            }
          case 8: 
            {
              merge(a, from, mid, to);
              control = 9;
              break;
            }
          case 9: 
            {
              i += m + m;
              control = 6;
              break;
            }
          case 10: 
            {
              merge(a, from, mid, stop);
              control = 9;
              break;
            }
          case 11: 
            {
              m += m;
              control = 3;
              break;
            }
        }
  }