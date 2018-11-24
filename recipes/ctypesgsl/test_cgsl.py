from math import sin, cos, pi, sqrt, exp, log

import ctypesGsl as cgsl

print("ctypesGsl imported!")


def test_gsl_basic():
    print(cgsl.strerror(cgsl.GSL_ENOTSQR))
    try:
        raise cgsl.GSL_Error(cgsl.GSL_ENOTSQR)
    except cgsl.GSL_Error as ge:
        print("Caught GSL error: " + str(ge))
    p = cgsl.permutation(5)
    try:
        p[10]
        p.swap(2,10)
    except cgsl.GSL_Error as ge:
        pass
    except IndexError:
        pass
    eh = cgsl.set_error_handler_off()
    try:
        p.swap(2,10)
    except cgsl.GSL_Error as ge:
        print("Caught GSL error: " + str(ge))
    
    sh = cgsl.set_status_handler_off()
    p.swap(2,10) # don't throw expection here
    cgsl.set_status_handler_warning()
    p.swap(2,10) # just print a warning here
    cgsl.set_status_handler_exception()
    try:
        p.swap(2,10) # just print a warning here
    except cgsl.GSL_Error as ge:
        print("Caught GSL error: " + str(ge))
    
    cgsl.set_status_handler(sh)
    cgsl.set_error_handler(eh)

    print(cgsl.isnan(1.0))
    print(cgsl.isnan(cgsl.GSL_NAN))
    print(cgsl.isinf(cgsl.atanh(1)))
    print(cgsl.finite(cgsl.atanh(1)))
    
    
    print(cgsl.log1p(1.0))
    print(cgsl.expm1(0.0))
    print(cgsl.hypot(4, 3))
    print(cgsl.acosh(2))
    print(cgsl.asinh(1))
    print(cgsl.atanh(1))
    print(cgsl.ldexp(1, 10))
    print(cgsl.frexp(2))
    
    print(cgsl.pow_int(3, 5))
    print(cgsl.pow_5(3))
    print(cgsl.pow_9(2))

    print(cgsl.GSL_SIGN(-2), cgsl.GSL_SIGN(0), cgsl.GSL_SIGN(2))
    print(cgsl.GSL_IS_ODD(4), cgsl.GSL_IS_ODD(5))
    print(cgsl.GSL_IS_EVEN(4), cgsl.GSL_IS_EVEN(5))
    
    print(cgsl.fcmp(1.0, 1.0, 0.0001), cgsl.fcmp(1.0, 1.001, 0.01), cgsl.fcmp(1.0, 1.1, 0.01))
    

def test_gsl_complex():
    c1 = cgsl.complex_rect(1,2.12345)
    c2 = cgsl.complex_polar(1,0)
    c3 = cgsl.gsl_complex(2+3j)
    c4 = cgsl.gsl_complex(5,6)
    print(c1, c2, c3, c4)
    print(c1.real, c1.imag)
    print(c2.real, c2.imag)
    c1.real = 7
    print(c1, cgsl.complex_polar(c1.abs, c1.arg), cgsl.complex_polar(sqrt(c1.abs2), c1.arg), end=' ')
    print(cgsl.complex_polar(exp(c1.logabs), c1.arg))

    print(c1 + c1)
    print(c1 + (1+1j), c1 + 1.0)
    print((1+1j) + c1, 1.0 + c1)

    print(c1 - c1)
    print(c1 - (1+1j), c1 - 1.0)
    print((1+1j) - c1, 1.0 - c1)

    print(c1 * c1)
    print(c1 * (1+1j), c1 * 2.0)
    print((1+1j) * c1, 2.0 * c1)

    print(c1 / c1)
    print(c1 / (1+1j), c1 / 2.0)
    print((1+1j) / c1, 1.0 / c1)

    print(c1, c1.mul_imag(1))
    print(c1.abs, abs(c1), -c1, +c1)
    print(c1 * c1.inverse())
    print(cgsl.gsl_complex(0).inverse())

    print(cgsl.complex_sqrt_real(-1))
    print(c1, cgsl.complex_sqrt(c1)**2, cgsl.complex_sqrt(c1)**(2+0j))
    print(c1, cgsl.complex_log(cgsl.complex_exp(c1)), 10**cgsl.complex_log10(c1), end=' ')
    print(c3**cgsl.complex_log_b(c1, c3))

    print(cgsl.complex_sin(c1) / cgsl.complex_cos(c1), cgsl.complex_tan(c1))
    print(c1, cgsl.complex_cos(cgsl.complex_arccos(c1)))
    print(2, cgsl.complex_sin(cgsl.complex_arcsin_real(2)))
    print(c1, cgsl.complex_cosh(cgsl.complex_arccosh(c1)))

    # test complex_float
    c1 = cgsl.gsl_complex_float(2+3j)
    c2 = cgsl.gsl_complex_float(5,6)
    print(c1, c2)
    print(c1.real, c1.imag)
    c1.real = -1; c1.imag = -2
    print(c1)
    print(complex(c1))

def test_poly():
    r = cgsl.poly_solve_quadratic(1, 1, -1)
    print(r, [cgsl.poly([-1,1,1])(x) for x in r])
    r = cgsl.poly_solve_quadratic(1, -2, 1)
    print(r, [cgsl.poly([1,-2,1])(x) for x in r])
    r = cgsl.poly_solve_quadratic(0, -2, 1)
    print(r, [cgsl.poly([1,-2,0])(x) for x in r])
    r = cgsl.poly_solve_quadratic(1, 0, 1)
    print(r, [cgsl.poly([1,0,1])(x) for x in r])

    r = cgsl.poly_complex_solve_quadratic(1, 0, 1)
    print(str(r[0]), str(r[1]), [str(x*x+1) for x in r])

    print(cgsl.poly_solve_cubic(-6, 11, -6)) # should be 1,2,3
    r = cgsl.poly_complex_solve_cubic(0, 0, 1)
    print([str(x*x*x + 1) for x in r])

    P = cgsl.poly([5,-1,2,5,0,3])
    print(P(0))
    print(P[0])
    P[0] = -5
    print(P(0))
    print(P)

    def print_roots(r):
        for x in r:
            print(x)
    print_roots(cgsl.poly([1, 0, 1]).roots())
    print_roots(cgsl.poly([-6, 11, -6, 1]).roots())
    print_roots(cgsl.poly([27, 0, 0, 1]).roots())
    print_roots(cgsl.poly([-1, 0, 0, 0, 0, 1]).roots())

    # divided difference form
    try:
        cgsl.poly_dd([1,2], [3,4,5])
    except cgsl.GSL_Error as ge:
        print("Caught exception: ", ge)

    Pd = cgsl.poly_dd([-5,-4,-3,-2,-1,0,1,2,3,4,5], [0,0,0,0,0,1,1,1,1,1,1])
    print(Pd.degree())
    print(Pd(-3), Pd(0), Pd(3))


    pT = Pd.taylor(0)
    print(pT(-3), pT(0), pT(3))
    pT2 = Pd.taylor(2)
    print(pT2(-3 -2), pT2(0 -2), pT2(3 -2))

    #from pylab import plot, show
    #X = []; Y = []; T = []; T2 = []
    #for i in xrange(1000):
    #    x = 10 * i / float(1000) - 5
    #    X.append(x)
    #    Y.append(Pd(x))
    #    T.append(pT(x))
    #    T2.append(pT2(x - 2))
    #plot(X, Y)
    #plot(X, T)
    #plot(X, T2)
    #show()

