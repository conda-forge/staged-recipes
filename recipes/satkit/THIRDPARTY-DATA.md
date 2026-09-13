# Third-party data embedded in satkit

satkit compiles a few small datasets into the library so that frames and
gravity work with no data directory and no network (`data/embedded/*.gz`,
inflated on first use). They are **not** covered by the MIT / Apache-2.0
licence of the satkit source code; their own terms and attributions are
below. `data/embedded/SOURCES.json` records the SHA-256 of every original
file and of the embedded copy. Larger files — the JPL DE440/DE421
ephemerides and the Earth-orientation and space-weather tables — are
downloaded on demand, not embedded; their sources and licences are listed in
`data/README.md`.

## ITU_GRACE16 gravity model — CC BY 4.0

- **Citation:** Akyilmaz, O.; Ustun, A.; Aydin, C.; Arslan, N.; Doganalp, S.;
  Guney, C.; Mercan, H.; Uygur, S.O.; Uz, M.; Yagci, O. (2016): *ITU_GRACE16
  The global gravity field model including GRACE data up to degree and order
  180 of ITU and other collaborating institutions.* GFZ Data Services.
  <https://doi.org/10.5880/icgem.2016.006>
- **Distributed by:** International Centre for Global Earth Models (ICGEM),
  GFZ German Research Centre for Geosciences, <https://icgem.gfz-potsdam.de/>
- **Licence:** Creative Commons Attribution 4.0 International (CC BY 4.0),
  <https://creativecommons.org/licenses/by/4.0/>
- **Modification:** the embedded copy is **truncated from degree/order 180 to
  degree/order 70** (satkit evaluates the field to at most degree 40). The
  file's header block, which carries the citation and licence statement, is
  retained unchanged. Original file SHA-256
  `b6bea9c78ad168f1e206fc7211f90b64fba54325c832f4473f6c05a07adbc718`
  (1,782,369 bytes); embedded copy
  `a9a2b237109d51fce0e02703472b62a9bd8f8d5371ff448f237db32d69e8952c`
  (279,549 bytes).

Results derived from `gravmodel.itu_grace16` should cite the model as above.

## EGM96 gravity model — US Government work

- Lemoine, F.G., et al. (1998): *The Development of the Joint NASA GSFC and
  NIMA Geopotential Model EGM96*, NASA/TP-1998-206861. NASA Goddard Space
  Flight Center / National Imagery and Mapping Agency.
- Distributed by ICGEM. A work of the United States Government, not subject
  to copyright (public domain).
- Modification: truncated from degree/order 360 to degree/order 70.

## JGM-2 and JGM-3 gravity models — US Government work

- JGM-2: Nerem, R.S., et al. (1994), *Gravity model development for
  TOPEX/POSEIDON: Joint Gravity Models 1 and 2*, J. Geophys. Res. 99(C12).
- JGM-3: Tapley, B.D., et al. (1996), *The Joint Gravity Model 3*,
  J. Geophys. Res. 101(B12).
- NASA Goddard Space Flight Center / University of Texas Center for Space
  Research; distributed by ICGEM. US Government work (public domain).
- Embedded unmodified (both models are complete to degree 70).

## IERS Conventions (2010) precession-nutation tables

- Tables 5.2a, 5.2b and 5.2d (the X, Y and s + XY/2 series of the IAU
  2006/2000A precession-nutation model) from Petit, G. and Luzum, B. (eds.),
  *IERS Conventions (2010)*, IERS Technical Note No. 36, Frankfurt am Main:
  Verlag des Bundesamts für Kartographie und Geodäsie, 2010.
- International Earth Rotation and Reference Systems Service (IERS); freely
  redistributable. Embedded unmodified.
