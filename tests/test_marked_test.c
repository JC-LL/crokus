#include <stdlib.h>
#include <stdio.h>


void addsub(float *sum,float *diff,float *in1,float *in2,int size)
{
  int i;

  for (i = 0; i < size; i++) {

    sum[i] = in1[i] + in2[i];

  }

  for (i = 0; i < size; i++) {

    diff[i] = in1[i] - in2[i];

  }

}

void muldiv(float *prod,float *qout,float *in1,float *in2,int size)
{
  int i;

  for (i = 0; i < size; i++) {

    prod[i] = in1[i] * in2[i];

  }


  for (i = 0; i < size; i++) {

    qout[i] = in1[i] / in2[i];

  }

}

int main(int argc,char **argv)
{

  int i;
  int size = 5000;
  float *a = (float *)(malloc(size * sizeof(float )));
  float *b = (float *)(malloc(size * sizeof(float )));
  float *c = (float *)(malloc(size * sizeof(float )));
  float *d = (float *)(malloc(size * sizeof(float )));
  float *e = (float *)(malloc(size * sizeof(float )));
  float *f = (float *)(malloc(size * sizeof(float )));

  for (i = 0; i < size; i++) {

    e[i] = (i + 1.7);
    f[i] = (i + 1.7);

  }

  addsub(a,b,e,f,size);
  muldiv(c,d,e,f,size);
  free(a);
  free(b);
  free(c);
  free(d);
  free(e);
  free(f);
  printf("f[10]=%f\n",f[10]);
  return 0;
}
