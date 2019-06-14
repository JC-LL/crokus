#include<stdio.h>

int f1(int a,int b){
  int x;

  x=2*a+b;
  y=3*b;

  if(x>10){
    x+=1;
  }
  else{
    x-=3;
    if (a>0){
      x++;
    }
    else{
      x*=2;
    }
  }
  while(x<100){
    x+=4;
  }
  for(i=0;i<30;i++){
    y+=5;
  }
  printf("ending\n");
  return x;
}

int main(void){
  int x=f1(12,34);
  printf("result = %d\n",x );
  return 0;
}
