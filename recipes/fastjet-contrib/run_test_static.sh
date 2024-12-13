#!/bin/bash
set -x

test -f $PREFIX/lib/libCentauro.a
test -f $PREFIX/lib/libClusteringVetoPlugin.a
test -f $PREFIX/lib/libConstituentSubtractor.a
test -f $PREFIX/lib/libEnergyCorrelator.a
test -f $PREFIX/lib/libFlavorCone.a
test -f $PREFIX/lib/libGenericSubtractor.a
test -f $PREFIX/lib/libJetCleanser.a
test -f $PREFIX/lib/libJetFFMoments.a
test -f $PREFIX/lib/libJetsWithoutJets.a
test -f $PREFIX/lib/libLundPlane.a
test -f $PREFIX/lib/libNsubjettiness.a
test -f $PREFIX/lib/libQCDAwarePlugin.a
test -f $PREFIX/lib/libRecursiveTools.a
test -f $PREFIX/lib/libScJet.a
test -f $PREFIX/lib/libSignalFreeBackgroundEstimator.a
test -f $PREFIX/lib/libSoftKiller.a
test -f $PREFIX/lib/libSubjetCounting.a
test -f $PREFIX/lib/libValenciaPlugin.a
test -f $PREFIX/lib/libVariableR.a
test ! -f $PREFIX/lib/libfastjetcontribfragile${SHLIB_EXT}

test -f $PREFIX/include/fastjet/contrib/Centauro.hh
test -f $PREFIX/include/fastjet/contrib/ClusteringVetoPlugin.hh
test -f $PREFIX/include/fastjet/contrib/ConstituentSubtractor.hh
test -f $PREFIX/include/fastjet/contrib/IterativeConstituentSubtractor.hh
test -f $PREFIX/include/fastjet/contrib/RescalingClasses.hh
test -f $PREFIX/include/fastjet/contrib/EnergyCorrelator.hh
test -f $PREFIX/include/fastjet/contrib/FlavorCone.hh
test -f $PREFIX/include/fastjet/contrib/GenericSubtractor.hh
test -f $PREFIX/include/fastjet/contrib/ShapeWithPartition.hh
test -f $PREFIX/include/fastjet/contrib/ShapeWithComponents.hh
test -f $PREFIX/include/fastjet/contrib/JetCleanser.hh
test -f $PREFIX/include/fastjet/contrib/JetFFMoments.hh
test -f $PREFIX/include/fastjet/contrib/JetsWithoutJets.hh
test -f $PREFIX/include/fastjet/contrib/EventStorage.hh
test -f $PREFIX/include/fastjet/contrib/KTClusCXX.hh
test -f $PREFIX/include/fastjet/contrib/LundGenerator.hh
test -f $PREFIX/include/fastjet/contrib/LundWithSecondary.hh
test -f $PREFIX/include/fastjet/contrib/SecondaryLund.hh
test -f $PREFIX/include/fastjet/contrib/RecursiveLundEEGenerator.hh
test -f $PREFIX/include/fastjet/contrib/LundJSON.hh
test -f $PREFIX/include/fastjet/contrib/LundEEHelpers.hh
test -f $PREFIX/include/fastjet/contrib/Nsubjettiness.hh
test -f $PREFIX/include/fastjet/contrib/Njettiness.hh
test -f $PREFIX/include/fastjet/contrib/NjettinessPlugin.hh
test -f $PREFIX/include/fastjet/contrib/XConePlugin.hh
test -f $PREFIX/include/fastjet/contrib/MeasureDefinition.hh
test -f $PREFIX/include/fastjet/contrib/ExtraRecombiners.hh
test -f $PREFIX/include/fastjet/contrib/AxesDefinition.hh
test -f $PREFIX/include/fastjet/contrib/TauComponents.hh
test -f $PREFIX/include/fastjet/contrib/QCDAwarePlugin.hh
test -f $PREFIX/include/fastjet/contrib/DistanceMeasure.hh
test -f $PREFIX/include/fastjet/contrib/Recluster.hh
test -f $PREFIX/include/fastjet/contrib/RecursiveSymmetryCutBase.hh
test -f $PREFIX/include/fastjet/contrib/ModifiedMassDropTagger.hh
test -f $PREFIX/include/fastjet/contrib/SoftDrop.hh
test -f $PREFIX/include/fastjet/contrib/IteratedSoftDrop.hh
test -f $PREFIX/include/fastjet/contrib/RecursiveSoftDrop.hh
test -f $PREFIX/include/fastjet/contrib/BottomUpSoftDrop.hh
test -f $PREFIX/include/fastjet/contrib/ScJet.hh
test -f $PREFIX/include/fastjet/contrib/SignalFreeBackgroundEstimator.hh
test -f $PREFIX/include/fastjet/contrib/SoftKiller.hh
test -f $PREFIX/include/fastjet/contrib/SubjetCounting.hh
test -f $PREFIX/include/fastjet/contrib/ValenciaPlugin.hh
test -f $PREFIX/include/fastjet/contrib/VariableR.hh
test -f $PREFIX/include/fastjet/contrib/VariableRPlugin.hh

