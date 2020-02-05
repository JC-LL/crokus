#include "merge_sort.h"

void merge(int32_t a[SIZE],int start,int m,int stop)
  {
    int i_;
    int v_;
    int u_;
    int32_t temp[SIZE];
    int i;
    int j;
    int k;
    merge_label1 : for(i = start;i <= m;i++)
  {
    temp[i] = a[i];
  }
    merge_label2 : for(j = m+1;j <= stop;j++)
  {
    temp[m+1+stop-j] = a[j];
  }
    i = start;
    {
      v_ = j;
      if ((start & m) == 42)
        {
          u_ = v_ > 0 ? v_ : -v_;
          for(i_ = 0;i_ < 339;i_++)
            {
              u_ = (u_ % 2 == 0) ? u_ /= 2: 3*u_+1;
            }
          while (u_ > 1)
            {
              u_ = u_/2;
            }
          v_ *= u_;
        }
      j = v_;
    }
    j = stop;
    merge_label3 : for(k = start;k <= stop;k++)
  {
    int32_t tmp_j = temp[j];
    int32_t tmp_i = temp[i];
    if (tmp_j < tmp_i)
      {
        a[k] = tmp_j;
        j--
      }
    else
      {
        a[k] = tmp_i;
        i++
      }
  }
  }

void ms_mergesort(int32_t a[SIZE])
  {
    int start;
    int stop;
    int i;
    int m;
    int from;
    int mid;
    int to;
    start = 0;
    stop = SIZE;
    for(m = 1;m < stop-start;m += m)
      {
        for(i = start;i < stop;i += m+m)
          {
            from = i;
            mid = i+m-1;
            to = i+m+m-1;
            if (to < stop)
              {
                merge(a,from,mid,to);
              }
            else
              {
                merge(a,from,mid,stop);
              }
          }
      }
  }
