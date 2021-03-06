/************************************************************************************************************************/
data {
    int<lower=0> N_uncensored;                                      // number of uncensored data points
    int<lower=0> N_censored;                                        // number of censored data points
    int<lower=1> m;                                                 // number of basis splines
    int<lower=1> NC;                                                // number of covariates
    matrix[N_censored,NC] X_censored;                               // design matrix (censored)
    matrix[N_uncensored,NC] X_uncensored;                           // design matrix (uncensored)
    vector[N_censored] log_times_censored;                          // x=log(t) in the paper (censored)
    vector[N_uncensored] log_times_uncensored;                      // x=log(t) in the paper (uncensored)
    matrix[m,N_censored] basis_evals_censored;                      // ispline basis matrix (censored)
    matrix[m,N_uncensored] basis_evals_uncensored;                  // ispline basis matrix (uncensored)
    matrix[m,N_uncensored] deriv_basis_evals_uncensored;            // derivatives of isplines matrix (uncensored)
}
/************************************************************************************************************************/
parameters {
    row_vector<lower=0>[m] gammas;                                  // regression coefficients for splines
    vector[NC] betas;                                               // regression coefficients for covariates
    real gamma_intercept;                                           // \gamma_0 in the paper
}
/************************************************************************************************************************/
model {
    vector[N_censored] etas_censored;
    vector[N_uncensored] etas_uncensored;
    gammas ~ normal(0, 2);
    betas ~ normal(0,1);
    gamma_intercept   ~ normal(0,1);
    
    etas_censored = X_censored*betas + (gammas*basis_evals_censored)' + gamma_intercept;
    etas_uncensored = X_uncensored*betas + (gammas*basis_evals_uncensored)' + gamma_intercept;
    target += -exp(etas_censored);
    target += etas_uncensored - exp(etas_uncensored) - log_times_uncensored + log(gammas*deriv_basis_evals_uncensored)';
}
/************************************************************************************************************************/
