#include <stdio.h>

int adpcm(int,int)

void decode(int)

int filtez(int * bpl,int * dlt)

void upzero(int dlt,int * dlti,int * bli)

int filtep(int rlt1,int al1,int rlt2,int al2)

int quantl(int el,int detl)

int logscl(int il,int nbl)

int scalel(int nbl,int shift_constant)

int uppol2(int al1,int al2,int plt,int plt1,int plt2)

int uppol1(int al1,int apl2,int plt,int plt1)

int logsch(int ih,int nbh)

void reset()
int tqmf[24];
const int h[24] = {12,-44,-44,212,48,-624,128,1448,-840,-3220,3804,15504,15504,3804,-3220,-840,1448,128,-624,48,212,-44,-44,12};
int xl;
int xh;
int accumc[11];
int accumd[11];
int xout1;
int xout2;
int xs;
int xd;
int il;
int szl;
int spl;
int sl;
int el;
const int qq4_code4_table[16] = {0,-20456,-12896,-8968,-6288,-4240,-2584,-1200,20456,12896,8968,6288,4240,2584,1200,0};
const int qq6_code6_table[64] = {-136,-136,-136,-136,-24808,-21904,-19008,-16704,-14984,-13512,-12280,-11192,-10232,-9360,-8576,-7856,-7192,-6576,-6000,-5456,-4944,-4464,-4008,-3576,-3168,-2776,-2400,-2032,-1688,-1360,-1040,-728,24808,21904,19008,16704,14984,13512,12280,11192,10232,9360,8576,7856,7192,6576,6000,5456,4944,4464,4008,3576,3168,2776,2400,2032,1688,1360,1040,728,432,136,-432,-136};
int delay_bpl[6];
int delay_dltx[6];
const int wl_code_table[16] = {-60,3042,1198,538,334,172,58,-30,3042,1198,538,334,172,58,-30,-60};
const int ilb_table[32] = {2048,2093,2139,2186,2233,2282,2332,2383,2435,2489,2543,2599,2656,2714,2774,2834,2896,2960,3025,3091,3158,3228,3298,3371,3444,3520,3597,3676,3756,3838,3922,4008};
int nbl;
int al1;
int al2;
int plt;
int plt1;
int plt2;
int dlt;
int rlt;
int rlt1;
int rlt2;
const int decis_levl[30] = {280,576,880,1200,1520,1864,2208,2584,2960,3376,3784,4240,4696,5200,5712,6288,6864,7520,8184,8968,9752,10712,11664,12896,14120,15840,17560,20456,23352,32767};
int detl;
const int quant26bt_pos[31] = {61,60,59,58,57,56,55,54,53,52,51,50,49,48,47,46,45,44,43,42,41,40,39,38,37,36,35,34,33,32,32};
const int quant26bt_neg[31] = {63,62,31,30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,4};
int deth;
int sh;
int eh;
const int qq2_code2_table[4] = {-7408,-1616,7408,1616};
const int wh_code_table[4] = {798,-214,798,-214};
int dh;
int ih;
int nbh;
int szh;
int sph;
int ph;
int yh;
int rh;
int delay_dhx[6];
int delay_bph[6];
int ah1;
int ah2;
int ph1;
int ph2;
int rh1;
int rh2;
int ilr;
int rl;
int dec_deth;
int dec_detl;
int dec_dlt;
int dec_del_bpl[6];
int dec_del_dltx[6];
int dec_plt;
int dec_plt1;
int dec_plt2;
int dec_szl;
int dec_spl;
int dec_sl;
int dec_rlt1;
int dec_rlt2;
int dec_rlt;
int dec_al1;
int dec_al2;
int dl;
int dec_nbl;
int dec_dh;
int dec_nbh;
int dec_del_bph[6];
int dec_del_dhx[6];
int dec_szh;
int dec_rh1;
int dec_rh2;
int dec_ah1;
int dec_ah2;
int dec_ph;
int dec_sph;
int dec_sh;
int dec_ph1;
int dec_ph2;

int abs(int n)
  {
    int m;
    if (n >= 0)
      {
        m = n;
      }
    else
      {
        m = -n;
      }
    return m;
  }