def test_sf():
    r = cgsl.gsl_sf_result(1,0.01)
    print(r, float(r))

    print(cgsl.sf_airy_Ai(5),";", cgsl.sf_airy_Ai_e(5))
    print(cgsl.sf_airy_Bi(5),";", cgsl.sf_airy_Bi_e(5))
    print(cgsl.sf_airy_Ai_scaled(5),";", cgsl.sf_airy_Ai_scaled_e(5))
    print(cgsl.sf_airy_Bi_scaled(5),";", cgsl.sf_airy_Bi_scaled_e(5))
    print(cgsl.sf_airy_Ai_deriv(5),";", cgsl.sf_airy_Ai_deriv_e(5))
    print(cgsl.sf_airy_Bi_deriv(5),";", cgsl.sf_airy_Bi_deriv_e(5))
    print(cgsl.sf_airy_Ai_deriv_scaled(5),";", cgsl.sf_airy_Ai_deriv_scaled_e(5))
    print(cgsl.sf_airy_Bi_deriv_scaled(5),";", cgsl.sf_airy_Bi_deriv_scaled_e(5))
    print(cgsl.sf_airy_zero_Ai(5),";", cgsl.sf_airy_zero_Ai_e(5),";",cgsl.sf_airy_Ai(cgsl.sf_airy_zero_Ai(5)))
    print(cgsl.sf_airy_zero_Bi(5),";", cgsl.sf_airy_zero_Bi_e(5),";",cgsl.sf_airy_Bi(cgsl.sf_airy_zero_Bi(5)))
    print(cgsl.sf_airy_zero_Ai_deriv(5),";", cgsl.sf_airy_zero_Ai_deriv_e(5),";",cgsl.sf_airy_Ai_deriv(cgsl.sf_airy_zero_Ai_deriv(5)))
    print(cgsl.sf_airy_zero_Bi_deriv(5),";", cgsl.sf_airy_zero_Bi_deriv_e(5),";",cgsl.sf_airy_Bi_deriv(cgsl.sf_airy_zero_Bi_deriv(5)))

    print()
    print(cgsl.sf_bessel_J0(1),";", cgsl.sf_bessel_J0_e(1))
    print(cgsl.sf_bessel_J1(1),";", cgsl.sf_bessel_J1_e(1))
    print(cgsl.sf_bessel_Jn(2,1),";", cgsl.sf_bessel_Jn_e(2,1))
    print(cgsl.sf_bessel_Jn_array(0, 2, 1))
    print(cgsl.sf_bessel_Y0(1),";", cgsl.sf_bessel_Y0_e(1))
    print(cgsl.sf_bessel_Y1(1),";", cgsl.sf_bessel_Y1_e(1))
    print(cgsl.sf_bessel_Yn(2,1),";", cgsl.sf_bessel_Yn_e(2,1))
    print(cgsl.sf_bessel_Yn_array(0, 2, 1))
    print(cgsl.sf_bessel_I0(1),";", cgsl.sf_bessel_I0_e(1))
    print(cgsl.sf_bessel_I1(1),";", cgsl.sf_bessel_I1_e(1))
    print(cgsl.sf_bessel_In(2,1),";", cgsl.sf_bessel_In_e(2,1))
    print(cgsl.sf_bessel_In_array(0, 2, 1))

    print(cgsl.sf_bessel_j0(1),";", cgsl.sf_bessel_j0_e(1))
    print(cgsl.sf_bessel_j1(1),";", cgsl.sf_bessel_j1_e(1))
    print(cgsl.sf_bessel_j2(1),";", cgsl.sf_bessel_j2_e(1))
    print(cgsl.sf_bessel_jl(3,1),";", cgsl.sf_bessel_jl_e(3,1))
    print(cgsl.sf_bessel_jl_array(3, 1))
    print(cgsl.sf_bessel_jl_steed_array(3, 1))

    print(cgsl.sf_bessel_k0_scaled(1),";", cgsl.sf_bessel_k0_scaled_e(1))
    print(cgsl.sf_bessel_k1_scaled(1),";", cgsl.sf_bessel_k1_scaled_e(1))
    print(cgsl.sf_bessel_k2_scaled(1),";", cgsl.sf_bessel_k2_scaled_e(1))
    print(cgsl.sf_bessel_kl_scaled(3,1),";", cgsl.sf_bessel_kl_scaled_e(3,1))
    print(cgsl.sf_bessel_kl_scaled_array(3, 1))

    print(cgsl.sf_bessel_Jnu(2,1),";", cgsl.sf_bessel_Jnu_e(2,1))
    print(cgsl.sf_bessel_sequence_Jnu(2,[1,2,3]))
    print(cgsl.sf_bessel_Ynu(2,1),";", cgsl.sf_bessel_Ynu_e(2,1))

    print(cgsl.sf_bessel_zero_J0(3), cgsl.sf_bessel_J0(cgsl.sf_bessel_zero_J0(3)))
    print(cgsl.sf_bessel_zero_J1(3), cgsl.sf_bessel_J1(cgsl.sf_bessel_zero_J1(3)))
    print(cgsl.sf_bessel_zero_Jnu(1.5, 3), cgsl.sf_bessel_Jnu(1.5, cgsl.sf_bessel_zero_Jnu(1.5, 3)))

    print()
    print(cgsl.sf_clausen(1), cgsl.sf_clausen_e(1))

    print()
    res = cgsl.sf_coulomb_wave_FG_e(0.5, 1, 4.5, 3)
    print(res.F, res.Fp)
    print(res.G, res.Gp)
    print(res.expF, res.expG)
    res = cgsl.sf_coulomb_wave_FG_e(1000, 10, 0, 0)
    print(res.expF, res.expG)
    print(cgsl.sf_coulomb_wave_F_array(4.5, 2, 0.5, 1))
    print(cgsl.sf_coulomb_wave_F_array(0, 1, 1000, 10))
    print(cgsl.sf_coulomb_wave_FG_array(4.5, 2, 0.5, 1))
    print(cgsl.sf_coulomb_wave_FG_array(0, 1, 1000, 10))
    res = cgsl.sf_coulomb_wave_FGp_array(4.5, 2, 0.5, 1)
    print(res.Fa, res.Fpa)
    print(res.Ga, res.Gpa)
    print(res.expF, res.expG)
    res = cgsl.sf_coulomb_wave_FGp_array(0, 1, 1000, 10)
    print(res.Fa, res.Fpa)
    print(res.Ga, res.Gpa)
    print(res.expF, res.expG)

    print()
    print(cgsl.sf_dawson(1), cgsl.sf_dawson_e(1))

    print()
    res = cgsl.sf_complex_dilog_e(0+0.99999j)
    print(cgsl.sf_complex_dilog(0+0.99999j),";",res[0], res[1])

    print()
    print(cgsl.sf_multiply_e(2, 3))
    print(cgsl.sf_multiply_e(2.1, 3.1))
    r = cgsl.sf_multiply_e(2, 3)
    print(cgsl.sf_multiply_err_e(r, r))

    print()
    print(cgsl.sf_ellint_F(0.5, 1), cgsl.sf_ellint_F_e(0.5, 1))
    print(cgsl.sf_ellint_D(0.5, 1, 2), cgsl.sf_ellint_D_e(0.5, 1, 2))
    print(cgsl.sf_ellint_RJ(0.5, 1, 2, 1), cgsl.sf_ellint_RJ_e(0.5, 1, 2, 1))

    print()
    print(cgsl.sf_elljac(0.1, 0.2))

    print()
    print(cgsl.sf_erf(1), cgsl.sf_erf_e(1))
    print(cgsl.sf_erfc(1), cgsl.sf_erfc_e(1))
    print(cgsl.sf_log_erfc(1), cgsl.sf_log_erfc_e(1))
    print(cgsl.sf_erf_Z(1), cgsl.sf_erf_Z_e(1))
    print(cgsl.sf_erf_Q(1), cgsl.sf_erf_Q_e(1))

    print()
    print(cgsl.sf_exp(1), cgsl.sf_exp_e(1))
    print(cgsl.sf_exp_e10_e(1))
    print(cgsl.sf_exp_e10_e(1000))
    print(cgsl.sf_exp_e10_e(1000000))
    # those give smaller error than without multiplication (strange):
    print(cgsl.sf_exp_mult_e10_e(1000000, 1))
    print(cgsl.sf_exp_mult_e10_e(1000000, 2))
    x = cgsl.gsl_sf_result(1, 0.1)
    y = cgsl.gsl_sf_result(2, 0.1)
    print(cgsl.sf_exp_err_e(x), cgsl.sf_exp_err_e10_e(x)) # strange error estimates
    print(cgsl.sf_exp_mult_err_e(x, y), cgsl.sf_exp_mult_err_e10_e(x, y))

    print(cgsl.sf_lngamma(-4.1), cgsl.sf_lngamma_e(-4.1))
    r = cgsl.sf_lngamma_sgn_e(-4.1)
    print(r[0], r[1])
    r = cgsl.sf_lngamma_complex_e_polar(-4.1)
    print(r[0], r[1])
    r = cgsl.sf_lngamma_complex_e_polar(1+1j)
    print(r[0], r[1])
    g = cgsl.sf_lngamma_complex(1+1j)
    print(g, g.abs, g.arg)

    print(cgsl.sf_fact(5), exp(cgsl.sf_lnfact(5)))
    print(cgsl.sf_choose(5, 3), cgsl.sf_choose_e(5, 3))

    r = cgsl.sf_lnpoch_sgn_e(3, 5)
    print(r[0], r[1])

    print(cgsl.sf_beta_e(2, 5))
    print(cgsl.sf_beta_inc_e(2, 5, 1))

    print()
    print(cgsl.sf_gegenpoly_n(0, 0.5, 1.0), end=' ')
    print(cgsl.sf_gegenpoly_1(0.5, 1), cgsl.sf_gegenpoly_2(0.5, 1), end=' ')
    print(cgsl.sf_gegenpoly_3(0.5, 1), cgsl.sf_gegenpoly_n(1, 0.5, 1.0))
    print(cgsl.sf_gegenpoly_array(4, 0.5, 1))

    print()
    print(cgsl.sf_hyperg_U_int_e10_e(1, 2, 1e-300))
    # GSL error: overflow shouldn't happen:
    print(cgsl.sf_hyperg_U_e10_e(1.5, 2.5, 1e-200))
    try:
        print(cgsl.sf_hyperg_U_e10_e(1.0, 2.5, 1e-300))
    except cgsl.GSL_Error as ge:
        print("bug in GSL:", ge)

    print()
    print(cgsl.sf_legendre_Pl(0, 1), end=' ')
    print(cgsl.sf_legendre_P1(1), cgsl.sf_legendre_P2(1), cgsl.sf_legendre_P3(1))
    print(cgsl.sf_legendre_Pl_array(3, 1))

    print(cgsl.sf_legendre_H3d_0(0.5, 1.5), cgsl.sf_legendre_H3d_1(0.5, 1.5), cgsl.sf_legendre_H3d(2, 0.5, 1.5))
    print(cgsl.sf_legendre_H3d_array(2, 0.5, 1.5))

    print()
    print(cgsl.sf_complex_log(2+0.5j), cgsl.complex_exp(cgsl.sf_complex_log(2+0.5j)))
    r, e = cgsl.sf_complex_log_e(2+0.5j)
    print(r, e)

    print()
    print(cgsl.sf_pow_int(3, 12),  cgsl.sf_pow_int_e(3, 12))

    print()
    print(cgsl.sf_complex_sin(pi/2), cgsl.sf_complex_cos(pi/2), cgsl.sf_complex_logsin(pi/2))
    r, e = cgsl.sf_complex_sin_e(pi/2)
    print(r, e)

def test_vector():
    v = cgsl.vector(5)
    v.set_all(1)
    v[3] = 7
    print(v)
    vc = cgsl.vector_complex(10)
    vc.set_all(2+3j)
    print(vc)
    vcf = cgsl.vector_complex_float(10)
    vcf[0] = 3+5j
    print(vcf[0])
    vcf.set_all(5)
    print(vcf)
    vcf.set_zero()
    print(vcf)
    vcf.set_basis(2)
    print(vcf)
    try:
        vcf.set_basis(len(vcf))
    except cgsl.GSL_Error as ge:
        print("Caught exception: Index out of range")

    # views
    vcf2 = vcf.subvector(0, 5)
    print(vcf2)
    print(vcf2.subvector(0, 3, 2))
    vcf2.subvector(0, 3, 2).set_all(cgsl.gsl_complex_float(4,7))
    print(vcf)
    print(vc.real())
    print(vc.imag())
    print(vcf2.real())
    print(vcf2.imag())

    # copy & swap
    cp = vcf2.copy()
    cp[0] = -1
    print(cp, vcf2)
    cp.swap(vcf2)
    print(cp, vcf2)

    vcf2.real().swap_elements(0, 2)
    print(vcf2)
    vcf2.reverse()
    print(vcf2)

    # arithmetic
    print(v)
    v += v
    print(v)
    v += 1
    print(v)
    v *= v
    print(v)
    v *= 1.5
    print(v)

    vf = cgsl.vector_float(v)
    print(vf)
    vf /= 1.5
    print(vf)
    vf /= cgsl.vector_float([sqrt(x) for x in vf])
    print(vf)
    vf -= 1
    print(vf)
    vf /= 2
    print(vf)

    # minmax
    print(vf.min(), vf.max(), vf.minmax())
    print(vf.min_index(), vf.max_index(), vf.minmax_index())

    #properties
    #print vf.ispos(), vf.isneg()
    print(vf.isnull())
    vf -= vf
    print(vf.isnull())

