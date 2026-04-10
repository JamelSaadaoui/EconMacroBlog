version 18.0

mata:
mata clear

real scalar function jie__quantile(
    real colvector x,
    real scalar p)
{
    real scalar n, pos, lo, hi, w

    x = sort(x, 1)
    n = rows(x)

    if (n == 0) return(.)
    if (n == 1) return(x[1])

    pos = 1 + (n - 1) * p
    lo  = floor(pos)
    hi  = ceil(pos)

    if (lo == hi) return(x[lo])

    w = pos - lo
    return((1 - w) * x[lo] + w * x[hi])
}

real rowvector function jie__colmeans(real matrix X)
{
    return(colsum(X) / rows(X))
}

real rowvector function jie__colvars(real matrix X)
{
    real rowvector mu

    if (rows(X) <= 1) return(J(1, cols(X), .))

    mu = jie__colmeans(X)
    return(colsum((X :- mu) :^ 2) / (rows(X) - 1))
}

real matrix function jie__build_xy(
    real matrix Yall,
    real colvector id,
    real colvector year,
    real colvector sample,
    real scalar p)
{
    real scalar N, K, nvalid, t, l, ok, r, c
    real matrix ZX

    N = rows(Yall)
    K = cols(Yall)

    nvalid = 0
    for (t = p + 1; t <= N; t++) {
        ok = (sample[t] == 1)
        if (ok) {
            for (l = 1; l <= p; l++) {
                if (id[t - l] != id[t]                           |
                    (year[t] - year[t - l]) != l                 |
                    sample[t - l] != 1) {
                    ok = 0
                    break
                }
            }
        }
        nvalid = nvalid + ok
    }

    ZX = J(nvalid, K + K * p + 1, .)

    r = 1
    for (t = p + 1; t <= N; t++) {
        ok = (sample[t] == 1)
        if (ok) {
            for (l = 1; l <= p; l++) {
                if (id[t - l] != id[t]                           |
                    (year[t] - year[t - l]) != l                 |
                    sample[t - l] != 1) {
                    ok = 0
                    break
                }
            }
        }

        if (ok) {
            ZX[r, 1..K] = Yall[t, .]
            c = K + 1
            for (l = 1; l <= p; l++) {
                ZX[r, c..(c + K - 1)] = Yall[t - l, .]
                c = c + K
            }
            ZX[r, cols(ZX)] = 1
            r = r + 1
        }
    }

    return(ZX)
}

real matrix function jie__rwishart(
    real matrix V,
    real scalar df)
{
    real scalar K, i
    real matrix A, C

    K = rows(V)
    A = J(K, K, 0)

    for (i = 1; i <= K; i++) {
        A[i, i] = sqrt(rchi2(1, 1, df - i + 1))
        if (i < K) {
            A[(i + 1)..K, i] = rnormal(K - i, 1, 0, 1)
        }
    }

    C = cholesky(V)
    return(C * A * A' * C')
}