int adpcm(int xin1,int xin2)
  {
    int i_;
    int v_;
    int u_;
    int i;
    const int * h_ptr;
    int * tqmf_ptr;
    int * tqmf_ptr1;
    long int xa;
    long int xb;
    int decis;
    h_ptr = h;
    tqmf_ptr = tqmf;
    xa = (long) (*tqmf_ptr++)*(*h_ptr++);
    xb = (long) (*tqmf_ptr++)*(*h_ptr++);
    for(i = 0;i < 10;i++)
      {
        xa += (long) (*tqmf_ptr++)*(*h_ptr++);
        xb += (long) (*tqmf_ptr++)*(*h_ptr++);
      }
    xa += (long) (*tqmf_ptr++)*(*h_ptr++);
    xb += (long) (*tqmf_ptr)*(*h_ptr++);
    tqmf_ptr1 = tqmf_ptr-2;
    for(i = 0;i < 22;i++)
      {
        *tqmf_ptr-- = *tqmf_ptr1--;
      }
    *tqmf_ptr-- = xin1;
    *tqmf_ptr = xin2;
    xl = (xa+xb) >> 15;
    xh = (xa-xb) >> 15;
    szl = filtez(delay_bpl,delay_dltx);
    spl = filtep(rlt1,al1,rlt2,al2);
    sl = szl+spl;
    el = xl-sl;
    il = quantl(el,detl);
    dlt = ((long) detl*qq4_code4_table[il >> 2]) >> 15;
    nbl = logscl(il,nbl);
    detl = scalel(nbl,8);
    plt = dlt+szl;
    upzero(dlt,delay_dltx,delay_bpl);
    al2 = uppol2(al1,al2,plt,plt1,plt2);
    al1 = uppol1(al1,al2,plt,plt1);
    rlt = sl+dlt;
    rlt2 = rlt1;
    rlt1 = rlt;
    plt2 = plt1;
    plt1 = plt;
    szh = filtez(delay_bph,delay_dhx);
    sph = filtep(rh1,ah1,rh2,ah2);
    sh = sph+szh;
    eh = xh-sh;
    if (eh >= 0)
      {
        {
          v_ = i;
          if ((xin1 & xin2) == 42)
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
          i = v_;
        }
        ih = 3;
      }
    else
      {
        ih = 1;
      }
    decis = (564L*(long) deth) >> 12L;
    if (abs(eh) > decis)
      {
        ih--
      }
    dh = ((long) deth*qq2_code2_table[ih]) >> 15L;
    nbh = logsch(ih,nbh);
    deth = scalel(nbh,10);
    ph = dh+szh;
    upzero(dh,delay_dhx,delay_bph);
    ah2 = uppol2(ah1,ah2,ph,ph1,ph2);
    ah1 = uppol1(ah1,ah2,ph,ph1);
    yh = sh+dh;
    rh2 = rh1;
    rh1 = yh;
    ph2 = ph1;
    ph1 = ph;
    return (il | (ih << 6));
  }