def test_matrix():
    m = cgsl.matrix(3, 4)
    m.set_all(1)
    m[(1,2)] = 7
    print(m)
    mc = cgsl.matrix_complex(3, 4)
    mc.set_all(2+3j)
    print(mc)
    mcf = cgsl.matrix_complex_float(3,4)
    mcf[0,0] = 3+5j
    print(mcf[0,0])
    mcf.set_all(5)
    print(mcf)
    mcf.set_zero()
    print(mcf)
    mcf.set_identity()
    print(mcf)

    m0 = cgsl.matrix(1,1)
    m0.set_zero()
    print(m0)
    
    # views
    mcf2 = mcf.submatrix(1, 0, 2, 2)
    print(mcf2)
    print(mcf2.submatrix(1, 1, 1, 1))
    mcf2.submatrix(1, 1, 1, 1).set_all(cgsl.gsl_complex_float(4,7))
    print(mcf)

    print(mcf.row(0))
    print(mcf.row(2))
    print(mcf2.row(0))
    print(mcf2.row(1))
    print(mcf.column(0))
    print(mcf.column(1))
    mcf.column(0)[-1] = 3+3j
    print(mcf)

    print()
    print(mcf.diagonal())
    mcf.diagonal().set_all(-2)
    print(mcf)
    mcf.diagonal(1).set_all(-1)
    mcf.diagonal(-1).set_zero()
    print(mcf)
    mcf.superdiagonal(1).set_all(-4)
    mcf.subdiagonal(1).set_all(4)
    print(mcf)

    for r in mcf.rowiter():
        print(r)
    for c in mcf.columniter():
        print(c)

    # copy & swap
    cp = mcf2.copy()
    cp[0, 0] = -1
    print(cp, mcf2)
    cp.swap(mcf2)
    print(cp, mcf2)

    vcf_r = cgsl.vector_complex_float(mcf.shape[1])
    vcf_c = cgsl.vector_complex_float(mcf.shape[0])
    mcf.copy_row(1, vcf_r)
    mcf.copy_col(1, vcf_c)
    print(mcf)
    print(vcf_r, vcf_c)
    vcf_r[0] = 0
    vcf_c[0] = 0
    mcf.set_row(1, vcf_r)
    mcf.set_col(1, vcf_c)
    print(mcf)

    mcf.swap_rows(1, 2)
    print(mcf)
    mcf.swap_columns(0, 1)
    print(mcf)

    msq = cgsl.matrix_int(4, 4)
    msq.set_zero()
    msq.row(0).set_all(1)
    msq.row(1).set_all(2)
    print(msq)
    msq.swap_rowcol(0, 1)
    print(msq)
    msq.transpose()
    print(msq)

    print(mcf, mcf.T())
    return

    # arithmetic
    print(m)
    m += m
    print(m)
    m += 1
    print(m)
    m *= m
    print(m)
    m *= 1.5
    print(m)

    mf = cgsl.matrix_float(m)
    print(mf)
    mf /= 1.5
    print(mf)
    mf_sqrt = cgsl.matrix_float(mf)
    for i in range(mf_sqrt.shape[0]):
        for j in range(mf_sqrt.shape[1]):
            mf_sqrt[i, j] = sqrt(mf[i, j])
    mf /= mf_sqrt
    print(mf)
    mf -= 1
    print(mf)
    mf /= 2
    print(mf)

    r = mf.row(2)
    r *= 3.5
    print(mf)

    # minmax
    print(mf.min(), mf.max(), mf.minmax())
    print(mf.min_index(), mf.max_index(), mf.minmax_index())

    #properties
    #print mf.ispos(), mf.isneg()
    print(mf.isnull())
    mf -= mf
    print(mf.isnull())


def test_blas():
    x = cgsl.vector_float([1,2,3,4])
    y = cgsl.vector_float([4,3,2,1])
    print(cgsl.blas_sdsdot(1.5, x, y))
    print(cgsl.blas_sdsdot(0, x, y))
    print(cgsl.blas_sdsdot(0, x, [4,3,2,1]))
    print(cgsl.blas_sdsdot(0, [1,2,3,4], [4,3,2,1]))
    
    print(cgsl.blas_sdot(x, y))
    print(cgsl.blas_dsdot(x, y))

    xd = cgsl.vector([1,2,3,4])
    yd = cgsl.vector([4,3,2,1])
    print(cgsl.blas_ddot(x, y))
    print(cgsl.blas_ddot([1,2,3,4], yd))
    print(cgsl.blas_ddot([1,2,3,4], [4,3,2,1]))

    print(cgsl.blas_cdotu(x, y))
    print(cgsl.blas_cdotu([0+1j,0+2j,0+3j,0+4j], [0+4j,0+3j,0+2j,0+1j]))
    print(cgsl.blas_zdotu(xd, yd))
    print(cgsl.blas_zdotu([0+1j,0+2j,0+3j,0+4j], [0+4j,0+3j,0+2j,0+1j]))
    print(cgsl.blas_cdotc(x, y))
    print(cgsl.blas_cdotc([0+1j,0+2j,0+3j,0+4j], [0+4j,0+3j,0+2j,0+1j]))
    print(cgsl.blas_zdotc(x, y))
    print(cgsl.blas_zdotc([0+1j,0+2j,0+3j,0+4j], [0+4j,0+3j,0+2j,0+1j]))

    print(cgsl.blas_snrm2(x), sqrt(30))
    print(cgsl.blas_dnrm2(xd), sqrt(30))
    print(cgsl.blas_scnrm2(x), sqrt(30))
    print(cgsl.blas_dznrm2(x), sqrt(30))

    print(cgsl.blas_sasum(x))
    print(cgsl.blas_dasum(xd))
    print(cgsl.blas_scasum(x))
    print(cgsl.blas_dzasum(xd))

    print(cgsl.blas_isamax(x))
    print(cgsl.blas_idamax(x))
    print(cgsl.blas_icamax(x))
    print(cgsl.blas_izamax(x))

    cgsl.blas_sswap(x, y); print(x, y)
    cgsl.blas_sswap(x, y); print(x, y)
    try:
        cgsl.blas_sswap(xd, yd); print("Error!!!")
    except:
        pass
    cgsl.blas_dswap(xd, yd); print(xd, yd)
    cgsl.blas_dswap(xd, yd); print(xd, yd)
    try:
        cgsl.blas_dswap(x, y); print("Error!!!")
    except:
        pass
    xc = cgsl.vector_complex_float([1j,2j,3j,4j])
    yc = cgsl.vector_complex_float([4j,3j,2j,1j])
    xz = cgsl.vector_complex([1j,2j,3j,4j])
    yz = cgsl.vector_complex([4j,3j,2j,1j])
    cgsl.blas_cswap(xc, yc); print(xc, yc)
    cgsl.blas_cswap(xc, yc); print(xc, yc)
    try:
        cgsl.blas_cswap(xz, yz); print("Error!!!")
    except:
        pass
    cgsl.blas_zswap(xz, yz); print(xz, yz)
    cgsl.blas_zswap(xz, yz); print(xz, yz)
    try:
        cgsl.blas_zswap(xc, yc); print("Error!!!")
    except:
        pass

    cgsl.blas_scopy([4,5,6,7], y); print(y)
    cgsl.blas_scopy(x, y); print(y)
    cgsl.blas_dcopy([4,5,6,7], yd); print(yd)
    cgsl.blas_dcopy(xd, yd); print(yd)
    cgsl.blas_ccopy([4,5,6,7], yc); print(yc)
    cgsl.blas_ccopy(xc, yc); print(yc)
    cgsl.blas_zcopy([4,5,6,7], yz); print(yz)
    cgsl.blas_zcopy(xz, yz); print(yz)

    cgsl.blas_saxpy([4,5,6,7], y); print(y)
    cgsl.blas_saxpy([4,5,6,7], y, alpha = -1); print(y)
    print(cgsl.blas_saxpy([4,5,6,7], [2,3,4,5], -1))
    cgsl.blas_daxpy([4,5,6,7], yd); print(yd)
    cgsl.blas_daxpy([4,5,6,7], yd, -1); print(yd)

    cgsl.blas_caxpy([4,5,6,7], yc); print(yc)
    cgsl.blas_caxpy([4,5,6,7], yc, -1j); print(yc)
    cgsl.blas_zaxpy([4,5,6,7], yz); print(yz)
    cgsl.blas_zaxpy([4,5,6,7], yz, -1j); print(yz)

    cgsl.blas_sscal(2.0, y); print(y)
    cgsl.blas_sscal(0.5, y); print(y)
    cgsl.blas_dscal(2.0, yd); print(yd)
    cgsl.blas_dscal(0.5, yd); print(yd)
    cgsl.blas_cscal(2.0j, yc); print(yc)
    cgsl.blas_cscal(-0.5j, yc); print(yc)
    cgsl.blas_zscal(2.0j, yz); print(yz)
    cgsl.blas_zscal(-0.5j, yz); print(yz)
    cgsl.blas_csscal(2.0, yc); print(yc)
    cgsl.blas_csscal(0.5, yc); print(yc)
    cgsl.blas_zdscal(2.0, yz); print(yz)
    cgsl.blas_zdscal(0.5, yz); print(yz)

    print(cgsl.blas_srotg(1,1))
    print(cgsl.blas_drotg(1,1))

    cgsl.blas_srot(x, y, sqrt(2)/2, sqrt(2)/2); print(x, y)
    cgsl.blas_srot(x, y, sqrt(2)/2, -sqrt(2)/2); print(x, y)
    cgsl.blas_drot(xd, yd, sqrt(2)/2, sqrt(2)/2); print(xd, yd)
    cgsl.blas_drot(xd, yd, sqrt(2)/2, -sqrt(2)/2); print(xd, yd)

    A = [[1,1,1,1], [0,1,0,0], [0,0,1,0], [0,0,0,1]]
    print(cgsl.matrix(A))
    zs = cgsl.vector_float([0,0,0,0])
    zd = cgsl.vector([0,0,0,0])
    zc = cgsl.vector_complex_float([0,0,0,0])
    zz = cgsl.vector_complex([0,0,0,0])
    cgsl.blas_sgemv(cgsl.matrix_float(A), [1,2,3,4], beta=1,y=zs)
    print(zs)
    print(cgsl.blas_sgemv(A, [1,2,3,4]))
    cgsl.blas_dgemv(cgsl.matrix(A), [1,2,3,4], y=zd)
    print(zd)
    print(cgsl.blas_dgemv(A, [1,2,3,4]))
    cgsl.blas_cgemv(cgsl.matrix_complex_float(A), [1,2,3,4], beta=1, y=zc)
    print(zc)
    print(cgsl.blas_cgemv(A, [1j,2j,3j,4j]))
    cgsl.blas_zgemv(cgsl.matrix_complex(A), [1,2,3,4], beta=1, y=zz)
    print(zz)
    print(cgsl.blas_zgemv(A, [1j,2j,3j,4j]))

    zs = cgsl.vector_float([1,2,3,4])
    cgsl.blas_strmv(cgsl.matrix_float(A), zs)
    print(zs)
    print(cgsl.blas_strmv(A, [1,2,3,4]))
    print(cgsl.blas_strmv(A, [1,2,3,4], Uplo=cgsl.CblasLower))
    zd = cgsl.vector([1,2,3,4])
    cgsl.blas_dtrmv(cgsl.matrix(A), zd)
    print(zd)
    print(cgsl.blas_dtrmv(A, [1,2,3,4]))
    print(cgsl.blas_dtrmv(A, [1,2,3,4], Uplo=cgsl.CblasLower))
    zc = cgsl.vector_complex_float([1,2,3,4])
    cgsl.blas_ctrmv(cgsl.matrix_complex_float(A), zc)
    print(zc)
    print(cgsl.blas_ctrmv(A, [1,2,3,4]))
    print(cgsl.blas_ctrmv(A, [1,2,3,4], Uplo=cgsl.CblasLower))
    zz = cgsl.vector_complex([1,2,3,4])
    cgsl.blas_ztrmv(cgsl.matrix_complex(A), zz)
    print(zz)
    print(cgsl.blas_ztrmv(A, [1,2,3,4]))
    print(cgsl.blas_ztrmv(A, [1,2,3,4], Uplo=cgsl.CblasLower))

    z = cgsl.blas_strsv(A, [1,2,3,4])
    print(z)
    print(cgsl.blas_strmv(A, z))
    print(cgsl.blas_strsv(A, [1,2,3,4], Uplo=cgsl.CblasLower))
    z = cgsl.blas_dtrsv(A, [1,2,3,4])
    print(z)
    print(cgsl.blas_dtrmv(A, z))
    print(cgsl.blas_dtrsv(A, [1,2,3,4], Uplo=cgsl.CblasLower))
    z = cgsl.blas_ctrsv(A, [1,2,3,4])
    print(z)
    print(cgsl.blas_ctrmv(A, z))
    print(cgsl.blas_ctrsv(A, [1,2,3,4], Uplo=cgsl.CblasLower))
    z = cgsl.blas_ztrsv(A, [1,2,3,4])
    print(z)
    print(cgsl.blas_ztrmv(A, z))
    print(cgsl.blas_ztrsv(A, [1,2,3,4], Uplo=cgsl.CblasLower))

    A2 = [[1,1,1,1], [1,1,1,1], [1,1,1,1], [0,0,0,1]]
    z = cgsl.blas_ssymv(A2, [1,2,3,4])
    print(z) 
    cgsl.blas_ssymv(A2, [1,2,3,4], beta=1, y=z)
    print(z)
    print(cgsl.blas_ssymv(A2, [1,2,3,4], y=[-1,-1,-1,-1]))
    z = cgsl.blas_dsymv(A2, [1,2,3,4])
    print(z) 
    cgsl.blas_dsymv(A2, [1,2,3,4], beta=1, y=z)
    print(z)
    print(cgsl.blas_dsymv(A2, [1,2,3,4], y=[-1,-1,-1,-1]))

    z = cgsl.blas_chemv(A2, [1,2,3,4])
    print(z) 
    cgsl.blas_chemv(A2, [1,2,3,4], beta=1, y=z)
    print(z)
    print(cgsl.blas_chemv(A2, [1,2,3,4], y=[-1,-1,-1,-1]))
    z = cgsl.blas_zhemv(A2, [1,2,3,4])
    print(z) 
    cgsl.blas_zhemv(A2, [1,2,3,4], beta=1, y=z)
    print(z)
    print(cgsl.blas_zhemv(A2, [1,2,3,4], y=[-1,-1,-1,-1]))

    print(cgsl.blas_sger([1,1,1,1], [1,1,1,1], A))
    print(cgsl.blas_dger([1,1,1,1], [1,1,1,1], A))
    print(cgsl.blas_cgeru([1j,1j,1j,1j], [1,1,1,1], A))
    print(cgsl.blas_zgeru([1j,1j,1j,1j], [1,1,1,1], A))
    print(cgsl.blas_cgerc([1j,1j,1j,1j], [1,1,1,1], A))
    print(cgsl.blas_zgerc([1j,1j,1j,1j], [1,1,1,1], A))
    print(cgsl.blas_cgerc([1,1,1,1], [1j,1j,1j,1j], A))
    print(cgsl.blas_zgerc([1,1,1,1], [1j,1j,1j,1j], A))

    Af = cgsl.matrix_float(A)
    cgsl.blas_ssyr([1,1,1,1], Af)
    print(Af)
    print(cgsl.blas_ssyr([1,1,1,1], A))
    Ad = cgsl.matrix(A)
    cgsl.blas_dsyr([1,1,1,1], Ad)
    print(Ad)
    print(cgsl.blas_dsyr([1,1,1,1], A))
    cgsl.blas_dsyr([1,1,1,1], Af)
    print(Af) # should be unchanged here as we need to copy Af into double format

    print(cgsl.blas_cher([1j,1j,1j,1j], A))
    print(cgsl.blas_zher([1j,1j,1j,1j], A))

    A3 = [[1,1,1,1], [1,1,1,1], [1,1,1,1], [1,1,1,1]]
    print(cgsl.blas_ssyr2([1,1,1,1], [1,1,1,1], A3))
    print(cgsl.blas_dsyr2([1,1,1,1], [1,1,1,1], A3))
    print(cgsl.blas_cher2([1j,1j,1j,1j], [1,1,1,1], A3))
    print(cgsl.blas_zher2([1j,1j,1j,1j], [1,1,1,1], A3))

    ### LEVEL 3
    A = [[1,2,3,4],[2,3,4,5],[3,4,5,6]]
    B = [[1,2],[1,3],[1,4],[1,5]]
    BT = [[1,1,1,1],[2,3,4,5]]
    C = [[1,1],[1,1],[1,1]]
    print(cgsl.blas_sgemm(A, B))
    print(cgsl.blas_sgemm(B, A, TransA = cgsl.CblasTrans, TransB = cgsl.CblasTrans, alpha=1))
    print(cgsl.blas_sgemm(A, B, beta = -1, C = C))
    print(cgsl.blas_dgemm(A, B))
    print(cgsl.blas_dgemm(B, A, TransA = cgsl.CblasTrans, TransB = cgsl.CblasTrans, alpha = 1))
    print(cgsl.blas_dgemm(A, B, beta = -1, C = C))
    print(cgsl.blas_cgemm(A, B, alpha = 1j))
    print(cgsl.blas_cgemm(B, A, TransA = cgsl.CblasTrans, TransB = cgsl.CblasTrans, alpha = 1j))
    print(cgsl.blas_cgemm(A, B, beta = -1j, C = C))
    print(cgsl.blas_zgemm(A, B, alpha = 1j))
    print(cgsl.blas_zgemm(B, A, TransA = cgsl.CblasTrans, TransB = cgsl.CblasTrans, alpha = 1j))
    print(cgsl.blas_zgemm(A, B, beta = -1j, C = C))

    A4 = [[1,1,1,1], [0,1,1,1], [0,0,1,1], [0,0,0,1]]
    C4 = [[-1,-1]] * 4
    print(cgsl.blas_ssymm(A4, B))
    print(cgsl.blas_ssymm(A4, BT, Side = cgsl.CblasRight))
    print(cgsl.blas_ssymm(A4, B, beta = -1, C = C4))
    print(cgsl.blas_dsymm(A4, B))
    print(cgsl.blas_dsymm(A4, BT, Side = cgsl.CblasRight))
    print(cgsl.blas_dsymm(A4, B, beta = -1, C = C4))
    print(cgsl.blas_csymm(A4, B))
    print(cgsl.blas_csymm(A4, BT, Side = cgsl.CblasRight))
    print(cgsl.blas_csymm(A4, B, beta = -1, C = C4))
    print(cgsl.blas_zsymm(A4, B))
    print(cgsl.blas_zsymm(A4, BT, Side = cgsl.CblasRight))
    print(cgsl.blas_zsymm(A4, B, beta = -1, C = C4))

    print(cgsl.blas_chemm(A4, B))
    print(cgsl.blas_chemm(A4, BT, Side = cgsl.CblasRight))
    print(cgsl.blas_chemm(A4, B, beta = -1, C = C4))
    print(cgsl.blas_zhemm(A4, B))
    print(cgsl.blas_zhemm(A4, BT, Side = cgsl.CblasRight))
    print(cgsl.blas_zhemm(A4, B, beta = -1, C = C4))

    print(cgsl.blas_strmm(A4, B))
    print(cgsl.blas_strmm(A4, BT, Side = cgsl.CblasRight))
    print(cgsl.blas_dtrmm(A4, B))
    print(cgsl.blas_dtrmm(A4, BT, Side = cgsl.CblasRight))
    print(cgsl.blas_ctrmm(A4, B))
    print(cgsl.blas_ctrmm(A4, BT, Side = cgsl.CblasRight))
    print(cgsl.blas_ztrmm(A4, B))
    print(cgsl.blas_ztrmm(A4, BT, Side = cgsl.CblasRight))

    BB = cgsl.blas_strsm(A4, B)
    print(cgsl.blas_strmm(A4, BB))
    BB = cgsl.blas_dtrsm(A4, B)
    print(cgsl.blas_dtrmm(A4, BB))
    BB = cgsl.blas_ctrsm(A4, B)
    print(cgsl.blas_ctrmm(A4, BB))
    BB = cgsl.blas_ztrsm(A4, B)
    print(cgsl.blas_ztrmm(A4, BB))

    print(cgsl.blas_ssyrk(C4, A3, beta = 1))
    print(cgsl.blas_dsyrk(C4, A3, beta = 1))
    print(cgsl.blas_csyrk(C4, A3, beta = 1))
    print(cgsl.blas_zsyrk(C4, A3, beta = 1))
    print(cgsl.blas_cherk(C4, A3, beta = 1))
    print(cgsl.blas_zherk(C4, A3, beta = 1))

    print(cgsl.blas_ssyr2k(C4, C4, A3))
    print(cgsl.blas_dsyr2k(C4, C4, A3))
    print(cgsl.blas_csyr2k(C4, C4, A3))
    print(cgsl.blas_zsyr2k(C4, C4, A3))
    print(cgsl.blas_cher2k(C4, C4, A3))
    print(cgsl.blas_zher2k(C4, C4, A3))

