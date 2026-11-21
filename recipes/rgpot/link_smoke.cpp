#include "rgpot/CPMDPot/CPMDPot.hpp"
#include "rgpot/NWChemPot/NWChemPot.hpp"

int main() {
  bool (rgpot::CPMDPot::*cpmd)() const = &rgpot::CPMDPot::available;
  bool (rgpot::NWChemPot::*nwchem)() const = &rgpot::NWChemPot::available;
  volatile auto keep_cpmd = cpmd;
  volatile auto keep_nwchem = nwchem;
  return keep_cpmd == nullptr || keep_nwchem == nullptr;
}
