int f(int a,int b,int c){
  int v;
  int aa,bb,cc;
  int i;
  for(i=0;i<10;i++){
    v+=1;
    if(a*3>b){
      aa=4;
    }
    else{
      bb=5;
    }
    v+=3*a;
  }
  v+=a*b+aa;
  return v;
}