def test_linalg():
    A = [[0.18, 0.60, 0.57, 0.96],
         [0.41, 0.24, 0.99, 0.58],
         [0.14, 0.30, 0.97, 0.66],
         [0.51, 0.13, 0.19, 0.85]]
    b = [1,2,3,4]
    LU, p, s = cgsl.linalg_LU_decomp(A)
    print(LU, p, s)
    x = cgsl.linalg_LU_solve(LU, p, b)
    print(x)
    print(cgsl.blas_dgemv(A, x))
    LUc, p, s = cgsl.linalg_complex_LU_decomp(A)
    print(LUc, p, s)
    xc = cgsl.linalg_complex_LU_solve(LUc, p, b)
    print(xc)
    print(cgsl.blas_zgemv(A, xc))

    x = cgsl.vector(b)
    cgsl.linalg_LU_svx(LU, p, x)
    print(x)
    print(cgsl.blas_dgemv(A, x))
    x = cgsl.linalg_LU_svx(LU, p, b)
    print(cgsl.blas_dgemv(A, x))

    xc = cgsl.vector_complex(b)
    cgsl.linalg_complex_LU_svx(LU, p, xc)
    print(xc)
    print(cgsl.blas_zgemv(A, xc))
    xc = cgsl.linalg_complex_LU_svx(LU, p, b)
    print(cgsl.blas_zgemv(A, xc))

    x = cgsl.vector(b)
    for i in range(3):
        x, tau = cgsl.linalg_LU_refine(A, LU, p, b, x)
        print("refinement", i+1, ":")
        print("  ", x)
        print("  ", tau, cgsl.blas_snrm2(tau))
    xc = cgsl.vector(b)
    xc, tauc = cgsl.linalg_complex_LU_refine(A, LUc, p, b, xc)
    print(xc, tauc)

    Ainv = cgsl.linalg_LU_invert(LU, p)
    print(Ainv)
    print(cgsl.blas_dgemm(Ainv, A))
    Ainvc = cgsl.linalg_complex_LU_invert(LUc, p)
    print(Ainvc)
    print(cgsl.blas_zgemm(Ainvc, A))

    Ad = [[1,0,0,0],[0,2,0,0],[0,0,3,0],[0,0,0,4]]
    LUd, pd, sd = cgsl.linalg_LU_decomp(Ad)
    print(cgsl.linalg_LU_det(LUd, sd))
    print(cgsl.linalg_complex_LU_det(LUd, sd))
    print(exp(cgsl.linalg_LU_lndet(LUd)) * cgsl.linalg_LU_sgndet(LUd, sd))
    print(exp(cgsl.linalg_complex_LU_lndet(LUd)) * cgsl.linalg_complex_LU_sgndet(LUd, sd))

    #QR decomp
    print()
    B = [[1,2,3],[2,0,4],[3,4,5], [5,5,5]]
    QRA, tauA = cgsl.linalg_QR_decomp(A)
    print(QRA, tauA)
    QRB, tauB = cgsl.linalg_QR_decomp(cgsl.matrix(B))
    print(QRB, tauB)
    x = cgsl.linalg_QR_solve(QRA, tauA, b)
    print(x)
    print(cgsl.blas_dgemv(A, x))
    x = cgsl.vector(b)
    cgsl.linalg_QR_svx(QRA, tauA, x)
    print(x, cgsl.blas_dgemv(A, x))

    x, res = cgsl.linalg_QR_lssolve(QRA, tauA, b)
    print(x)
    print(cgsl.blas_dgemv(A, x))
    x, res = cgsl.linalg_QR_lssolve(QRB, tauB, b)
    print(x, res, cgsl.blas_snrm2(res))
    print(cgsl.blas_dgemv(B, x))

    v = cgsl.linalg_QR_QTvec(QRA, tauA, b)
    print(v)
    print(cgsl.linalg_QR_Qvec(QRA, tauA, v))

    x = cgsl.linalg_QR_Rsolve(QRA, cgsl.linalg_QR_QTvec(QRA, tauA, b))
    print(cgsl.blas_dgemv(A, x))
    x = cgsl.linalg_QR_Rsvx(QRA, cgsl.linalg_QR_QTvec(QRA, tauA, b))
    print(cgsl.blas_dgemv(A, x))

    Q,R = cgsl.linalg_QR_unpack(QRB, tauB)
    print(Q)
    print(R)
    print(cgsl.blas_dgemm(Q, Q, TransB = cgsl.CblasTrans))
    print(cgsl.linalg_QR_QTmat(QRB, tauB, Q))

    Q,R = cgsl.linalg_QR_unpack(QRA, tauA)
    x = cgsl.linalg_QR_QRsolve(Q, R, b)
    print(cgsl.blas_dgemv(A, x))
    x = cgsl.linalg_R_solve(R, b)
    print(cgsl.blas_dgemv(R, x))
    x = cgsl.linalg_R_svx(R, b)
    print(cgsl.blas_dgemv(R, x))
    print()

    ### !!! bug in documentation, need to premultiply w by Q^T
    w = cgsl.blas_dgemv(Q, [1,1,1,1], TransA = cgsl.CblasTrans)
    Q2, R2 = cgsl.linalg_QR_update(Q, R, w, [1,1,1,1])
    print(cgsl.blas_dgemm(Q2,R2)) 
    AA = cgsl.matrix(A)
    for i in range(4):
        for j in range(4):
            AA[i,j] += 1
    print(AA)

    #QR decomp with pivoting

    QRA, tauA, pA, s = cgsl.linalg_QRPT_decomp(A)
    print(QRA, tauA, pA, s)
    QA,RA,tau,p,s =cgsl.linalg_QRPT_decomp2(A)
    print(QA,RA,tau,p,s)
    print(A)
    print(cgsl.blas_dgemm(QA, RA))

    x = cgsl.linalg_QRPT_solve(QRA, tauA, pA, b)
    print(cgsl.blas_dgemv(A, x))
    x = cgsl.vector(b)
    cgsl.linalg_QRPT_svx(QRA, tauA, pA, x)
    print(cgsl.blas_dgemv(A, x))
    x = cgsl.linalg_QRPT_QRsolve(QA, RA, pA, b)
    print(cgsl.blas_dgemv(A, x))
    qb = cgsl.blas_dgemv(QA, b, TransA = cgsl.CblasTrans)
    x = cgsl.linalg_QRPT_Rsolve(QRA, pA, qb)
    print(cgsl.blas_dgemv(A, x))
    cgsl.linalg_QRPT_Rsvx(QRA, pA, qb)
    print(cgsl.blas_dgemv(A, qb))

    ### !!! bug in documentation, need to premultiply w by Q^T
    w = cgsl.blas_dgemv(QA, [1,1,1,1], TransA = cgsl.CblasTrans)
    Q2, R2 = cgsl.linalg_QR_update(QA, RA, w, [1,1,1,1])
    print(cgsl.blas_dgemm(Q2,R2)) 
    AA = cgsl.matrix(A)
    for i in range(4):
        for j in range(4):
            AA[i,j] += 1
    print(AA, p)

    # Singular Value Decomposition
    def make_diag(s):
        n = len(s)
        S = cgsl.matrix(n,n)
        S.set_zero()
        for i in range(n):
            S[i,i] = s[i]
        return S
    U,V,s = cgsl.linalg_SV_decomp(A)
    S = make_diag(s)
    print(cgsl.blas_dgemm(U, cgsl.blas_dgemm(S, V, TransB = cgsl.CblasTrans)))
    x = cgsl.linalg_SV_solve(U,V,s,b)
    print(cgsl.blas_dgemv(A, x))
    print(B)
    U,V,s = cgsl.linalg_SV_decomp(B)
    S = make_diag(s)
    print(cgsl.blas_dgemm(U, cgsl.blas_dgemm(S, V, TransB = cgsl.CblasTrans)))
    U,V,s = cgsl.linalg_SV_decomp_mod(B)
    S = make_diag(s)
    print(cgsl.blas_dgemm(U, cgsl.blas_dgemm(S, V, TransB = cgsl.CblasTrans)))
    U,V,s = cgsl.linalg_SV_decomp_jacobi(B)
    S = make_diag(s)
    print(cgsl.blas_dgemm(U, cgsl.blas_dgemm(S, V, TransB = cgsl.CblasTrans)))

    # Cholesky Decomposition
    def clear_upper(M):
        for i in range(M.shape[0]):
            for j in range(i+1, M.shape[1]):
                M[i,j] = 0
    try:
        LL = cgsl.linalg_cholesky_decomp(A)
        print("!!! Error: nonpositive matrix not detected")
    except cgsl.GSL_Error as e:
        print("OK: Matrix not positive definite")
    Apos = cgsl.blas_dgemm(A,A,TransB = cgsl.CblasTrans)
    print(Apos)
    LL = cgsl.linalg_cholesky_decomp(Apos)
    clear_upper(LL)
    print(LL)
    print(cgsl.blas_dgemm(LL,LL,TransB = cgsl.CblasTrans))
    Aposc = cgsl.blas_dgemm(A,A,TransB = cgsl.CblasTrans)
    LLc = cgsl.linalg_complex_cholesky_decomp(Aposc)
    clear_upper(LLc)
    print(cgsl.blas_zgemm(LLc,LLc,TransB = cgsl.CblasTrans))

    Apos = cgsl.blas_dgemm(A,A,TransB = cgsl.CblasTrans)
    LL = cgsl.linalg_cholesky_decomp(Apos)
    x = cgsl.linalg_cholesky_solve(LL, b)
    Apos = cgsl.blas_dgemm(A,A,TransB = cgsl.CblasTrans)
    print(cgsl.blas_dgemv(Apos, x))
    x = cgsl.vector(b)
    cgsl.linalg_cholesky_svx(LL, x)
    print(cgsl.blas_dgemv(Apos, x))
    Aposc = cgsl.blas_dgemm(A,A,TransB = cgsl.CblasTrans)
    LLc = cgsl.linalg_complex_cholesky_decomp(Aposc)
    x = cgsl.linalg_complex_cholesky_solve(LLc, b)
    print(cgsl.blas_zgemv(Aposc, x))
    x = cgsl.vector_complex(b)
    cgsl.linalg_complex_cholesky_svx(LL, x)
    print(cgsl.blas_zgemv(Aposc, x))

    # Tridiagonal Decomposition
    print()
    Apos = cgsl.blas_dgemm(A,A,TransB = cgsl.CblasTrans)
    Atrd, tau = cgsl.linalg_symmtd_decomp(Apos)
    Q, diag, subdiag = cgsl.linalg_symmtd_unpack(Atrd, tau)
    print(Q, diag, subdiag)
    def make_tridiag(diag, subdiag, complx = False):
        if complx:
            M = cgsl.matrix_complex(len(diag), len(diag))
        else:
            M = cgsl.matrix(len(diag), len(diag))
        M.set_zero()
        for i in range(len(diag)):
            M[i,i] = diag[i]
        for i in range(len(subdiag)):
            M[i+1,i] = subdiag[i]
            M[i,i+1] = subdiag[i]
        return M
    TD = make_tridiag(diag, subdiag)
    print(cgsl.blas_dgemm(Q, cgsl.blas_dgemm(TD, Q, TransB = cgsl.CblasTrans)))
    Apos = cgsl.blas_dgemm(A,A,TransB = cgsl.CblasTrans)
    print(Apos)
    diag, subdiag = cgsl.linalg_symmtd_unpack_T(Atrd)
    print(diag, subdiag)

    Atrd, tau = cgsl.linalg_hermtd_decomp(Apos)
    Q, diag, subdiag = cgsl.linalg_hermtd_unpack(Atrd, tau)
    print(diag, subdiag)
    TD = make_tridiag(diag, subdiag, complx = True)
    print(cgsl.blas_zgemm(Q, cgsl.blas_zgemm(TD, Q, TransB = cgsl.CblasTrans)))
    diag, subdiag = cgsl.linalg_hermtd_unpack_T(Atrd)
    print(diag, subdiag)

    # Hessenberg decomposition
    H, tau = cgsl.linalg_hessenberg_decomp(A)
    print(H, tau)
    U = cgsl.linalg_hessenberg_unpack(H, tau)
    V = cgsl.matrix([[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1],[0,0,0,0]])
    V = cgsl.linalg_hessenberg_unpack_accum(H, tau, V)
    cgsl.linalg_hessenberg_set_zero(H)
    print(cgsl.blas_dgemm(cgsl.blas_dgemm(U, H), U, TransB = cgsl.CblasTrans))
    print(U, V)
    A2 = cgsl.blas_dgemm(A,A,TransB = cgsl.CblasTrans)
    H, R, U2, V2 = cgsl.linalg_hesstri_decomp(A, A2)
    A2 = cgsl.blas_dgemm(A,A,TransB = cgsl.CblasTrans)
    #print A, A2
    print(cgsl.blas_dgemm(cgsl.blas_dgemm(U2, H), V2, TransB = cgsl.CblasTrans))
    print(cgsl.blas_dgemm(cgsl.blas_dgemm(U2, R), V2, TransB = cgsl.CblasTrans))

    # Bidiagonalization
    BB, tau_U, tau_V = cgsl.linalg_bidiag_decomp(B)
    #print BB, tau_U, tau_V
    U, V, diag, superdiag = cgsl.linalg_bidiag_unpack(BB, tau_U, tau_V)
    print(U,V,diag, superdiag)
    def make_bidiag(N, diag, superdiag):
        M = cgsl.matrix(N,N)
        M.set_zero()
        for i in range(N):
            M[i,i] = diag[i]
        for i in range(N-1):
            M[i,i+1] = superdiag[i]
        return M
    BD = make_bidiag(len(B[0]), diag, superdiag)
    print(B)
    print(cgsl.blas_dgemm(cgsl.blas_dgemm(U, BD), V, TransB = cgsl.CblasTrans))

    diag, superdiag = cgsl.linalg_bidiag_unpack_B(BB)
    U, V = cgsl.linalg_bidiag_unpack2(BB, tau_U, tau_V)
    print(U, V)
    print(diag, superdiag)

    # Householder Transformations
    tau, v = cgsl.linalg_householder_transform(b)
    I = cgsl.matrix(len(v), len(v))
    I.set_identity()
    print(cgsl.linalg_householder_hm(tau, v, cgsl.matrix(I)))
    print(cgsl.linalg_householder_mh(tau, v, cgsl.matrix(I)))
    print(cgsl.linalg_householder_hv(tau, v, b)) # should zero all but the first elements of b
    print(cgsl.linalg_householder_hv(tau, v, [1,0,0,0])) # should be identical to the first column of mh and hm

    tau, v = cgsl.linalg_complex_householder_transform(b)
    print(cgsl.linalg_complex_householder_hm(tau, v, I))
    print(cgsl.linalg_complex_householder_mh(tau, v, I))
    print(cgsl.linalg_complex_householder_hv(tau, v, b)) # should zero all but the first elements of b
    print(cgsl.linalg_complex_householder_hv(tau, v, [1,0,0,0])) # should be identical to the first column of mh and hm

    x = cgsl.linalg_HH_solve(A, b)
    print(cgsl.blas_dgemv(A, x))
    x = cgsl.vector(b)
    cgsl.linalg_HH_svx(A, x)
    print(cgsl.blas_dgemv(A, x))

    # Tridiagonal Systems
    print()
    def make_tridiag_nonsym(diag, e, f):
        M = cgsl.matrix(len(diag), len(diag))
        M.set_zero()
        for i in range(len(diag)):
            M[i,i] = diag[i]
        for i in range(len(e)):
            M[i+1,i] = f[i]
            M[i,i+1] = e[i]
        return M
    diag = [1,2,3,4,5]
    e = [4,3,2,1]
    f = [1,1,1,1]
    TD = make_tridiag_nonsym(diag, e, f)
    print(TD)
    x = cgsl.linalg_solve_tridiag(diag, e, f, [1,2,3,4,5])
    print(cgsl.blas_dgemv(TD, x))
    TD[0,4] = 1
    TD[4,0] = -1
    x = cgsl.linalg_solve_cyc_tridiag(diag, e+[-1], f+[1], [1,2,3,4,5])
    print(cgsl.blas_dgemv(TD, x))
    try:
        cgsl.linalg_cholesky_decomp(TD)
    except:
        print("Matrix not positive definite")

    TD = make_tridiag(diag, e)
    x = cgsl.linalg_solve_symm_tridiag(diag, e, [1,2,3,4,5])
    print(cgsl.blas_dgemv(TD, x))
    TD[0,4] = -1
    TD[4,0] = -1
    x = cgsl.linalg_solve_symm_cyc_tridiag(diag, e+[-1], [1,2,3,4,5])
    print(cgsl.blas_dgemv(TD, x))

    # Balancing
    print()
    print(cgsl.matrix(A))
    A, D = cgsl.linalg_balance_matrix(A)
    print(A, D)
    
