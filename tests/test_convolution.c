void convolve (double *p_coeffs, int p_coeffs_n,
               double *p_in, double *p_out, int n)
{
  int i, j, k;
  double tmp;

  for (k = 0; k < n; k++)  //  position in output
  {
    tmp = 0;

    for (i = 0; i < p_coeffs_n; i++)  //  position in coefficients array
    {
      j = k - i;  //  position in input

      if (j >= 0)  //  bounds check for input buffer
      {
        tmp += p_coeffs [k] * p_in [j];
      }
    }

    p_out [i] = tmp;
  }
}