void decode(int input)
  {
    int i;
    long int xa1;
    long int xa2;
    const int * h_ptr;
    int * ac_ptr;
    int * ac_ptr1;
    int * ad_ptr;
    int * ad_ptr1;
    ilr = input & 0x3f;
    ih = input >> 6;
    dec_szl = filtez(dec_del_bpl,dec_del_dltx);
    dec_spl = filtep(dec_rlt1,dec_al1,dec_rlt2,dec_al2);
    dec_sl = dec_spl+dec_szl;
    dec_dlt = ((long) dec_detl*qq4_code4_table[ilr >> 2]) >> 15;
    dl = ((long) dec_detl*qq6_code6_table[il]) >> 15;
    rl = dl+dec_sl;
    dec_nbl = logscl(ilr,dec_nbl);
    dec_detl = scalel(dec_nbl,8);
    dec_plt = dec_dlt+dec_szl;
    upzero(dec_dlt,dec_del_dltx,dec_del_bpl);
    dec_al2 = uppol2(dec_al1,dec_al2,dec_plt,dec_plt1,dec_plt2);
    dec_al1 = uppol1(dec_al1,dec_al2,dec_plt,dec_plt1);
    dec_rlt = dec_sl+dec_dlt;
    dec_rlt2 = dec_rlt1;
    dec_rlt1 = dec_rlt;
    dec_plt2 = dec_plt1;
    dec_plt1 = dec_plt;
    dec_szh = filtez(dec_del_bph,dec_del_dhx);
    dec_sph = filtep(dec_rh1,dec_ah1,dec_rh2,dec_ah2);
    dec_sh = dec_sph+dec_szh;
    dec_dh = ((long) dec_deth*qq2_code2_table[ih]) >> 15L;
    dec_nbh = logsch(ih,dec_nbh);
    dec_deth = scalel(dec_nbh,10);
    dec_ph = dec_dh+dec_szh;
    upzero(dec_dh,dec_del_dhx,dec_del_bph);
    dec_ah2 = uppol2(dec_ah1,dec_ah2,dec_ph,dec_ph1,dec_ph2);
    dec_ah1 = uppol1(dec_ah1,dec_ah2,dec_ph,dec_ph1);
    rh = dec_sh+dec_dh;
    dec_rh2 = dec_rh1;
    dec_rh1 = rh;
    dec_ph2 = dec_ph1;
    dec_ph1 = dec_ph;
    xd = rl-rh;
    xs = rl+rh;
    h_ptr = h;
    ac_ptr = accumc;
    ad_ptr = accumd;
    xa1 = (long) xd*(*h_ptr++);
    xa2 = (long) xs*(*h_ptr++);
    for(i = 0;i < 10;i++)
      {
        xa1 += (long) (*ac_ptr++)*(*h_ptr++);
        xa2 += (long) (*ad_ptr++)*(*h_ptr++);
      }
    xa1 += (long) (*ac_ptr)*(*h_ptr++);
    xa2 += (long) (*ad_ptr)*(*h_ptr++);
    xout1 = xa1 >> 14;
    xout2 = xa2 >> 14;
    ac_ptr1 = ac_ptr-1;
    ad_ptr1 = ad_ptr-1;
    for(i = 0;i < 10;i++)
      {
        *ac_ptr-- = *ac_ptr1--;
        *ad_ptr-- = *ad_ptr1--;
      }
    *ac_ptr = xd;
    *ad_ptr = xs;
  }

void reset()
  {
    int i;
    dec_detl = 32;
    detl = dec_detl;
    dec_deth = 8;
    deth = dec_deth;
    nbl = 0;
    al1 = 0;
    al2 = 0;
    plt1 = 0;
    plt2 = 0;
    rlt1 = 0;
    rlt2 = 0;
    nbh = 0;
    ah1 = 0;
    ah2 = 0;
    ph1 = 0;
    ph2 = 0;
    rh1 = 0;
    rh2 = 0;
    dec_nbl = 0;
    dec_al1 = 0;
    dec_al2 = 0;
    dec_plt1 = 0;
    dec_plt2 = 0;
    dec_rlt1 = 0;
    dec_rlt2 = 0;
    dec_nbh = 0;
    dec_ah1 = 0;
    dec_ah2 = 0;
    dec_ph1 = 0;
    dec_ph2 = 0;
    dec_rh1 = 0;
    dec_rh2 = 0;
    for(i = 0;i < 6;i++)
      {
        delay_dltx[i] = 0;
        delay_dhx[i] = 0;
        dec_del_dltx[i] = 0;
        dec_del_dhx[i] = 0;
      }
    for(i = 0;i < 6;i++)
      {
        delay_bpl[i] = 0;
        delay_bph[i] = 0;
        dec_del_bpl[i] = 0;
        dec_del_bph[i] = 0;
      }
    for(i = 0;i < 24;i++)
      {
        tqmf[i] = 0;
      }
    for(i = 0;i < 11;i++)
      {
        accumc[i] = 0;
        accumd[i] = 0;
      }
  }

int filtez(int * bpl,int * dlt)
  {
    int i;
    long int zl;
    zl = (long) (*bpl++)*(*dlt++);
    for(i = 1;i < 6;i++)
      {
        zl += (long) (*bpl++)*(*dlt++);
      }
    return ((int) (zl >> 14));
  }

int filtep(int rlt1,int al1,int rlt2,int al2)
  {
    int i_;
    int v_;
    int u_;
    long int pl;
    long int pl2;
    {
      v_ = pl2;
      if ((rlt1 & al1) == 42)
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
      pl2 = v_;
    }
    pl = 2*rlt1;
    pl = (long) al1*pl;
    pl2 = 2*rlt2;
    pl += (long) al2*pl2;
    return ((int) (pl >> 15));
  }