# The repository is too large to vendor in the info/test/ package metadata, so download it
# Need to use PKG_VERSION as the shell script doesn't have access to Jinja2 variables
# c.f. https://docs.conda.io/projects/conda-build/en/stable/user-guide/environment-variables.html#environment-variables-set-during-the-build-process
curl -sL https://fastjet.hepforge.org/contrib/downloads/fjcontrib-"${PKG_VERSION}".tar.gz | tar -xz
cd fjcontrib-"${PKG_VERSION}"

cd Centauro
grep -rl '#include "Centauro.hh"' | xargs sed -i 's|#include "Centauro.hh"|#include "fastjet/contrib/Centauro.hh"|g' Centauro.cc
$CXX example.cc -o example $CXXFLAGS $LDFLAGS -lCentauro -lfastjet
./example < ../data/single-event.dat &> Centauro_example_output.txt

cd ../ClusteringVetoPlugin
grep -rl '#include "ClusteringVetoPlugin.hh"' | xargs sed -i 's|#include "ClusteringVetoPlugin.hh"|#include "fastjet/contrib/ClusteringVetoPlugin.hh"|g'
$CXX example.cc -o example $CXXFLAGS $LDFLAGS -lClusteringVetoPlugin -lfastjet
./example < ../data/single-event.dat &> ClusteringVetoPlugin_example_output.txt

cd ../ConstituentSubtractor
grep -rl '#include "ConstituentSubtractor.hh"' | xargs sed -i 's|#include "ConstituentSubtractor.hh"|#include "fastjet/contrib/ConstituentSubtractor.hh"|g'
grep -rl '#include "IterativeConstituentSubtractor.hh"' | xargs sed -i 's|#include "IterativeConstituentSubtractor.hh"|#include "fastjet/contrib/IterativeConstituentSubtractor.hh"|g'
grep -rl '#include "RescalingClasses.hh"' | xargs sed -i 's|#include "RescalingClasses.hh"|#include "fastjet/contrib/RescalingClasses.hh"|g'
$CXX example_jet_by_jet.cc -o example_jet_by_jet $CXXFLAGS $LDFLAGS -lConstituentSubtractor -lfastjettools -lfastjet
./example_jet_by_jet < ../data/Pythia-Zp2jets-lhc-pileup-1ev.dat &> example_jet_by_jet_output.txt
$CXX example_event_wide.cc -o example_event_wide $CXXFLAGS $LDFLAGS -lConstituentSubtractor -lfastjettools -lfastjet
./example_event_wide < ../data/Pythia-Zp2jets-lhc-pileup-1ev.dat &> example_event_wide_output.txt
$CXX example_iterative.cc -o example_iterative $CXXFLAGS $LDFLAGS -lConstituentSubtractor -lfastjettools -lfastjet
./example_iterative < ../data/Pythia-Zp2jets-lhc-pileup-1ev.dat &> example_iterative_output.txt
$CXX example_background_rescaling.cc -o example_background_rescaling $CXXFLAGS $LDFLAGS -lConstituentSubtractor -lfastjettools -lfastjet
./example_background_rescaling < ../data/Pythia-Zp2jets-lhc-pileup-1ev.dat &> example_background_rescaling_output.txt
$CXX example_whole_event_using_charged_info.cc -o example_whole_event_using_charged_info $CXXFLAGS $LDFLAGS -lConstituentSubtractor -lfastjettools -lfastjet
./example_whole_event_using_charged_info < ../data/Pythia-Zp2jets-lhc-pileup-1ev.dat &> example_whole_event_using_charged_info_output.txt
