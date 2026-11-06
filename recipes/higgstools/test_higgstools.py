import Higgs.predictions as HP

pred = HP.Predictions()
h = pred.addParticle(HP.BsmParticle("h", "neutral", "even"))
h.setMass(125.09)
HP.effectiveCouplingInput(h, HP.smLikeEffCouplings)

xs = h.cxn(HP.Collider.LHC13, HP.Production.ggH)
print(h, xs)
# SM-like ggH cross section at 13 TeV is about 48.5 pb
assert 45 < xs < 52, f"Unexpected ggH cross section: {xs} pb"