def test_eigen():
    print()
    def make_hilb(n):
        M = cgsl.matrix(n,n)
        for i in range(n):
            for j in range(n):
                M[i,j] = 1.0 / (i+j+1)
        return M
    A = make_hilb(4)
    print(A)
    eig = cgsl.eigen_symm(make_hilb(4))
    print(eig)
    eig, eigv = cgsl.eigen_symmv(make_hilb(4))
    print(eig)
    print(eigv)
    def test_eigenv(M, eig, eigv, B = None, beta = None):
        for i in range(4):
            print("eigenvector", i+1, "; eigvalue =", eig[i])
            eiv = eigv.column(i)
            if isinstance(eigv, cgsl.matrix):
                ee = cgsl.blas_dgemv(M, eiv)
                if beta is not None:
                    cgsl.blas_dscal(beta[i], ee)
                print(ee)
                cgsl.blas_dscal(eig[i], eiv)
                if B is not None:
                    eiv = cgsl.blas_dgemv(B, eiv)
            else:
                ee = cgsl.blas_zgemv(cgsl.matrix_complex(M), eiv)
                if beta is not None:
                    cgsl.blas_zscal(cgsl.gsl_complex(beta[i]), ee)
                print(ee)
                cgsl.blas_zscal(eig[i], eiv)
                if B is not None:
                    eiv = cgsl.blas_zgemv(cgsl.matrix_complex(B), eiv)
            print(eiv)
    cgsl.eigen_symmv_sort(eig, eigv, cgsl.GSL_EIGEN_SORT_ABS_ASC)
    test_eigenv(make_hilb(4), eig, eigv)

    print()
    eig = cgsl.eigen_herm(make_hilb(4))
    print(eig)
    eig, eigv = cgsl.eigen_hermv(make_hilb(4))
    cgsl.eigen_hermv_sort(eig, eigv, cgsl.GSL_EIGEN_SORT_ABS_ASC)
    print(eig)
    print(eigv)

    def make_Vandermonde(v):
        v = cgsl.vector(v)
        n = len(v)
        c = cgsl.vector(n)
        c.set_all(1.0)
        M = cgsl.matrix(n,n)
        for i in range(n):
            cgsl.blas_dcopy(c, M.column(n-1-i))
            c *= v
        return M
    VM = make_Vandermonde([-1,-2,3,4])
    print(VM)
    eig = cgsl.eigen_nonsymm(make_Vandermonde([-1,-2,3,4]))
    print(eig)
    eig = cgsl.eigen_nonsymm(make_Vandermonde([-1,-2,3,4]), balance=1)
    print(eig)
    eig = cgsl.eigen_nonsymm(VM, balance=1, compute_t=1)
    print(eig)
    print(VM)
    VM = make_Vandermonde([-1,-2,3,4])
    eig, Z = cgsl.eigen_nonsymm_Z(VM, compute_t=1)
    print(eig)
    #print cgsl.blas_dgemm(Z, Z, TransA = cgsl.CblasTrans)
    print(cgsl.blas_dgemm(Z, cgsl.blas_dgemm(VM, Z, TransB = cgsl.CblasTrans)))

    eig, eigv = cgsl.eigen_nonsymmv(make_Vandermonde([-1,-2,3,4]))
    print(eig)
    print(eigv)
    cgsl.eigen_nonsymmv_sort(eig, eigv, cgsl.GSL_EIGEN_SORT_ABS_ASC)
    test_eigenv(make_Vandermonde([-1,-2,3,4]), eig, eigv)

    VM = make_Vandermonde([-1,-2,3,4])
    eig, eigv, Z = cgsl.eigen_nonsymmv_Z(make_Vandermonde([-1,-2,3,4]))
    # this is more difficult due to balancing, need to figure out:
    #print cgsl.blas_dgemm(Z, cgsl.blas_dgemm(VM, Z, TransB = cgsl.CblasTrans))

    # Real generalized symmetric-definite
    print()
    eig = cgsl.eigen_gensymm(make_hilb(4), make_hilb(4))
    print(eig)
    eig, eigv = cgsl.eigen_gensymmv(make_hilb(4), make_hilb(4))
    print(eig)
    print(eigv)
    cgsl.eigen_gensymmv_sort(eig, eigv, cgsl.GSL_EIGEN_SORT_ABS_ASC)
    test_eigenv(make_hilb(4), eig, eigv, make_hilb(4))
    # Complex generalized hermitian-definite
    print()
    eig = cgsl.eigen_genherm(make_hilb(4), make_hilb(4))
    print(eig)
    eig, eigv = cgsl.eigen_genhermv(make_hilb(4), make_hilb(4))
    print(eig)
    print(eigv)
    cgsl.eigen_genhermv_sort(eig, eigv, cgsl.GSL_EIGEN_SORT_ABS_ASC)
    test_eigenv(make_hilb(4), eig, eigv, make_hilb(4))
    # Real generalized nonsymmetric
    print()
    eiga, eigb = cgsl.eigen_gen(make_hilb(4), make_Vandermonde([-1,-2,3,4]))
    print(eiga)
    print(eigb)
    eiga, eigb, eigv = cgsl.eigen_genv(make_hilb(4), make_Vandermonde([-1,-2,3,4]))
    print(eiga)
    print(eigb)
    print(eigv)
    cgsl.eigen_genv_sort(eiga, eigb, eigv, cgsl.GSL_EIGEN_SORT_ABS_ASC)
    test_eigenv(make_hilb(4), eiga, eigv, make_Vandermonde([-1,-2,3,4]), eigb)

    print()
    eiga, eigb, Q, Z = cgsl.eigen_gen_QZ(make_hilb(4), make_Vandermonde([-1,-2,3,4]))
    print(eiga)
    print(eigb)
    eiga, eigb, eigv, Q, Z = cgsl.eigen_genv_QZ(make_hilb(4), make_Vandermonde([-1,-2,3,4]))
    print(eiga)
    print(eigb)
    print(eigv)