real matrix function jie__riwishart(
    real matrix S,
    real scalar df)
{
    real matrix Winv

    S = 0.5 :* (S + S')
    Winv = jie__rwishart(invsym(S), df)

    return(invsym(Winv))
}

real matrix function jie__companion(
    real matrix B,
    real scalar K,
    real scalar p)
{
    real scalar l
    real matrix F

    F = J(K * p, K * p, 0)

    for (l = 1; l <= p; l++) {
        F[1..K, ((l - 1) * K + 1)..(l * K)] =
            B[((l - 1) * K + 1)..(l * K), .]'
    }

    if (p > 1) {
        F[(K + 1)..(K * p), 1..(K * (p - 1))] = I(K * (p - 1))
    }

    return(F)
}

real scalar function jie__get_scale(
    real colvector state,
    real scalar K,
    real scalar scale_idx)
{
    real scalar den

    if (scale_idx <= 0) return(1)

    if (scale_idx > K) {
        errprintf("scale_idx out of range in jie__get_scale().\n")
        exit(3301)
    }

    den = state[scale_idx, 1]

    if (missing(den) | abs(den) < 1e-12) {
        den = 1
    }

    return(den)
}

real matrix function jie__oirf(
    real matrix B,
    real matrix Sigma,
    real scalar K,
    real scalar p,
    real scalar H,
    real scalar shock_idx,
    real scalar scale_idx)
{
    real scalar h, scale
    real matrix F, P, irf
    real colvector state

    F = jie__companion(B, K, p)
    P = cholesky(0.5 :* (Sigma + Sigma'))

    state = J(K * p, 1, 0)
    state[1..K, 1] = P[, shock_idx]

    scale = jie__get_scale(state, K, scale_idx)

    irf = J(H + 1, K, .)
    irf[1, .] = (state[1..K, 1] :/ scale)'

    for (h = 1; h <= H; h++) {
        state = F * state
        irf[h + 1, .] = (state[1..K, 1] :/ scale)'
    }

    return(irf)
}

real matrix function jie__bvar_draws_from_xy(
    real matrix Y,
    real matrix X,
    real scalar p,
    real scalar H,
    real scalar ndraws,
    real scalar shock_idx,
    real scalar scale_idx)
{
    real scalar T, K, m, nu, d, h, j, idx
    real matrix XtX, Vb, Bhat, E, S, Cb
    real matrix Sigma, Cs, Z, B, irf, draws

    T = rows(Y)
    K = cols(Y)
    m = cols(X)
    nu = T - m

    if (T <= m | nu <= K - 1) {
        errprintf("Not enough effective observations ")
        errprintf("for the Jeffreys-prior posterior.\n")
        exit(3499)
    }

    XtX  = quadcross(X, X)
    Vb   = invsym(XtX)
    Bhat = Vb * quadcross(X, Y)
    E    = Y - X * Bhat
    S    = quadcross(E, E)
    S    = 0.5 :* (S + S')

    Cb = cholesky(Vb)

    draws = J(ndraws, (H + 1) * K, .)

    for (d = 1; d <= ndraws; d++) {
        Sigma = jie__riwishart(S, nu)
        Cs    = cholesky(0.5 :* (Sigma + Sigma'))
        Z     = rnormal(m, K, 0, 1)
        B     = Bhat + Cb * Z * Cs'
        irf   = jie__oirf(B, Sigma, K, p, H, shock_idx, scale_idx)

        idx = 1
        for (h = 1; h <= H + 1; h++) {
            for (j = 1; j <= K; j++) {
                draws[d, idx] = irf[h, j]
                idx = idx + 1
            }
        }
    }

    return(draws)
}

void function jie__summarize_draws(
    real matrix draws,
    real scalar H,
    real scalar K,
    string scalar mat_q05,
    string scalar mat_q50,
    string scalar mat_q95,
    string scalar mat_mean,
    string scalar mat_var)
{
    real scalar h, j, idx
    real rowvector mu, va
    real matrix q05, q50, q95, meanm, varm

    q05   = J(H + 1, K, .)
    q50   = J(H + 1, K, .)
    q95   = J(H + 1, K, .)
    meanm = J(H + 1, K, .)
    varm  = J(H + 1, K, .)

    mu = jie__colmeans(draws)
    va = jie__colvars(draws)

    idx = 1
    for (h = 1; h <= H + 1; h++) {
        for (j = 1; j <= K; j++) {
            q05[h, j]   = jie__quantile(draws[, idx], 0.05)
            q50[h, j]   = jie__quantile(draws[, idx], 0.50)
            q95[h, j]   = jie__quantile(draws[, idx], 0.95)
            meanm[h, j] = mu[idx]
            varm[h, j]  = va[idx]
            idx = idx + 1
        }
    }

    st_matrix(mat_q05, q05)
    st_matrix(mat_q50, q50)
    st_matrix(mat_q95, q95)
    st_matrix(mat_mean, meanm)
    st_matrix(mat_var, varm)
}

void function jie_bvar_pooled_summary(
    string scalar yvars,
    string scalar panelvar,
    string scalar timevar,
    string scalar samplevar,
    real scalar p,
    real scalar H,
    real scalar ndraws,
    real scalar shock_idx,
    real scalar scale_idx,
    string scalar mat_q05,
    string scalar mat_q50,
    string scalar mat_q95,
    string scalar mat_mean,
    string scalar mat_var,
    string scalar scalar_neff)
{
    string rowvector vars
    real matrix Yall, ZX, Y, X, draws
    real colvector id, year, sample
    real scalar K

    vars   = tokens(yvars)
    Yall   = st_data(., vars)
    id     = st_data(., panelvar)
    year   = st_data(., timevar)
    sample = st_data(., samplevar)

    K  = cols(Yall)
    ZX = jie__build_xy(Yall, id, year, sample, p)
    Y  = ZX[, 1..K]
    X  = ZX[, (K + 1)..cols(ZX)]

    draws = jie__bvar_draws_from_xy(
        Y, X, p, H, ndraws, shock_idx, scale_idx)

    jie__summarize_draws(
        draws, H, K, mat_q05, mat_q50, mat_q95, mat_mean, mat_var)

    st_numscalar(scalar_neff, rows(Y))
}

void function jie_bvar_units_aggregate(
    string scalar yvars,
    string scalar panelvar,
    string scalar timevar,
    string scalar samplevar,
    real scalar minobs,
    real scalar p,
    real scalar H,
    real scalar ndraws,
    real scalar shock_idx,
    real scalar scale_idx,
    string scalar mat_ivw,
    string scalar mat_ew,
    string scalar mat_q05,
    string scalar mat_q95,
    string scalar scalar_ncountry)
{
    string rowvector vars
    real matrix Yall, ZX, Y, X, draws, all_draws
    real matrix mean_store, var_store, ivw, ew, q05, q95
    real colvector id, year, sample, w, agg
    real scalar N, K, cells, start, stop, i, j, h, idx
    real scalar Ti, ncountry, cstart, cend, sw

    vars   = tokens(yvars)
    Yall   = st_data(., vars)
    id     = st_data(., panelvar)
    year   = st_data(., timevar)
    sample = st_data(., samplevar)

    N     = rows(id)
    K     = cols(Yall)
    cells = (H + 1) * K

    ncountry = 0
    start = 1
    while (start <= N) {
        stop = start
        while (stop <= N) {
            if (id[stop] != id[start]) break
            stop++
        }
        stop = stop - 1

        Ti = sum(sample[start..stop])
        if (Ti >= minobs) ncountry = ncountry + 1

        start = stop + 1
    }

    if (ncountry == 0) {
        errprintf("No countries satisfy ")
        errprintf("the minimum-observation rule.\n")
        exit(3499)
    }

    all_draws  = J(ndraws, cells * ncountry, .)
    mean_store = J(ncountry, cells, .)
    var_store  = J(ncountry, cells, .)

    i = 0
    start = 1
    while (start <= N) {
        stop = start
        while (stop <= N) {
            if (id[stop] != id[start]) break
            stop++
        }
        stop = stop - 1

        Ti = sum(sample[start..stop])

        if (Ti >= minobs) {
            i = i + 1

            ZX = jie__build_xy(
                Yall[start..stop, .],
                id[start..stop],
                year[start..stop],
                sample[start..stop],
                p)

            Y = ZX[, 1..K]
            X = ZX[, (K + 1)..cols(ZX)]

            draws = jie__bvar_draws_from_xy(
                Y, X, p, H, ndraws, shock_idx, scale_idx)

            mean_store[i, .] = jie__colmeans(draws)
            var_store[i, .]  = jie__colvars(draws)

            cstart = (i - 1) * cells + 1
            cend   = i * cells
            all_draws[, cstart..cend] = draws
        }

        start = stop + 1
    }

    ivw = J(H + 1, K, .)
    ew  = J(H + 1, K, .)
    q05 = J(H + 1, K, .)
    q95 = J(H + 1, K, .)

    idx = 1
    for (h = 1; h <= H + 1; h++) {
        for (j = 1; j <= K; j++) {
            w = J(ncountry, 1, 0)

            for (i = 1; i <= ncountry; i++) {
                if (var_store[i, idx] > 0 & var_store[i, idx] < .) {
                    w[i] = 1 / var_store[i, idx]
                }
            }

            sw = sum(w)
            if (sw <= 0) {
                w = J(ncountry, 1, 1 / ncountry)
            }
            else {
                w = w / sw
            }

            ivw[h, j] = w' * mean_store[, idx]
            ew[h, j]  = sum(mean_store[, idx]) / ncountry

            agg = J(ndraws, 1, 0)
            for (i = 1; i <= ncountry; i++) {
                cstart = (i - 1) * cells + idx
                agg = agg + w[i] * all_draws[, cstart]
            }

            q05[h, j] = jie__quantile(agg, 0.05)
            q95[h, j] = jie__quantile(agg, 0.95)

            idx = idx + 1
        }
    }

    st_matrix(mat_ivw, ivw)
    st_matrix(mat_ew, ew)
    st_matrix(mat_q05, q05)
    st_matrix(mat_q95, q95)
    st_numscalar(scalar_ncountry, ncountry)
}

end