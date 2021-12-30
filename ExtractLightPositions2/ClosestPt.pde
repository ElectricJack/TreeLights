

float getv(PVector v, int i) {
  if(i == 0) return v.x;
  if(i == 1) return v.y;
  return v.z;
}

void setv(PVector v, int i, float value) {
  if      (i == 0) v.x = value;
  else if (i == 1) v.y = value;
  else             v.z = value;
}

void incv(PVector v, int i, float value) {
  setv(v,i,getv(v,i) + value);
}

float getm(float[] mm, int r, int c)              { return mm[c + r*4]; }
void  setm(float[] mm, int r, int c, float value) { mm[c + r*4] = value; }
void  incm(float[] mm, int r, int c, float value) { mm[c + r*4] += value; }

PVector findNearestPoint(PVector a[], PVector d[]) {
  var mm = new float[16];
  
  var b = new PVector();
  var n = a.length;
  for (int i = 0; i < n; ++i) {
    var d2 = d[i].dot(d[i]);
    var da = d[i].dot(a[i]);
    
    for (int ii = 0; ii < 3; ++ii) {
      for (int jj = 0; jj < 3; ++jj) {
        //m[ii][jj] += d[i][ii] * d[i][jj];
        incm(mm,ii,jj, getv(d[i],ii) * getv(d[i],jj));
      }
      
      //m[ii][ii] -= d2;
      incm(mm, ii,ii, -d2);
      
      //b[ii] += d[i][ii] * da - a[i][ii] * d2;
      incv(b, ii, getv(d[i], ii) * da - getv(a[i], ii) * d2);
    }
  }
  
  var p = solve(mm, new float[] {b.x, b.y, b.z});
  return new PVector(p[0],p[1],p[2]);
}

// Verifier
float dist2(PVector p, PVector a, PVector d) {
  PVector pa  = new PVector( a.x-p.x, a.y-p.y, a.z-p.z );
  float   dpa = d.dot(pa);
  return  d.dot(d) * pa.dot(pa) - dpa * dpa;
}

//double sum_dist2(VEC p, VEC a[], VEC d[], int n) {
float sum_dist2(PVector p, PVector a[], PVector d[]) {
  int n = a.length;
  float sum = 0;
  for (int i = 0; i < n; ++i) { 
    sum += dist2(p, a[i], d[i]);
  }
  return sum;
}

// Check 26 nearby points and verify the provided one is nearest.
boolean isNearest(PVector p, PVector a[], PVector d[]) {
  float min_d2 = 3.4028235E38;
  int   ii = 2, jj = 2, kk = 2;
  final float D  = 0.1f;
  
  for (int i = -1; i <= 1; ++i) 
    for (int j = -1; j <= 1; ++j)
      for (int k = -1; k <= 1; ++k) {
        PVector pp = new PVector( p.x + D * i, p.y + D * j, p.z + D * k );
        float d2 = sum_dist2(pp, a, d);
        // Prefer provided point among equals.
        if (d2 < min_d2 || i == 0 && j == 0 && k == 0 && d2 == min_d2) {
          min_d2 = d2;
          ii = i; jj = j; kk = k;
        }
      }
      
  return ii == 0 && jj == 0 && kk == 0;
}




// From rosettacode (with bug fix: added a missing fabs())
int mat_elem(int y, int x) { return y*4+x; }

void swap_row(float[] a, float[] b, int r1, int r2, int n)
{
  float tmp;
  int p1, p2;
  int i;

  if (r1 == r2) return;
  
  for (i = 0; i < n; i++) {
    p1 = mat_elem(r1, i);
    p2 = mat_elem(r2, i);
    
    tmp = a[p1];
    a[p1] = a[p2];
    a[p2] = tmp;
  }
  
  tmp = b[r1];
  b[r1] = b[r2];
  b[r2] = tmp;
}


float[] solve(float[] a, float[] b)
{
  float[] x = new float[] {0,0,0};
  int n = x.length;
  int i, j, col, row, max_row, dia;
  float max, tmp;

  for (dia = 0; dia < n; dia++) {
    max_row = dia;
    max = abs(getm(a, dia, dia));
    for (row = dia + 1; row < n; row++) {
      if ((tmp = abs(getm(a, row, dia))) > max) { 
        max_row = row;
        max = tmp;
      }
    }
    swap_row(a, b, dia, max_row, n);
    for (row = dia + 1; row < n; row++) {
      tmp = getm(a, row, dia) / getm(a, dia, dia);
      for (col = dia+1; col < n; col++) {
        incm(a, row, col, -tmp * getm(a, dia, col));
      }
      setm(a,row,dia, 0);
      b[row] -= tmp * b[dia];
    }
  }
  for (row = n - 1; row >= 0; row--) {
    tmp = b[row];
    for (j = n - 1; j > row; j--) {
      tmp -= x[j] * getm(a, row, j);
    }
    x[row] = tmp / getm(a, row, row);
  }
  
  return x;
}