def test_permutation():
    p = cgsl.permutation(5)
    print(len(p), p[2])
    p2 = p.copy()
    del p
    print(len(p2), p2[2])
    print(len(p2), p2[2], p2[3])
    p2.swap(2,3)
    print(len(p2), p2[2], p2[3])
    print(p2)
    p2.init()
    print(p2)
    for x in p2:
        print(x)
    print(p2.as_list())
    print(p2.valid())
    p2.reverse()
    print(p2)
    pi = p2.inverse()
    print(pi)

    print(p2.prev())
    print(p2)
    print(next(p2))
    print(p2)

    p3 = cgsl.permutation(3)
    for ip in p3.iterperm():
        print(ip)
    
def test_combination():
    for i in range(5):
        c = cgsl.combination(4, i)
        print(c)
        while next(c):
            print(c)
    c = cgsl.combination(4, 2)
    print(c.valid())
    c.init_last()
    print(c)
    c.init_first()
    print(c)
    next(c)
    c.prev()
    print(c)
    next(c)
    next(c)
    for c2 in c.itercomb():
        print(c2)

def test_integration():
    def f(x, params):
        alpha = params[0]
        f = log(alpha*x) / sqrt(x)
        return f
    F  = cgsl.gsl_function(f, [0.5])
    F1 = cgsl.gsl_function(exp)
    print(F(2))
    print(cgsl.integration_qng(F1, 0, 1, 1e-1, 1e-1))
    try:
        print(cgsl.integration_qng(F, 0, 1, 0, 1e-7))
    except cgsl.GSL_Error as ge:
        print("Caught ctypesGsl exception:", str(ge))
        print("function return value:", ge.result)

    w = cgsl.integration_workspace(5000)
    print(w.size)

    print(cgsl.integration_qag(F1, 0, 1, 1e-1, 1e-1, w))
    print(cgsl.integration_qag(F, 0, 1, 0, 1e-7, w))

    # automatically allocate workspace
    print(cgsl.integration_qag(F1, 0, 1, 1e-1, 1e-1))
    print(cgsl.integration_qag(F, 0, 1, 0, 1e-7))

    print(cgsl.integration_qags(F1, 0, 1, 1e-1, 1e-1, w))
    print(cgsl.integration_qags(F, 0, 1, 0, 1e-7, w))

    print(cgsl.integration_qagp(F1, [0, 1], 1e-1, 1e-1, w))
    print(cgsl.integration_qagp(F, [0, 1], 0, 1e-7, w))

    # infinite intervals
    def f3(x):
        f = 1.0 / (1.0 * sqrt(2*pi)) * exp(-(x - 0)**2/(2.0*1.0**2))
        return f
    F3  = cgsl.gsl_function(f3)
    print(cgsl.integration_qagi(F3, 1e-10, 0, w))
    print(cgsl.integration_qagiu(F3, 0, 1e-10, 0, w))
    print(cgsl.integration_qagil(F3, 0, 1e-10, 0, w))

    # weighted integration
    print(cgsl.integration_qawc(F1, 0, 1, 0.5, 1e-1, 1e-1, w))

    qawst = cgsl.integration_qaws_table(0, 0, 0, 0)
    print(cgsl.integration_qaws(F1, 0, 1, 1e-1, 1e-1, qawst, w))
    print(cgsl.integration_qaws(F1, 0, 1, 1e-1, 1e-1))
    print(cgsl.integration_qaws(F1, 0, 1, 1e-1, 1e-1, alpha = 2, mu = 1))

    # oscillatory functions
    def f4(x):
        f = exp(x) * sin(2*pi*x)
        return f
    F4  = cgsl.gsl_function(f4)
    print(F4(0))

    # standard method
    print(cgsl.integration_qag(F4, 0, 1, 1e-10, 1e-1, w))

    # qawo method
    qawot = cgsl.integration_qawo_table(2*pi, 1, cgsl.GSL_INTEG_SINE, n = 5)
    print(cgsl.integration_qawo(F1, 0, 1e-10, 1e-1, qawot))
    print(cgsl.integration_qawo(F1, 0, 1e-10, 1e-1,
                                omega = 2*pi, is_sine = cgsl.GSL_INTEG_SINE,
                                L = 1, n = 10))
    # Fourier integrals

    # standard method
    def f5(x):
        f = 1.0 / (1.0 * sqrt(2*pi)) * exp(-(x - 0)**2/(2.0*1.0**2)) * cos(2*pi*x)
        return f
    F5  = cgsl.gsl_function(f5)
    print(cgsl.integration_qagiu(F5, 0, 1e-10, 0, w))
    #qawf method
    qawot2 = cgsl.integration_qawo_table(2*pi, 1, cgsl.GSL_INTEG_COSINE, n = 10)
    print(cgsl.integration_qawf(F3, 0, 1e-10, qawot2))
    print(cgsl.integration_qawf(F3, 0, 1e-10))


