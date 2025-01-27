library(Rcpp)
library(RcppEigen)

log_prodction <-  function(l, k , omega, eta, beta_0, beta_l, beta_k) {
  ln_y = beta_0 + beta_l*l + beta_k*k +omega + eta 
  return(ln_y)
}

log_labor_choice <- function(k, wage, omega, beta_0, beta_l, beta_k, sigma_eta) { 
  n = length(k)
  eta = rnorm(n, 0, sigma_eta)
  ln_l = (1/(1-beta_l)) * log(((1/wage) * beta_l * exp(beta_0+omega) * exp(k)^beta_k))
  return(ln_l)
}

log_labor_choice_error <- function(k, wage, omega, beta_0, beta_l, beta_k, iota, sigma_eta) { 
  n = length(k)
  eta = rnorm(n, 0, sigma_eta)
  ln_l = (1/(1-beta_l)) * log(((1/wage) * beta_l *exp(beta_0+omega+iota) * exp(k)^beta_k)) 
  return(ln_l)
}

investment_choice <- function(k, omega, gamma, delta){
  I = (delta + gamma*omega)*k
  return(I)
}

moment_OP_2nd <- function(alpha, beta_0, beta_k, df, df_T_1st) {
  J <- max(df$j, na.rm =TRUE)
  T <- max(df$t)
  
  df <- df %>%
    group_by(j) %>%
    arrange(j, t) %>%
    mutate(lag_k = lag(k, default=0),
           lag_I = lag(I, default=0) %>%
    ungroup()
  
  mat <- as.matrix(df[c("k", "lag_k", "lag_I")])
  y_error_tilde <- df_T_1st$y_error_tilde
  phi_t_1 <- df_T_1st$phi_t_1
  
  moment <- moment_OP_2nd_rcpp(T, J, alpha, beta_0, beta_k,
                               y_error_tilde, phi_t_1, mat)
  return(moment)
}

objective_OP_2nd <- function(alpha, beta_0, beta_k, df_T, df_T_1st) {
  
  smp_mom <- as.matrix(moment_OP_2nd(alpha, beta_0, beta_k, df_T, df_T_1st))
  
  print(smp_mom)
  
  n <-  length(smp_mom)
  W <- diag(n)
  
  obj_val <- t(smp_mom) %*% W %*% smp_mom
  
  return(obj_val)
  
}
