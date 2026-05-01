

#include "pxs_gausq_3.h"

#define C0(a, b, c, d, e, f) C0i(cc0, a, b, c, d, e, f)
#define C1(a, b, c, d, e, f) C0i(cc1, a, b, c, d, e, f)
#define C2(a, b, c, d, e, f) C0i(cc2, a, b, c, d, e, f)
#define C00(a, b, c, d, e, f) C0i(cc00, a, b, c, d, e, f)
#define C11(a, b, c, d, e, f) C0i(cc11, a, b, c, d, e, f)
#define C12(a, b, c, d, e, f) C0i(cc12, a, b, c, d, e, f)
#define C22(a, b, c, d, e, f) C0i(cc22, a, b, c, d, e, f)

#define Power std::pow
#define pow2(x) x *x
//#define Conjugate conj

ComplexType ME_us_qqg_qgg(POLE pIEPS, bool sc, bool uc, bool axial, double Q2,
                          double P1K1, Parameters *params) {
  BOX_KINEMATIC;
  BOX_INDEX;
  BOX_BASE;
  int q_I = q;

  // Tensor<ComplexType, 2> Lp_IJk = cc_chiral(params);

  ComplexType L = (params->CHSQq[ch][sq][q].L);
  ComplexType R = (params->CHSQq[ch][sq][q].R);
  ComplexType Lp = conj(params->CHSQq[ch][sq][q].R);
  ComplexType Rp = conj(params->CHSQq[ch][sq][q].L);

  double SS = sc, UU = uc, AXG = axial;
  ComplexType ret = 0;
  // auto ret =

  _EPS0(
      ret,
      (Power(gs, 4) * Nc * (-1 + Power(Nc, 2)) * (Lp * R + L * Rp) *
       Power(TR, 2) *
       (-(s *
          (4 * MUs * SS * (MXs - t) + 2 * (-3 + AXG) * Power(MXs, 2) * UU +
           (MUs + MXs - s - t) *
               (4 * SS * t + (-1 + AXG) * s * UU -
                2 * (MUs + MXs - s - AXG * (MUs + MXs - s - t) + t) * UU) +
           MXs * (-4 * SS * (MUs + MXs - s - t) +
                  (5 * s - AXG * s + 8 * (MUs + MXs - s - t) -
                   4 * AXG * (MUs + MXs - s - t) + 4 * t) *
                      UU)) *
          C0(0, 0, s, 0, 0, 0)) -
        s *
            (2 * MUs * MXs * SS - 2 * AXG * MUs * MXs * SS -
             2 * Power(MXs, 2) * SS - 2 * MUs * s * SS +
             2 * AXG * MUs * s * SS + 2 * AXG * MXs * s * SS +
             2 * Power(s, 2) * SS - 2 * AXG * Power(s, 2) * SS -
             2 * MUs * SS * t + 2 * AXG * MUs * SS * t + 2 * MXs * SS * t +
             2 * AXG * MXs * SS * t + 2 * s * SS * t - 4 * AXG * s * SS * t -
             2 * AXG * SS * Power(t, 2) - 2 * Power(MUs, 2) * UU +
             2 * AXG * Power(MUs, 2) * UU + 2 * AXG * MUs * MXs * UU +
             5 * MUs * s * UU - 5 * AXG * MUs * s * UU + 2 * MXs * s * UU -
             2 * AXG * MXs * s * UU - 3 * Power(s, 2) * UU +
             3 * AXG * Power(s, 2) * UU + 4 * MUs * t * UU -
             6 * AXG * MUs * t * UU - 2 * AXG * MXs * t * UU - 5 * s * t * UU +
             7 * AXG * s * t * UU - 2 * Power(t, 2) * UU +
             4 * AXG * Power(t, 2) * UU) *
            C1(0, s, 0, 0, 0, 0) +
        2. * (2. *
                  (2 * MUs * SS * (MXs - t) +
                   2 * (-2 + AXG) * Power(MXs, 2) * UU +
                   (MUs + MXs - s - t) *
                       (2 * SS * t + (-1 + AXG) * s * UU -
                        2 * (MUs + MXs - s - AXG * (MUs + MXs - s - t)) * UU) +
                   MXs * (-2 * SS * (MUs + MXs - s - t) +
                          (3 * s - AXG * s + 6 * (MUs + MXs - s - t) -
                           4 * AXG * (MUs + MXs - s - t) + 2 * t) *
                              UU)) *
                  C00(0, s, 0, 0, 0, 0) +
              (-1 + AXG) * s * (-MUs + s + t) *
                  (2 *
                       (MUs * SS - SS * (MUs + MXs - s - t) +
                        (MXs - s - t) * UU) *
                       C11(0, s, 0, 0, 0, 0) +
                   (-2 * MXs + s + 2 * (MUs + MXs - s - t)) * UU *
                       C12(0, s, 0, 0, 0, 0))))) /
          (768. * Power(Pi, 2) * s * (-MXs + s + t)));
  _EPS1(
      ret,
      (Power(gs, 4) * Nc * (-1 + Power(Nc, 2)) * (Lp * R + L * Rp) *
       Power(TR, 2) *
       (-(s *
          (2 * (MUs - s - t) *
               (-(MXs * SS) + s * SS + SS * t + MXs * UU - s * UU - t * UU) -
           2 * AXG * (-MUs + s + t) *
               (MXs * SS - s * SS - SS * t - MXs * UU + s * UU + t * UU)) *
          C1(0, s, 0, 0, 0, 0)) -
        2. * (2. *
                  (2 * MUs * SS * (MXs - t) +
                   2 * (-2 + AXG) * Power(MXs, 2) * UU +
                   (MUs + MXs - s - t) *
                       (2 * SS * t + (-1 + AXG) * s * UU -
                        2 * (MUs + MXs - s - AXG * (MUs + MXs - s - t)) * UU) +
                   MXs * (-2 * SS * (MUs + MXs - s - t) +
                          (3 * s - AXG * s + 6 * (MUs + MXs - s - t) -
                           4 * AXG * (MUs + MXs - s - t) + 2 * t) *
                              UU)) *
                  C00(0, s, 0, 0, 0, 0) +
              (-1 + AXG) * s * (-MUs + s + t) *
                  (2 *
                       (MUs * SS - SS * (MUs + MXs - s - t) +
                        (MXs - s - t) * UU) *
                       C11(0, s, 0, 0, 0, 0) +
                   (-2 * MXs + s + 2 * (MUs + MXs - s - t)) * UU *
                       C12(0, s, 0, 0, 0, 0))))) /
          (768. * Power(Pi, 2) * s * (-MXs + s + t)));
  return ret.real();
}