def test_monte():
    def f(x, params):
        #print "in f"
        #print x, params, x[0]
        return 1
    mf = cgsl.gsl_monte_function(f, 1, "abc")
    print(mf([0.5]))
    print(cgsl.monte_plain_integrate(mf, [0], [1], 100))

    def g(k):
        A = 1.0 / (pi * pi * pi);
        return A / (1.0 - cos(k[0]) * cos(k[1]) * cos(k[2]))
    mg = cgsl.gsl_monte_function(g, 3)
    exact = 1.3932039296856768591842462603255
    def show_result(res):
        print(res[0], exact, abs(res[0]-exact), res[1])
    calls = 10000
    print("exact =", exact)
    show_result(cgsl.monte_plain_integrate(mg, [0]*3, [pi]*3, calls))
    #
    show_result(cgsl.monte_miser_integrate(mg, [0]*3, [pi]*3, calls))
    ms = cgsl.monte_miser_state(3, dither=0.1)
    show_result(cgsl.monte_miser_integrate(mg, [0]*3, [pi]*3, calls, state=ms))
    show_result(cgsl.monte_miser_integrate(mg, [0]*3, [pi]*3, calls, dither=0.1))
    #
    show_result(cgsl.monte_vegas_integrate(mg, [0]*3, [pi]*3, calls))
    

def test_gsl_odeiv():
    def func(t, y, f, params):
        mu = params[0]
        f[0] = y[1]
        f[1] = -y[0] - mu * y[1] * (y[0]*y[0] - 1)
        return cgsl.GSL_SUCCESS
     
    def jac(t, y, dfdy, dfdt, params):
        mu = params[0]
        dfdy[0] = 0
        dfdy[1] = 1
        dfdy[2] = -2.0*mu*y[0]*y[1] - 1.0
        dfdy[3] = -mu*(y[0]*y[0] - 1.0)
        dfdt[0] = 0.0
        dfdt[1] = 0.0
        return cgsl.GSL_SUCCESS

     
    T = cgsl.odeiv_step_rk8pd
    #T = cgsl.odeiv_step_rk4
    #T = cgsl.odeiv_step_bsimp
     
    mu = 10
    sys = cgsl.odeiv_system(func, None, 2, T, params = [mu])
    #sys = cgsl.odeiv_system(func, jac, 2, T, params = [mu])

    print(sys.fn_eval(0, [1,0])[:])
     
    t = 0.0
    t1 = 100.0
    eps_abs = 1e-6
    h = 0.01
    y = [1.0, 0.0]
    nsteps = 100

    # simple stepping
    resx = []
    sys.init(t, y)
    print(sys)
    resx.append(sys.get_y()[0])
    for i in range(nsteps):
        sys.step(h)
        print(sys)
        resx.append(sys.get_y()[0])

    # evolve
    resx2 = []
    sys.init(t, y)
    print(sys)
    resx2.append(sys.y[0])
    for i in range(nsteps):
        sys.evolve(sys.t + h)
        print(sys)
        resx2.append(sys.y[0])

    #from pylab import plot, ylim, show
    #plot(resx, 'r')
    #plot(resx2)
    #ylim(-2.5,2.5)
    #show()


def test_chebyshev():
    def f(x):
        if x < 0.5:
            return 0.25
        else:
            return 0.75
    F = cgsl.gsl_function(f)

    n = 10
    
    cs = cgsl.cheb_series(40)
    cs.init(F, 0.0, 1.0)

    deri = cs.deriv()
    intg = cs.integ()
    
    for i in range(n):
        x = i / float(n)
        r10   = cs.eval_n(10, x)
        r10_err = cs.eval_n_err(10, x)
        r40   = cs(x)
        r40_err = cs.eval_err(x)
        print("%g %g %g %g %g+/-%g %g+/-%g" % (x, cgsl.GSL_FN_EVAL(F, x), r10, r40,
                                                  r40_err[0], r40_err[1], r10_err[0], r10_err[1]), end=' ')
    xs = []
    es = []
    as_ = []
    ds = []
    ii = []
    for i in range(1000):
        x = i / float(1000)
        xs.append(x)
        es.append(F(x))
        as_.append(cs(x))
        ds.append(deri(x))
        ii.append(intg(x))
    #from pylab import plot, show, ylim
    #plot(xs, es)
    #plot(xs, as_)
    #plot(xs, ds)
    #plot(xs, ii)
    #ylim(-3,3)
    #show()


def test_roots():
    class quadratic_params:
        def __init__(self, a, b, c):
            self.a = a
            self.b = b
            self.c = c

    def quadratic(x, params):
        a = params.a
        b = params.b
        c = params.c
        return (a * x + b) * x + c

    def quadratic_deriv(x, params):
        a = params.a
        b = params.b
        c = params.c
        return 2.0 * a * x + b
     
    def quadratic_fdf(x, params):
        a = params.a
        b = params.b
        c = params.c
     
        y = (a * x + b) * x + c
        dy = 2.0 * a * x + b
        return y, dy

    p = quadratic_params(1.0, 0.0, -5.0)
    F = cgsl.gsl_function(quadratic, p)
    print(F(0))

    ### bracketing based
    
    #T = cgsl.root_fsolver_bisection
    #T = cgsl.root_fsolver_falsepos
    T = cgsl.root_fsolver_brent
    s = cgsl.root_fsolver(T, F)
    s.init(0, 5)

    expected = sqrt(5.0)

    print("iter 0:", s.root(), s.bracket(), s.root() - expected)
    for it in range(10):
        s.iterate()
        if s.test_interval(0, 0.001):
            print("Converged!!!")
            print("iter %d:" % (it+1), s.root(), s.bracket(), s.root() - expected)
            break
        print("iter %d:" % (it+1), s.root(), s.bracket(), s.root() - expected)

    FDF  = cgsl.gsl_function_fdf(quadratic, quadratic_deriv, quadratic_fdf, p)
    FDF2 = cgsl.gsl_function_fdf(quadratic, quadratic_deriv, None, p)
    print(FDF(0), FDF2(0))

    ### derivative based
    
    #T = cgsl.root_fdfsolver_newton
    #T = cgsl.root_fdfsolver_secant
    T = cgsl.root_fdfsolver_steffenson
    s = cgsl.root_fdfsolver(T, FDF)
    #s = cgsl.root_fdfsolver(T, FDF2)
    s.init(5)

    print("iter 0:", s.root(), s.last_step_width(), s.root() - expected)
    for it in range(10):
        s.iterate()
        if s.test_delta(0, 0.001):
            print("Converged!!!")
            print("iter %d:" % (it+1), s.root(), s.last_step_width(), s.root() - expected)
            break
        print("iter %d:" % (it+1), s.root(), s.last_step_width(), s.root() - expected)

def test_min():
    def fn1(x):
        return cos(x) + 1.0

    F = cgsl.gsl_function(fn1)
    print(F(0))
    
    expected = pi

    #T = cgsl.min_fminimizer_goldensection
    T = cgsl.min_fminimizer_brent
    s = cgsl.min_fminimizer(T, F)
    s.init(2.0, 0.0, 6.0)

    print("iter 0:", s.bracket(), s.x_minimum(), s.x_minimum() - expected, s.upper() - s.lower())
    for it in range(100):
        s.iterate()
        if s.test_interval(0, 0.001):
            print("Converged!!!")
            print("iter %d:" % (it+1), s.bracket(), s.x_minimum(), s.x_minimum() - expected, s.upper() - s.lower())
            break
        print("iter %d:" % (it+1), s.bracket(), s.x_minimum(), s.x_minimum() - expected, s.upper() - s.lower())

def test_multiroots():
    def print_state(iter, s):
        x = s.root()
        f = s.f()
        print("iter = %3u x = % .3f % .3f f(x) = % .3e % .3e" % (iter, x[0], x[1], f[0], f[1]))

    class rparams:
        def __init__(self, a, b):
            self.a = a
            self.b = b

    def rosenbrock_f(x, params, f):
        a = params.a
        b = params.b
        x0 = x[0]
        x1 = x[1]
        y0 = a * (1 - x0)
        y1 = b * (x1 - x0 * x0)
        f[0] = y0
        f[1] = y1
        return cgsl.GSL_SUCCESS

    def rosenbrock_df(x, params, J):
        a = params.a
        b = params.b
        x0 = x[0]
        df00 = -a
        df01 = 0
        df10 = -2 * b  * x0
        df11 = b
        J[0, 0] = df00
        J[0, 1] = df01
        J[1, 0] = df10
        J[1, 1] = df11
        return cgsl.GSL_SUCCESS

    p = rparams(1, 10)
    f = cgsl.vector(2)
    x = cgsl.vector([0, 0])
    rosenbrock_f(x, p, f)
    print(f)

    F = cgsl.gsl_multiroot_function(rosenbrock_f, 2, p)
    x[0] = 1
    print(F(x))

    x_init = [-10.0, -5.0]
    x = cgsl.vector(x_init)

    T = cgsl.multiroot_fsolver_hybrids
    s = cgsl.multiroot_fsolver(T, F)
    it = 0
    s.init(x)

    print_state(it, s)

    while True:
        it += 1
        s.iterate()
        print_state(it, s)
        status = s.test_delta(1e-7, 0)
        #status = s.test_residual(1e-7)
        if it >= 1000 or status:
            break
    print("success")

    FDF = cgsl.gsl_multiroot_function_fdf(rosenbrock_f, rosenbrock_df, None, 2, p)
    x[0] = 0
    x[1] = 0
    print(FDF.eval_f(x))
    print(FDF.eval_df(x))
    fv, dfv = FDF(x)
    print(fv)
    print(dfv)

    x = cgsl.vector(x_init)

    T = cgsl.multiroot_fdfsolver_gnewton
    s = cgsl.multiroot_fdfsolver(T, FDF)
    it = 0
    s.init(x)

    print_state(it, s)

    while True:
        it += 1
        s.iterate()
        print_state(it, s)
        status = s.test_delta(1e-7, 0)
        #status = s.test_residual(1e-7)
        if it >= 1000 or status:
            break
    print("success")