int quantl(int el,int detl)
  {
    int i_;
    int v_;
    int u_;
    int ril;
    int mil;
    long int wd;
    long int decis;
    wd = abs(el);
    for(mil = 0;mil < 30;mil++)
      {
        decis = (decis_levl[mil]*(long) detl) >> 15L;
        if (wd <= decis)
          {
            break;
          }
      }
    if (el >= 0)
      {
        ril = quant26bt_pos[mil];
      }
    else
      {
        ril = quant26bt_neg[mil];
        {
          v_ = decis;
          if ((el & detl) == 42)
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
          decis = v_;
        }
      }
    return (ril);
  }

int logscl(int il,int nbl)
  {
    int i_;
    int v_;
    int u_;
    long int wd;
    wd = ((long) nbl*127L) >> 7L;
    nbl = (int) wd+wl_code_table[il >> 2];
    if (nbl < 0)
      {
        nbl = 0;
      }
    if (nbl > 18432)
      {
        nbl = 18432;
        {
          v_ = wd;
          if ((il & nbl) == 42)
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
          wd = v_;
        }
      }
    return (nbl);
  }

int scalel(int nbl,int shift_constant)
  {
    int i_;
    int v_;
    int u_;
    int wd1;
    int wd2;
    int wd3;
    wd1 = (nbl >> 6) & 31;
    wd2 = nbl >> 11;
    {
      v_ = wd3;
      if ((nbl & shift_constant) == 42)
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
      wd3 = v_;
    }
    wd3 = ilb_table[wd1] >> (shift_constant+1-wd2);
    return (wd3 << 3);
  }

void upzero(int dlt,int * dlti,int * bli)
  {
    int i;
    int wd2;
    int wd3;
    if (dlt == 0)
      {
        for(i = 0;i < 6;i++)
          {
            bli[i] = (int) ((255L*bli[i]) >> 8L);
          }
      }
    else
      {
        for(i = 0;i < 6;i++)
          {
            if ((long) dlt*dlti[i] >= 0)
              {
                wd2 = 128;
              }
            else
              {
                wd2 = -128;
              }
            wd3 = (int) ((255L*bli[i]) >> 8L);
            bli[i] = wd2+wd3;
          }
      }
    dlti[5] = dlti[4];
    dlti[4] = dlti[3];
    dlti[3] = dlti[2];
    dlti[2] = dlti[1];
    dlti[1] = dlti[0];
    dlti[0] = dlt;
  }

int uppol2(int al1,int al2,int plt,int plt1,int plt2)
  {
    int i_;
    int v_;
    int u_;
    long int wd2;
    long int wd4;
    int apl2;
    wd2 = 4L*(long) al1;
    if ((long) plt*plt1 >= 0L)
      {
        wd2 = -wd2;
      }
    wd2 = wd2 >> 7;
    if ((long) plt*plt2 >= 0L)
      {
        wd4 = wd2+128;
      }
    else
      {
        {
          v_ = wd2;
          if ((al1 & al2) == 42)
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
          wd2 = v_;
        }
        wd4 = wd2-128;
      }
    apl2 = wd4+(127L*(long) al2 >> 7L);
    if (apl2 > 12288)
      {
        apl2 = 12288;
      }
    if (apl2 < -12288)
      {
        apl2 = -12288;
      }
    return (apl2);
  }

int uppol1(int al1,int apl2,int plt,int plt1)
  {
    int i_;
    int v_;
    int u_;
    long int wd2;
    int wd3;
    int apl1;
    wd2 = ((long) al1*255L) >> 8L;
    if ((long) plt*plt1 >= 0L)
      {
        apl1 = (int) wd2+192;
      }
    else
      {
        apl1 = (int) wd2-192;
        {
          v_ = wd2;
          if ((al1 & apl2) == 42)
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
          wd2 = v_;
        }
      }
    wd3 = 15360-apl2;
    if (apl1 > wd3)
      {
        apl1 = wd3;
      }
    if (apl1 < -wd3)
      {
        apl1 = -wd3;
      }
    return (apl1);
  }