ComplexType ME_us_qqg_qqg(POLE pIEPS, bool sc, bool uc, bool axial, double Q2,
                          double P1K1, Parameters *params) {
  BOX_KINEMATIC;
  BOX_INDEX;
  BOX_BASE;
  int q_I = q;

  // Tensor<ComplexType, 2> Lp_IJk = cc_chiral(params);

  ComplexType L = (params->CHSQq[ch][sq][q].L);
  ComplexType R = (params->CHSQq[ch][sq][q].R);
  ComplexType Lp = conj(params->CHSQq[ch][sq][q].R);
  ComplexType Rp = conj(params->CHSQq[ch][sq][q].L);

  double SS = sc, UU = uc, AXG = axial;
  ComplexType ret = 0;
  // auto ret =
  _EPS0(
      ret,
      (Power(gs, 4) * (-1 + Power(Nc, 2)) * (Lp * R + L * Rp) * Power(TR, 2) *
       (s *
            (-4 * MUs * SS * (-MUs + AXG * MUs + s - AXG * s + t - AXG * t) -
             (MUs + MXs - s - t) * (-4 * (-1 + AXG) * SS * (MUs + MXs - s - t) -
                                    2 * (-1 + AXG) * s * UU +
                                    4 * (-1 + AXG) * (MUs + MXs - s - t) * UU -
                                    4 * (-1 + AXG) * t * UU) -
             MXs * (4 * (-1 + AXG) * SS * (MUs + MXs - s - t) +
                    (2 * (-1 + AXG) * s +
                     2 * (-2 * (-1 + AXG) * (MUs + MXs - s - t) +
                          2 * (-1 + AXG) * t)) *
                        UU)) *
            C1(0, s, 0, 0, 0, 0) +
        2. * (2. *
                  (2 * MUs * SS * (MXs - t) +
                   2 * (-2 + AXG) * Power(MXs, 2) * UU +
                   (MUs + MXs - s - t) *
                       (2 * SS * t + (-1 + AXG) * s * UU -
                        2 * (MUs + MXs - s - AXG * (MUs + MXs - s - t)) * UU) +
                   MXs * (-2 * SS * (MUs + MXs - s - t) +
                          (3 * s - AXG * s + 6 * (MUs + MXs - s - t) -
                           4 * AXG * (MUs + MXs - s - t) + 2 * t) *
                              UU)) *
                  C00(0, s, 0, 0, 0, 0) +
              (-1 + AXG) * s * (-MUs + s + t) *
                  (2 *
                       (MUs * SS - SS * (MUs + MXs - s - t) +
                        (MXs - s - t) * UU) *
                       C11(0, s, 0, 0, 0, 0) +
                   (-2 * MXs + s + 2 * (MUs + MXs - s - t)) * UU *
                       C12(0, s, 0, 0, 0, 0))))) /
          (768. * Nc * Power(Pi, 2) * s * (-MXs + s + t)));
  _EPS1(
      ret,
      (Power(gs, 4) * (-1 + Power(Nc, 2)) * (Lp * R + L * Rp) * Power(TR, 2) *
       (s *
            (4 * MUs * SS * (-MUs + AXG * MUs + MXs + s - AXG * s - AXG * t) -
             4 * Power(MXs, 2) * UU -
             (MUs + MXs - s - t) * (4 * (-1 + AXG) * SS * (MUs + MXs - s - t) -
                                    4 * SS * t + 2 * (-1 + AXG) * s * UU -
                                    4 * (-1 + AXG) * (MUs + MXs - s - t) * UU +
                                    4 * AXG * t * UU) -
             MXs * (-4 * (-2 + AXG) * SS * (MUs + MXs - s - t) +
                    (-2 * (1 + AXG) * s +
                     2 * (2 * (-2 + AXG) * (MUs + MXs - s - t) - 2 * AXG * t)) *
                        UU)) *
            C1(0, s, 0, 0, 0, 0) -
        2. * (2. *
                  (2 * MUs * SS * (MXs - t) +
                   2 * (-2 + AXG) * Power(MXs, 2) * UU +
                   (MUs + MXs - s - t) *
                       (2 * SS * t + (-1 + AXG) * s * UU -
                        2 * (MUs + MXs - s - AXG * (MUs + MXs - s - t)) * UU) +
                   MXs * (-2 * SS * (MUs + MXs - s - t) +
                          (3 * s - AXG * s + 6 * (MUs + MXs - s - t) -
                           4 * AXG * (MUs + MXs - s - t) + 2 * t) *
                              UU)) *
                  C00(0, s, 0, 0, 0, 0) +
              (-1 + AXG) * s * (-MUs + s + t) *
                  (2 *
                       (MUs * SS - SS * (MUs + MXs - s - t) +
                        (MXs - s - t) * UU) *
                       C11(0, s, 0, 0, 0, 0) +
                   (-2 * MXs + s + 2 * (MUs + MXs - s - t)) * UU *
                       C12(0, s, 0, 0, 0, 0))))) /
          (768. * Nc * Power(Pi, 2) * s * (-MXs + s + t)));
  return ret.real();
}

