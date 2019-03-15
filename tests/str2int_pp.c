#include <stdio.h>

int toString(char[])

int main() {
  char a[100];
  int n;
  printf("Input a valid string to convert to integer\n");
  scanf("%s",a);
  n = toString(a);
  printf("String  = %s\nInteger = %d\n",a,n);
  return 0;
}

int toString(char a[]) {
  int c;
  int sign;
  int offset;
  int n;
  if a[0]=='-' {{
    sign = -1;
    }
  }
  if sign==-1 {{
    offset = 1;
    }
  }
  else {{
    offset = 0;
    }
  }
  n = 0;
  for(c = offset;a[c]!='\0';c++){
    n = n*10+a[c]-'0';
    }
  if sign==-1 {{
    n = -n;
    }
  }
  return n;
}
