functions{
  int which_min(real [] y ){
    int ans = sort_indices_asc(y)[1];
    return(ans);
  }
  real approximate_ca0(real x, real[] x_pred, real[] y_pred){
    int K = size(x_pred);
    real deltas [K];
    real ans;
    int i;
    if(size(y_pred) != K) reject("x_pred and y_pred aren't of the same size");
    for(k in 1:K) deltas[k] = fabs(x_pred[k] - x);
    i = which_min(deltas);
    if(i != 1){
      real x1 = x_pred[i];
      real x2 = x_pred[i + 1];
      real y1 = y_pred[i];
      real y2 = y_pred[i + 1];
      ans = y1 + (y2-y1) * (x-x1)/(x2-x1);
    }else{
      ans = y_pred[i];
    }
    return(ans);
  }
}
data {
  int<lower=0> N0;
  int<lower=0> P;
  matrix[N0, P] X0;
  int<lower=0, upper=1> y0[N0];
  int<lower=0> N;
  matrix[N, P] X;
  int<lower=0, upper=1> y[N];
  real<lower=0> eta;
  real<lower=0> nu;
  /* Approximation stuff*/
  int<lower=0> K;
  real pred_grid_x[K];
  real pred_grid_y[K];
}
parameters {
  real alpha0;
  real alpha1;
  vector[P] beta0;
  vector[P] beta1;
  real<lower=0, upper=1> a_0;
}
model {
  /* Commensurate Power prior */
  target += -approximate_ca0(a_0, pred_grid_x, pred_grid_y);
  target += normal_lpdf(alpha0 | 0, 1);
  target += normal_lpdf(beta0 | 0, 1);
  target += a_0 * bernoulli_logit_lpmf(y0 | alpha0 + X0*beta0);
  target += beta_lpdf(a_0 | eta, nu);
  target += normal_lpdf(alpha1 | 0, 1);
  target += normal_lpdf(beta1 | 0, 1);
  /* Likelihood */
  target += bernoulli_logit_lpmf(y | alpha1 + X*beta1);
}
