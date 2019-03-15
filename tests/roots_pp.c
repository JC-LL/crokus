#include <stdio.h>
#include <math.h>

int main() {
  double a;
  double b;
  double c;
  double determinant;
  double root1;
  double root2;
  double realPart;
  double imaginaryPart;
  printf("Enter coefficients a, b and c: ");
  scanf("%lf %lf %lf", &a , &b , &c );
  determinant = b*b-4*a*c;
  if (determinant>0) {{
    root1 = -b+sqrt(determinant)/2*a;
    root2 = -b-sqrt(determinant)/2*a;
    printf("root1 = %.2lf and root2 = %.2lf",root1,root2);
    }
  }
  else {
    if (determinant==0) {{
      root1 = root2=-b/2*a;
      printf("root1 = root2 = %.2lf;",root1);
      }
    }
    else {{
      realPart = -b/2*a;
      imaginaryPart = sqrt(-determinant)/2*a;
      printf("root1 = %.2lf+%.2lfi and root2 = %.2f-%.2fi",realPart,imaginaryPart,realPart,imaginaryPart);
      }
    }
  }
  return 0;
}
