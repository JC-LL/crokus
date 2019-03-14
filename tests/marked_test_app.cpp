// code generated automatically by JCLL at 2016-02-01 11:39:12 +0100

#include <stdlib.h>
#include <stdio.h>
#include "xpu.h"

// functions (as in initial code OR resulting from splitted functions)

void func_main_15_2 (int from,int to,int step, int  i, int  size, float *  e, float *  f) {
  for (i = 0; i < size; i++) {

    e[i] = (i + 1.7);
    f[i] = (i + 1.7);

  }

}
void func_addsub_7_4 (int from,int to,int step, float *  sum, float *  in1, float *  in2, int  size, int  i) {
  for (i = 0; i < size; i++) {

    sum[i] = in1[i] + in2[i];

  }

}
void func_addsub_9_5 (int from,int to,int step, float *  diff, float *  in1, float *  in2, int  size, int  i) {
  for (i = 0; i < size; i++) {

    diff[i] = in1[i] - in2[i];

  }

}
void func_muldiv_11_7 (int from,int to,int step, float *  prod, float *  in1, float *  in2, int  size, int  i) {
  for (i = 0; i < size; i++) {

    prod[i] = in1[i] * in2[i];

  }

}
void func_muldiv_13_8 (int from,int to,int step, float *  qout, float *  in1, float *  in2, int  size, int  i) {
  for (i = 0; i < size; i++) {

    qout[i] = in1[i] / in2[i];

  }

}

int main(int argc,char **argv) {

  // initial declarations

  int i;
  int size = 5000;
  float *a = (float *)(malloc(size * sizeof(float )));
  float *b = (float *)(malloc(size * sizeof(float )));
  float *c = (float *)(malloc(size * sizeof(float )));
  float *d = (float *)(malloc(size * sizeof(float )));
  float *e = (float *)(malloc(size * sizeof(float )));
  float *f = (float *)(malloc(size * sizeof(float )));



  // task definitions
  //xpu::task main_15_2(func_main_15_2,i, size, e, f);
  //xpu::task addsub_7_4(func_addsub_7_4,sum, in1, in2, size, i);
  //xpu::task addsub_9_5(func_addsub_9_5,diff, in1, in2, size, i);
  //xpu::task muldiv_11_7(func_muldiv_11_7,prod, in1, in2, size, i);
  //xpu::task muldiv_13_8(func_muldiv_13_8,qout, in1, in2, size, i);

  //// task groups definitions
  //xpu::task_group * muldiv_13_8_pf = parallel_for(&muldiv_13_8);
  //xpu::task_group * muldiv_11_7_pf = parallel_for(&muldiv_11_7);
  //xpu::task_group * dummy_par_2 = parallel(muldiv_11_7_pf,muldiv_13_8_pf);
  //xpu::task_group * muldiv_24_6 = sequential(dummy_par_2);
  //xpu::task_group * addsub_9_5_pf = parallel_for(&addsub_9_5);
  //xpu::task_group * addsub_7_4_pf = parallel_for(&addsub_7_4);
  //xpu::task_group * dummy_par_1 = parallel(addsub_7_4_pf,addsub_9_5_pf);
  //xpu::task_group * addsub_23_3 = sequential(dummy_par_1);
  //xpu::task_group * dummy_par_3 = parallel(addsub_23_3,muldiv_24_6);
  //xpu::task_group * main_15_2_pf = parallel_for(&main_15_2);
  //xpu::task_group * main_0_1 = sequential(main_15_2_pf,dummy_par_3);

  //task graph execution
  //main_0_1->run();
  //xpu::clean;
  return 0;
}