ComplexType ME_us_qqg_QGG(POLE pIEPS, bool sc, bool uc, bool axial, double Q2,
                          double P1K1, Parameters *params) {
  BOX_KINEMATIC;
  BOX_INDEX;
  BOX_BASE;
  double SS = sc, UU = uc, AXG = axial;
  ComplexType ret = 0;
  // ret.zeros();
  for (int itsq = 0; itsq < 6; itsq++) {
    for (int itq = 0; itq < 3; itq++) {
      int isq = is_up_quark(q) * 6 + itsq;
      int iq = is_up_quark(q) * 3 + itq;

      // Tensor<ComplexType, 2> Lp_IJk = cc_chiral(params);

      ComplexType L = (params->CHSQq[ch][sq][q].L);
      ComplexType R = (params->CHSQq[ch][sq][q].R);
      ComplexType Lp = conj(params->CHSQq[ch][sq][iq].R);
      ComplexType Rp = conj(params->CHSQq[ch][sq][iq].L);

      auto MQi = params->mSQ[isq];
      auto MQis = pow2(MQi);

      ComplexType LG = (params->GLSQq[isq][iq].L);
      ComplexType RG = (params->GLSQq[isq][iq].R);
      ComplexType LGp = conj(params->GLSQq[isq][q].R);
      ComplexType RGp = conj(params->GLSQq[isq][q].L);

      if (norm(LGp * Lp * R * RG + L * LG * RGp * Rp) > 0) {
        // ret +=
        _EPS0(
            ret,
            (Power(gs, 2) * Nc * (-1 + Power(Nc, 2)) *
             (LGp * Lp * R * RG + L * LG * RGp * Rp) * Power(TR, 2) *
             ((2 * Power(MU, 2) * SS * (MXs - t) +
               2 * (-2 + AXG) * Power(MX, 4) * UU +
               (MUs + MXs - s - t) *
                   (2 * SS * t + (-1 + AXG) * s * UU -
                    2 * (MUs + MXs - s - AXG * (MUs + MXs - s - t)) * UU) +
               MXs * (-2 * SS * (MUs + MXs - s - t) +
                      (3 * s - AXG * s + 6 * (MUs + MXs - s - t) -
                       4 * AXG * (MUs + MXs - s - t) + 2 * t) *
                          UU)) *
                  B0(0, MGs, MGs) -
              (MGs - MQis) *
                  (2 * Power(MU, 2) * SS * (MXs - t) +
                   2 * (-2 + AXG) * Power(MX, 4) * UU +
                   (MUs + MXs - s - t) *
                       (2 * SS * t + (-1 + AXG) * s * UU -
                        2 * (MUs + MXs - s - AXG * (MUs + MXs - s - t)) * UU) +
                   MXs * (-2 * SS * (MUs + MXs - s - t) +
                          (3 * s - AXG * s + 6 * (MUs + MXs - s - t) -
                           4 * AXG * (MUs + MXs - s - t) + 2 * t) *
                              UU)) *
                  C0(0, 0, s, MGs, MGs, MQis) -
              4 * Power(MU, 2) * MXs * SS * C00(0, s, 0, MGs, MQis, MGs) +
              4 * MXs * SS * (MUs + MXs - s - t) *
                  C00(0, s, 0, MGs, MQis, MGs) +
              4 * Power(MU, 2) * SS * t * C00(0, s, 0, MGs, MQis, MGs) -
              4 * SS * (MUs + MXs - s - t) * t * C00(0, s, 0, MGs, MQis, MGs) +
              8 * Power(MX, 4) * UU * C00(0, s, 0, MGs, MQis, MGs) -
              4 * AXG * Power(MX, 4) * UU * C00(0, s, 0, MGs, MQis, MGs) -
              6 * MXs * s * UU * C00(0, s, 0, MGs, MQis, MGs) +
              2 * AXG * MXs * s * UU * C00(0, s, 0, MGs, MQis, MGs) -
              12 * MXs * (MUs + MXs - s - t) * UU *
                  C00(0, s, 0, MGs, MQis, MGs) +
              8 * AXG * MXs * (MUs + MXs - s - t) * UU *
                  C00(0, s, 0, MGs, MQis, MGs) +
              2 * s * (MUs + MXs - s - t) * UU * C00(0, s, 0, MGs, MQis, MGs) -
              2 * AXG * s * (MUs + MXs - s - t) * UU *
                  C00(0, s, 0, MGs, MQis, MGs) +
              4 * Power(MUs + MXs - s - t, 2) * UU *
                  C00(0, s, 0, MGs, MQis, MGs) -
              4 * AXG * Power(MUs + MXs - s - t, 2) * UU *
                  C00(0, s, 0, MGs, MQis, MGs) -
              4 * MXs * t * UU * C00(0, s, 0, MGs, MQis, MGs) +
              4 * (MUs + MXs - s - t) * t * UU * C00(0, s, 0, MGs, MQis, MGs) -
              2 * Power(MX, 4) * s * UU * C12(0, s, 0, MGs, MQis, MGs) +
              2 * AXG * Power(MX, 4) * s * UU * C12(0, s, 0, MGs, MQis, MGs) +
              MXs * Power(s, 2) * UU * C12(0, s, 0, MGs, MQis, MGs) -
              AXG * MXs * Power(s, 2) * UU * C12(0, s, 0, MGs, MQis, MGs) +
              4 * MXs * s * (MUs + MXs - s - t) * UU *
                  C12(0, s, 0, MGs, MQis, MGs) -
              4 * AXG * MXs * s * (MUs + MXs - s - t) * UU *
                  C12(0, s, 0, MGs, MQis, MGs) -
              Power(s, 2) * (MUs + MXs - s - t) * UU *
                  C12(0, s, 0, MGs, MQis, MGs) +
              AXG * Power(s, 2) * (MUs + MXs - s - t) * UU *
                  C12(0, s, 0, MGs, MQis, MGs) -
              2 * s * Power(MUs + MXs - s - t, 2) * UU *
                  C12(0, s, 0, MGs, MQis, MGs) +
              2 * AXG * s * Power(MUs + MXs - s - t, 2) * UU *
                  C12(0, s, 0, MGs, MQis, MGs) +
              4 * Power(MU, 2) * MXs * s * SS * C2(0, s, 0, MGs, MQis, MGs) -
              2 * AXG * Power(MU, 2) * MXs * s * SS *
                  C2(0, s, 0, MGs, MQis, MGs) -
              2 * Power(MU, 2) * s * SS * (MUs + MXs - s - t) *
                  C2(0, s, 0, MGs, MQis, MGs) +
              2 * AXG * Power(MU, 2) * s * SS * (MUs + MXs - s - t) *
                  C2(0, s, 0, MGs, MQis, MGs) -
              4 * MXs * s * SS * (MUs + MXs - s - t) *
                  C2(0, s, 0, MGs, MQis, MGs) +
              2 * AXG * MXs * s * SS * (MUs + MXs - s - t) *
                  C2(0, s, 0, MGs, MQis, MGs) +
              2 * s * SS * Power(MUs + MXs - s - t, 2) *
                  C2(0, s, 0, MGs, MQis, MGs) -
              2 * AXG * s * SS * Power(MUs + MXs - s - t, 2) *
                  C2(0, s, 0, MGs, MQis, MGs) -
              2 * Power(MU, 2) * s * SS * t * C2(0, s, 0, MGs, MQis, MGs) +
              2 * s * SS * (MUs + MXs - s - t) * t *
                  C2(0, s, 0, MGs, MQis, MGs) -
              2 * Power(MX, 4) * s * UU * C2(0, s, 0, MGs, MQis, MGs) +
              MXs * Power(s, 2) * UU * C2(0, s, 0, MGs, MQis, MGs) +
              AXG * MXs * Power(s, 2) * UU * C2(0, s, 0, MGs, MQis, MGs) +
              4 * MXs * s * (MUs + MXs - s - t) * UU *
                  C2(0, s, 0, MGs, MQis, MGs) -
              2 * AXG * MXs * s * (MUs + MXs - s - t) * UU *
                  C2(0, s, 0, MGs, MQis, MGs) +
              Power(s, 2) * (MUs + MXs - s - t) * UU *
                  C2(0, s, 0, MGs, MQis, MGs) -
              AXG * Power(s, 2) * (MUs + MXs - s - t) * UU *
                  C2(0, s, 0, MGs, MQis, MGs) -
              2 * s * Power(MUs + MXs - s - t, 2) * UU *
                  C2(0, s, 0, MGs, MQis, MGs) +
              2 * AXG * s * Power(MUs + MXs - s - t, 2) * UU *
                  C2(0, s, 0, MGs, MQis, MGs) +
              2 * AXG * MXs * s * t * UU * C2(0, s, 0, MGs, MQis, MGs) -
              2 * AXG * s * (MUs + MXs - s - t) * t * UU *
                  C2(0, s, 0, MGs, MQis, MGs) +
              2 * Power(MU, 2) * MXs * s * SS * C22(0, s, 0, MGs, MQis, MGs) -
              2 * AXG * Power(MU, 2) * MXs * s * SS *
                  C22(0, s, 0, MGs, MQis, MGs) -
              2 * Power(MU, 2) * s * SS * (MUs + MXs - s - t) *
                  C22(0, s, 0, MGs, MQis, MGs) +
              2 * AXG * Power(MU, 2) * s * SS * (MUs + MXs - s - t) *
                  C22(0, s, 0, MGs, MQis, MGs) -
              2 * MXs * s * SS * (MUs + MXs - s - t) *
                  C22(0, s, 0, MGs, MQis, MGs) +
              2 * AXG * MXs * s * SS * (MUs + MXs - s - t) *
                  C22(0, s, 0, MGs, MQis, MGs) +
              2 * s * SS * Power(MUs + MXs - s - t, 2) *
                  C22(0, s, 0, MGs, MQis, MGs) -
              2 * AXG * s * SS * Power(MUs + MXs - s - t, 2) *
                  C22(0, s, 0, MGs, MQis, MGs) +
              2 * Power(MX, 4) * s * UU * C22(0, s, 0, MGs, MQis, MGs) -
              2 * AXG * Power(MX, 4) * s * UU * C22(0, s, 0, MGs, MQis, MGs) -
              2 * MXs * Power(s, 2) * UU * C22(0, s, 0, MGs, MQis, MGs) +
              2 * AXG * MXs * Power(s, 2) * UU * C22(0, s, 0, MGs, MQis, MGs) -
              2 * MXs * s * (MUs + MXs - s - t) * UU *
                  C22(0, s, 0, MGs, MQis, MGs) +
              2 * AXG * MXs * s * (MUs + MXs - s - t) * UU *
                  C22(0, s, 0, MGs, MQis, MGs) +
              2 * Power(s, 2) * (MUs + MXs - s - t) * UU *
                  C22(0, s, 0, MGs, MQis, MGs) -
              2 * AXG * Power(s, 2) * (MUs + MXs - s - t) * UU *
                  C22(0, s, 0, MGs, MQis, MGs) -
              2 * MXs * s * t * UU * C22(0, s, 0, MGs, MQis, MGs) +
              2 * AXG * MXs * s * t * UU * C22(0, s, 0, MGs, MQis, MGs) +
              2 * s * (MUs + MXs - s - t) * t * UU *
                  C22(0, s, 0, MGs, MQis, MGs) -
              2 * AXG * s * (MUs + MXs - s - t) * t * UU *
                  C22(0, s, 0, MGs, MQis, MGs))) /
                (768. * Power(Pi, 2) * s * (Power(MU, 2) - MUs - MXs + s + t)));
      }
    }
  }
  return ret.real();
}