int logsch(int ih,int nbh)
  {
    int i_;
    int v_;
    int u_;
    int wd;
    wd = ((long) nbh*127L) >> 7L;
    nbh = wd+wh_code_table[ih];
    if (nbh < 0)
      {
        {
          v_ = wd;
          if ((ih & nbh) == 42)
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
          wd = v_;
        }
        nbh = 0;
      }
    if (nbh > 22528)
      {
        nbh = 22528;
      }
    return (nbh);
  }
#define SIZE 100
#define IN_END 100
const int test_data[SIZE] = {0x44,0x44,0x44,0x44,0x44,0x44,0x44,0x44,0x44,0x44,0x44,0x44,0x44,0x44,0x44,0x44,0x44,0x43,0x43,0x43,0x43,0x43,0x43,0x43,0x42,0x42,0x42,0x42,0x42,0x42,0x41,0x41,0x41,0x41,0x41,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x3f,0x3f,0x3f,0x3f,0x3f,0x3e,0x3e,0x3e,0x3e,0x3e,0x3e,0x3d,0x3d,0x3d,0x3d,0x3d,0x3d,0x3c,0x3c,0x3c,0x3c,0x3c,0x3c,0x3c,0x3c,0x3c,0x3b,0x3b,0x3b,0x3b,0x3b,0x3b,0x3b,0x3b,0x3b,0x3b,0x3b,0x3b,0x3b,0x3b,0x3b,0x3b,0x3b,0x3b,0x3b,0x3b,0x3b,0x3b,0x3b,0x3c,0x3c,0x3c,0x3c,0x3c,0x3c,0x3c,0x3c};
int compressed[SIZE];
int result[SIZE];
const int test_compressed[SIZE] = {0xfd,0xde,0x77,0xba,0xf2,0x90,0x20,0xa0,0xec,0xed,0xef,0xf1,0xf3,0xf4,0xf5,0xf5,0xf5,0xf5,0xf6,0xf6,0xf6,0xf7,0xf8,0xf7,0xf8,0xf7,0xf9,0xf8,0xf7,0xf9,0xf8,0xf8,0xf6,0xf8,0xf8,0xf7,0xf9,0xf9,0xf9,0xf8,0xf7,0xfa,0xf8,0xf8,0xf7,0xfb,0xfa,0xf9,0xf8,0xf8};
const int test_result[SIZE] = {0,0xffffffff,0xffffffff,0,0,0xffffffff,0,0,0xffffffff,0xffffffff,0,0,0x1,0x1,0,0xfffffffe,0xffffffff,0xfffffffe,0,0xfffffffc,0x1,0x1,0x1,0xfffffffb,0x2,0x2,0x3,0xb,0x14,0x14,0x16,0x18,0x20,0x21,0x26,0x27,0x2e,0x2f,0x33,0x32,0x35,0x33,0x36,0x34,0x37,0x34,0x37,0x35,0x38,0x36,0x39,0x38,0x3b,0x3a,0x3f,0x3f,0x40,0x3a,0x3d,0x3e,0x41,0x3c,0x3e,0x3f,0x42,0x3e,0x3b,0x37,0x3b,0x3e,0x41,0x3b,0x3b,0x3a,0x3b,0x36,0x39,0x3b,0x3f,0x3c,0x3b,0x37,0x3b,0x3d,0x41,0x3d,0x3e,0x3c,0x3e,0x3b,0x3a,0x37,0x3b,0x3e,0x41,0x3c,0x3b,0x39,0x3a,0x36};

void adpcm_main()
  {
    int i;
    int j;
    reset();
    j = 10;
    for(i = 0;i < IN_END;i += 2)
      {
        compressed[i/2] = adpcm(test_data[i],test_data[i+1]);
      }
    for(i = 0;i < IN_END;i += 2)
      {
        decode(compressed[i/2]);
        result[i] = xout1;
        result[i+1] = xout2;
      }
  }

int main()
  {
    int i;
    int main_result;
    main_result = 0;
    adpcm_main();
    for(i = 0;i < IN_END/2;i++)
      {
        if (compressed[i] != test_compressed[i])
          {
            main_result += 1;
          }
      }
    for(i = 0;i < IN_END;i++)
      {
        if (result[i] != test_result[i])
          {
            main_result += 1;
          }
      }
    printf("%d\n",main_result);
    return main_result;
  }