def test_multimin():
    def my_f(v, params):
        dp = params
        x, y = v[0], v[1]
        return 10.0 * (x - dp[0]) * (x - dp[0]) + \
               20.0 * (y - dp[1]) * (y - dp[1]) + 30.0
    def my_df(v, params, df):
        dp = params
        x, y = v[0], v[1]
        df[0] = 20.0 * (x - dp[0])
        df[1] = 40.0 * (y - dp[1])

    p = [1, 2]
    F = cgsl.gsl_multimin_function(my_f, 2, p)
    print(F(cgsl.vector([2, 2])))
    FDF = cgsl.gsl_multimin_function_fdf(my_f, my_df, None, 2, p)
    print("F =", FDF.eval_f(cgsl.vector([2, 2])))
    print("dF =", FDF.eval_df(cgsl.vector([2, 2])))
    fdf = FDF(cgsl.vector([2, 2]))
    print("FdF =", fdf[0], fdf[1])

    # Starting point, x = (5,7)
    x = cgsl.vector([5, 7])
     
    T = cgsl.multimin_fdfminimizer_conjugate_fr
    T = cgsl.multimin_fdfminimizer_conjugate_pr
    T = cgsl.multimin_fdfminimizer_vector_bfgs
    #T = cgsl.multimin_fdfminimizer_vector_bfgs2
    #T = cgsl.multimin_fdfminimizer_steepest_descent

    s = cgsl.multimin_fdfminimizer(T, FDF)
    s.init(x, 0.01, 1e-4)
    it = 0
    while True:
        it += 1
        s.iterate()
        status = s.test_gradient(1e-3)
        if status:
            print("Minimum found at:")
        xx = s.x()
        print("%5d %.5f %.5f %10.5f" % (it, xx[0], xx[1], s.minimum()))
        if status or it >= 1000:
            break


    print()
    print()
    T = cgsl.multimin_fminimizer_nmsimplex

    s = cgsl.multimin_fminimizer(T, F)
    s.init(x, cgsl.vector([1.0] * F.n))
    it = 0
    while True:
        it += 1
        s.iterate()
        status = s.test_size(1e-2)
        if status:
            print("Minimum found at:")
        xx = s.x()
        print("%5d %.5f %.5f %10.5f, size=%.3f" % (it, xx[0], xx[1], s.minimum(), s.size()))
        if status or it >= 1000:
            break

def test_rng():
    T = cgsl.rng_ranlxd1
    rng = cgsl.rng(T)
    print(rng.get(), rng.get(), rng.get())
    print(rng(), rng(), rng())
    print(rng.uniform_pos(), rng.uniform_pos(), rng.uniform_pos())
    print(rng.uniform_int(5), rng.uniform_int(5), rng.uniform_int(5), rng.uniform_int(5))
    rng.set(20)
    print(rng.uniform_int(5), rng.uniform_int(5), rng.uniform_int(5), rng.uniform_int(5))
    print(rng.name, type(rng.name))
    print(rng.min, rng.max)

    cgsl.rng_env_setup()

    print("available generators:", ", ".join([T.name for T in cgsl.rng_types]))
    default_rng = cgsl.rng()
    print("default rng:", default_rng.name)

    rng2 = rng.clone()
    print(rng(), rng())
    print(rng2(), rng2())

def test_qrng():
    T = cgsl.qrng_sobol
    qrng = cgsl.qrng(T, 2)
    print(qrng.get(), qrng.get(), qrng.get())
    print(qrng(), qrng(), qrng())
    qrng.init()
    print(qrng.get(), qrng.get(), qrng.get())
    print(qrng(), qrng(), qrng())
    print(qrng.name, type(qrng.name))

    qrng2 = qrng.clone()
    print(qrng(), qrng())
    print(qrng2(), qrng2())

    #qrng = cgsl.qrng(cgsl.qrng_sobol, 12)
    #qrng3 = cgsl.qrng(cgsl.qrng_niederreiter_2, 12)
    #X  = zip(*[qrng()[3:5]  for i in xrange(1000)])
    #X2 = zip(*[qrng3()[3:5] for i in xrange(1000)])
    #from pylab import plot, show
    #plot(X[0], X[1], "1")
    #plot(X2[0], X2[1], "xr")
    #show()

def test_randist():
    rng = cgsl.rng()
    rng.set(0)
    print(cgsl.ran_ugaussian(rng))
    rng.set(0)
    print(cgsl.ran_gaussian(rng, 1))
    print(cgsl.cdf_gaussian_P(0, 1))
    print(cgsl.cdf_gaussian_Pinv(0.5, 1))
    rng.set(0)
    print(cgsl.ran_gaussian_ziggurat(rng, 1))
    rng.set(0)
    print(cgsl.ran_gaussian_tail(rng, 10, 1))
    print(cgsl.ran_gaussian_tail_pdf(11, 10, 1))
    rng.set(0)
    print(cgsl.ran_ugaussian_tail(rng, 10))
    print(cgsl.ran_ugaussian_tail_pdf(11, 10))

    rng.set(0)
    print(cgsl.ran_bivariate_gaussian(rng, 1, 1, 1))
    print(cgsl.ran_bivariate_gaussian(rng, 1, 1, -0.999))
    print(cgsl.ran_bivariate_gaussian(rng, 1, 1, -0.999))
    print(cgsl.ran_bivariate_gaussian(rng, 1, 1, -0.999))
    print(cgsl.ran_bivariate_gaussian(rng, 1, 1, -0.999))

    # mean of Cauchy sample
    for n in [100, 1000, 5000, 10000, 20000]:#, 30000, 50000, 100000]:
        X = [cgsl.ran_cauchy(rng, 1) for i in range(n)]
        mean = sum(X) / n
        X.sort()
        median = X[len(X)//2]
        print(mean,"(",median,")", end=' ')
    print()

    rng.set(0)
    print(cgsl.ran_levy_skew(rng, 1.5, 1.5, 1.5))

    rng.set(0)
    for i in range(10):
        print(cgsl.ran_poisson(rng, 5), end=' ')
    print()
    print(cgsl.ran_poisson_pdf(0, 5))
    print(cgsl.cdf_poisson_P(0, 5))
    print(cgsl.cdf_poisson_Q(0, 5)) 
    print(cgsl.cdf_poisson_P(5, 5))
    print(cgsl.cdf_poisson_Q(5, 5))
    rng.set(0)
    for i in range(10):
        print(cgsl.ran_bernoulli(rng, 0.5), end=' ')
    print()
    rng.set(0)
    for i in range(10):
        print(cgsl.ran_binomial(rng, 0.5, 10), end=' ')
    print()
    print(cgsl.ran_binomial_pdf(3, 0.5, 10))
    print(cgsl.cdf_binomial_P(3, 0.5, 10))
    print(cgsl.cdf_binomial_P(3, 0.5, 100))
    rng.set(0)
    for i in range(10):
        print(cgsl.ran_negative_binomial(rng, 0.5, 10), end=' ')
    print()
    rng.set(0)
    for i in range(10):
        print(cgsl.ran_pascal(rng, 0.5, 10), end=' ')
    print()
    rng.set(0)
    for i in range(10):
        print(cgsl.ran_hypergeometric(rng, 2, 8, 5), end=' ')
    print()

    rng.set(0)
    print(sum([x*x for x in cgsl.ran_dir_2d(rng)]))
    for i in range(10):
        print(cgsl.ran_dir_2d(rng), end=' ')
    print()
    rng.set(0)
    print(sum([x*x for x in cgsl.ran_dir_2d_trig_method(rng)]))
    rng.set(0)
    print(sum([x*x for x in cgsl.ran_dir_3d(rng)]))
    rng.set(0)
    print(sum([x*x for x in cgsl.ran_dir_nd(rng, 10)]))
    print(sum([x*x for x in cgsl.ran_dir_nd(rng, 2)]))
    print(sum([x*x for x in cgsl.ran_dir_nd(rng, 1000)]))
    for i in range(10):
        print(cgsl.ran_dir_nd(rng, 1), end=' ')
    print()

    rng.set(0)
    print(cgsl.ran_dirichlet(rng, [1,1,1]))
    print(cgsl.ran_dirichlet_pdf([1,1,1], [0.5, 0.5, 0.5]))
    print(exp(cgsl.ran_dirichlet_lnpdf([1,1,1], [0.5, 0.5, 0.5])))
    rng.set(0)
    print(cgsl.ran_multinomial(rng, 10, [0.2,0.4,0.4]))
    print(cgsl.ran_multinomial(rng, 10, [0.2,0.4,0.4]))
    print(cgsl.ran_multinomial(rng, 10, [0.2,0.4,0.4]))
    print(cgsl.ran_multinomial(rng, 10, [0.2,0.4,0.4]))
    print(cgsl.ran_multinomial_pdf([0.2,0.4,0.4], [4,2,4]))
    print(exp(cgsl.ran_multinomial_lnpdf([0.2,0.4,0.4], [4,2,4])))


    dd = cgsl.ran_discrete([1,1,1]) # does not work...
    rng.set(0)
    for i in range(10):
        print(dd(rng), end=' ')
    print()
    print(dd.pdf(), dd.pdf(1))

    ddb = cgsl.ran_discrete([cgsl.ran_binomial_pdf(i, 0.5, 1000) for i in range(1000)])
    rng.set(0)
    for i in range(10):
        print(ddb(rng), end=' ')
    print()

    rng.set(0)
    print(cgsl.ran_shuffle(rng, [1,2,3,4,5]))
    print(cgsl.ran_shuffle(rng, "abcd"))
    print(cgsl.ran_choose(rng, 8, range(10)))
    print(cgsl.ran_sample(rng, 8, range(10)))
    print(cgsl.ran_sample(rng, 5, range(1)))


if __name__ == '__main__':
    test_gsl_basic()
    test_gsl_complex()
    test_poly()
    test_sf()
    test_vector()
    test_matrix()
    test_blas()
    test_linalg()
    test_eigen()
    test_permutation()
    test_combination()
    test_integration()
    test_monte()
    test_gsl_odeiv()
    test_chebyshev()
    test_roots()
    test_min()
    test_multiroots()
    test_multimin()
    test_rng()
    test_qrng()
    #test_randist()