ComplexType ME_us_qqg_QQG(POLE pIEPS, bool sc, bool uc, bool axial, double Q2,
                          double P1K1, Parameters *params) {
  BOX_KINEMATIC;
  BOX_INDEX;
  BOX_BASE;
  double SS = sc, UU = uc, AXG = axial;
  ComplexType ret;
  // ret.zeros();
  for (int itsq = 0; itsq < 6; itsq++) {
    for (int itq = 0; itq < 3; itq++) {
      int isq = is_up_quark(q) * 6 + itsq;
      int iq = is_up_quark(q) * 3 + itq;

      // Tensor<ComplexType, 2> Lp_IJk = cc_chiral(params);

      ComplexType L = (params->CHSQq[ch][sq][q].L);
      ComplexType R = (params->CHSQq[ch][sq][q].R);
      ComplexType Lp = conj(params->CHSQq[ch][sq][iq].R);
      ComplexType Rp = conj(params->CHSQq[ch][sq][iq].L);

      auto MQi = params->mSQ[isq];
      auto MQis = pow2(MQi);

      ComplexType LG = (params->GLSQq[isq][iq].L);
      ComplexType RG = (params->GLSQq[isq][iq].R);
      ComplexType LGp = conj(params->GLSQq[isq][q].R);
      ComplexType RGp = conj(params->GLSQq[isq][q].L);

      if (norm(LGp * Lp * R * RG + L * LG * RGp * Rp) > 0) {
        // ret +=
        _EPS0(
            ret,
            -(Power(gs, 2) * (-1 + Power(Nc, 2)) *
              (LGp * Lp * R * RG + L * LG * RGp * Rp) * Power(TR, 2) *
              (2. *
                   (2 * Power(MU, 2) * SS * (MXs - t) +
                    2 * (-2 + AXG) * Power(MX, 4) * UU +
                    (MUs + MXs - s - t) *
                        (2 * SS * t + (-1 + AXG) * s * UU -
                         2 * (MUs + MXs - s - AXG * (MUs + MXs - s - t)) * UU) +
                    MXs * (-2 * SS * (MUs + MXs - s - t) +
                           (3 * s - AXG * s + 6 * (MUs + MXs - s - t) -
                            4 * AXG * (MUs + MXs - s - t) + 2 * t) *
                               UU)) *
                   C00(0, s, 0, MQis, MGs, MQis) -
               (-1 + AXG) * s * (-MUs + s + t) *
                   (-(Power(MU, 2) * SS) + SS * (MUs + MXs - s - t) +
                    (-MXs + s + t) * UU) *
                   C2(0, s, 0, MQis, MGs, MQis) +
               (-1 + AXG) * s * (-MUs + s + t) *
                   ((-2 * MXs + s + 2 * (MUs + MXs - s - t)) * UU *
                        C12(0, s, 0, MQis, MGs, MQis) +
                    2 *
                        (Power(MU, 2) * SS - SS * (MUs + MXs - s - t) +
                         (MXs - s - t) * UU) *
                        C22(0, s, 0, MQis, MGs, MQis)))) /
                (768. * Nc * Power(Pi, 2) * s *
                 (Power(MU, 2) - MUs - MXs + s + t)));
      }
    }
  }
  return ret.real();
}
