# TODO:
# add ScalableProblems_java

get_ac_init_version(${Ipopt_DIR}/configure.ac IPOPT)

set(IPOPT_VERSION_MAJOR   "${IPOPT_MAJOR_VERSION}"  CACHE STRING "The IpOpt major version number")
set(IPOPT_VERSION_MINOR   "${IPOPT_MINOR_VERSION}"  CACHE STRING "The IpOpt minor version number")
set(IPOPT_VERSION_RELEASE "${IPOPT_PATCH_VERSION}"  CACHE STRING "The IpOpt patch version number")
set(IPOPT_VERSION         "${IPOPT_VERSION_STRING}" CACHE STRING "The IpOpt version")

set(IPOPT_WC_REVISION "0")
if (EXISTS "${Ipopt_DIR}/.svn")
  find_package(Subversion)
  if (Subversion_FOUND)
    Subversion_WC_INFO(${Ipopt_DIR} IPOPT)
  endif ()
endif ()

if (EXISTS "${Ipopt_DIR}/.git")
  find_package(Git)
  if (Git_FOUND)
    include(export_git)
    GIT_WC_INFO(${Ipopt_DIR} IPOPT)
    set(IPOPT_WC_REVISION "${IPOPT_WC_SVNEQUIV}") # alphanumeric rev not yet managed
  endif ()
endif ()

message(STATUS "Current IPOPT revision is ${IPOPT_WC_REVISION}")
set(IPOPT_SVN_REV "${IPOPT_WC_REVISION}" CACHE STRING "The IPOPT subversion revision" FORCE)

mark_as_advanced(IPOPT_VERSION_MAJOR
                 IPOPT_VERSION_MINOR
                 IPOPT_VERSION_RELEASE
                 IPOPT_VERSION
                 IPOPT_SVN_REV)

add_definitions(-DIPOPTLIB_BUILD)

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/include/config.h.in       ${CMAKE_BINARY_DIR}/Ipopt/include/config.h)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/include/config_ipopt.h.in ${CMAKE_BINARY_DIR}/Ipopt/include/config_ipopt.h)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/include/config_ipopt.h.in ${CMAKE_BINARY_DIR}/Ipopt/include/install/IpoptConfig.h)

#
# pkg-config file generation
#

set(prefix               "${CMAKE_INSTALL_PREFIX}")
set(exec_prefix          "\${prefix}")
set(libdir               "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}")
set(includedir           "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR}")
set(IPOPTLIB_LFLAGS_NOPC "-lm -ldl")
set(IPOPTLIB_PCFILES     "")
if (COIN_HAS_LAPACK OR COIN_USE_SYSTEM_LAPACK)
  set(IPOPTLIB_PCFILES "${IPOPTLIB_PCFILES} -llapack")
endif ()
if (COIN_HAS_BLAS OR COIN_USE_BLAS)
  set(IPOPTLIB_PCFILES "${IPOPTLIB_PCFILES} -lblas")
endif ()
if (COIN_ENABLE_DOWNLOAD_CLAPACK)
  set(IPOPTLIB_PCFILES "${IPOPTLIB_PCFILES} -lf2c")
endif ()
set(PACKAGE_VERSION "${IPOPT_VERSION}")
set(IPOPT_OUTPUT_NAME "ipopt-3")

configure_file(${CMAKE_CURRENT_LIST_DIR}/ipopt_cmake.pc.in ${CMAKE_BINARY_DIR}/Ipopt/ipopt.pc @ONLY)

set(libdir         "${Ipopt_DIR}")
set(abs_source_dir "${CMAKE_BINARY_DIR}/bin")

install(FILES ${CMAKE_BINARY_DIR}/Ipopt/ipopt.pc
        DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/pkgconfig/)

#
# Build
#

set (IPOPT_SRC_ALGORITHM_LIST ${Ipopt_DIR}/src/Algorithm/IpAdaptiveMuUpdate.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpAlgBuilder.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpAlgorithmRegOp.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpAugRestoSystemSolver.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpBacktrackingLineSearch.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpDefaultIterateInitializer.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpEquilibrationScaling.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpExactHessianUpdater.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpFilterLSAcceptor.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpFilter.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpGenAugSystemSolver.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpGradientScaling.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpIpoptAlg.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpIpoptCalculatedQuantities.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpIpoptData.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpIteratesVector.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpLeastSquareMults.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpLimMemQuasiNewtonUpdater.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpLoqoMuOracle.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpLowRankAugSystemSolver.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpLowRankSSAugSystemSolver.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpMonotoneMuUpdate.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpNLPBoundsRemover.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpNLPScaling.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpOptErrorConvCheck.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpOrigIpoptNLP.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpOrigIterationOutput.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpPDFullSpaceSolver.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpPDPerturbationHandler.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpPDSearchDirCalc.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpPenaltyLSAcceptor.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpProbingMuOracle.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpQualityFunctionMuOracle.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpRestoConvCheck.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpRestoFilterConvCheck.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpRestoIpoptNLP.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpRestoIterateInitializer.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpRestoIterationOutput.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpRestoMinC_1Nrm.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpRestoPenaltyConvCheck.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpRestoRestoPhase.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpStdAugSystemSolver.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpTimingStatistics.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpUserScaling.cpp
                              ${Ipopt_DIR}/src/Algorithm/IpWarmStartIterateInitializer.cpp)

set (IPOPT_SRC_ALGORITHM_INEXACT_LIST ${Ipopt_DIR}/src/Algorithm/Inexact/IpInexactAlgBuilder.cpp
                                      ${Ipopt_DIR}/src/Algorithm/Inexact/IpInexactCq.cpp
                                      ${Ipopt_DIR}/src/Algorithm/Inexact/IpInexactData.cpp
                                      ${Ipopt_DIR}/src/Algorithm/Inexact/IpInexactDoglegNormal.cpp
                                      ${Ipopt_DIR}/src/Algorithm/Inexact/IpInexactLSAcceptor.cpp
                                      ${Ipopt_DIR}/src/Algorithm/Inexact/IpInexactNewtonNormal.cpp
                                      ${Ipopt_DIR}/src/Algorithm/Inexact/IpInexactNormalTerminationTester.cpp
                                      ${Ipopt_DIR}/src/Algorithm/Inexact/IpInexactRegOp.cpp
                                      ${Ipopt_DIR}/src/Algorithm/Inexact/IpInexactSearchDirCalc.cpp
                                      ${Ipopt_DIR}/src/Algorithm/Inexact/IpInexactTSymScalingMethod.cpp
                                      ${Ipopt_DIR}/src/Algorithm/Inexact/IpIterativeSolverTerminationTester.cpp
                                      ${Ipopt_DIR}/src/Algorithm/Inexact/IpInexactPDSolver.cpp
                                      ${Ipopt_DIR}/src/Algorithm/Inexact/IpInexactPDTerminationTester.cpp
                                      ${Ipopt_DIR}/src/Algorithm/Inexact/IpIterativePardisoSolverInterface.cpp)

set (IPOPT_SRC_ALGORITHM_LINEARSOLVERS_LIST ${Ipopt_DIR}/src/Algorithm/LinearSolvers/IpLinearSolvers.c 
                                            ${Ipopt_DIR}/src/Algorithm/LinearSolvers/IpLinearSolversRegOp.cpp
                                            ${Ipopt_DIR}/src/Algorithm/LinearSolvers/IpSlackBasedTSymScalingMethod.cpp
                                            ${Ipopt_DIR}/src/Algorithm/LinearSolvers/IpTripletToCSRConverter.cpp
                                            ${Ipopt_DIR}/src/Algorithm/LinearSolvers/IpTSymDependencyDetector.cpp
                                            ${Ipopt_DIR}/src/Algorithm/LinearSolvers/IpTSymLinearSolver.cpp
                                            ${Ipopt_DIR}/src/Algorithm/LinearSolvers/IpMa27TSolverInterface.cpp
                                            ${Ipopt_DIR}/src/Algorithm/LinearSolvers/IpMa57TSolverInterface.cpp
                                            ${Ipopt_DIR}/src/Algorithm/LinearSolvers/IpMa86SolverInterface.cpp
                                            ${Ipopt_DIR}/src/Algorithm/LinearSolvers/IpMa97SolverInterface.cpp
                                            ${Ipopt_DIR}/src/Algorithm/LinearSolvers/IpMc19TSymScalingMethod.cpp
                                            ${Ipopt_DIR}/src/Algorithm/LinearSolvers/IpMa28TDependencyDetector.cpp
                                            ${Ipopt_DIR}/src/Algorithm/LinearSolvers/IpMa77SolverInterface.cpp)

if (IPOPT_ENABLE_LINEARSOLVERLOADER OR COIN_ENABLE_COMPILE_HSL OR COIN_USE_COINHSL)
  enable_language(Fortran)
endif ()

if (IPOPT_ENABLE_LINEARSOLVERLOADER AND (NOT "${CMAKE_Fortran_COMPILER}" STREQUAL ""))
  set (IPOPT_SRC_ALGORITHM_LINEARSOLVERS_LIST ${IPOPT_SRC_ALGORITHM_LINEARSOLVERS_LIST}
                                              ${Ipopt_DIR}/src/Algorithm/LinearSolvers/IpPardisoSolverInterface.cpp)
else ()
  if (IPOPT_HAS_PARDISO)
    set (IPOPT_SRC_ALGORITHM_LINEARSOLVERS_LIST ${IPOPT_SRC_ALGORITHM_LINEARSOLVERS_LIST}
                                                ${Ipopt_DIR}/src/Algorithm/LinearSolvers/IpPardisoSolverInterface.cpp)
  endif ()
  if (COINHSL_HAS_MA28 AND (NOT "${CMAKE_Fortran_COMPILER}" STREQUAL ""))
    set (IPOPT_SRC_ALGORITHM_LINEARSOLVERS_LIST ${IPOPT_SRC_ALGORITHM_LINEARSOLVERS_LIST}
                                                ${Ipopt_DIR}/src/Algorithm/LinearSolvers/IpMa28Partition.F)
  endif ()
endif ()

if (IPOPT_HAS_WSMP)
  set (IPOPT_SRC_ALGORITHM_LINEARSOLVERS_LIST ${IPOPT_SRC_ALGORITHM_LINEARSOLVERS_LIST}
                                              ${Ipopt_DIR}/src/Algorithm/LinearSolvers/IpWsmpSolverInterface.cpp
                                              ${Ipopt_DIR}/src/Algorithm/LinearSolvers/IpIterativeWsmpSolverInterface.cpp)
endif ()

if (IPOPT_HAS_MUMPS)
  set (IPOPT_SRC_ALGORITHM_LINEARSOLVERS_LIST ${IPOPT_SRC_ALGORITHM_LINEARSOLVERS_LIST}
                                              ${Ipopt_DIR}/src/Algorithm/LinearSolvers/IpMumpsSolverInterface.cpp)
endif ()

set (IPOPT_SRC_APPS_CUTERINTERFACE_LIST )
set (IPOPT_SRC_APPS_AMPLSOLVER_LIST )

set (IPOPT_SRC_CONTRIB_CGPENALTY_LIST ${Ipopt_DIR}/src/contrib/CGPenalty/IpCGPenaltyCq.cpp
                                      ${Ipopt_DIR}/src/contrib/CGPenalty/IpCGPenaltyData.cpp
                                      ${Ipopt_DIR}/src/contrib/CGPenalty/IpCGPenaltyLSAcceptor.cpp
                                      ${Ipopt_DIR}/src/contrib/CGPenalty/IpCGPenaltyRegOp.cpp
                                      ${Ipopt_DIR}/src/contrib/CGPenalty/IpCGPerturbationHandler.cpp
                                      ${Ipopt_DIR}/src/contrib/CGPenalty/IpCGSearchDirCalc.cpp
                                      ${Ipopt_DIR}/src/contrib/CGPenalty/IpPiecewisePenalty.cpp)

set (IPOPT_SRC_COMMON_LIST ${Ipopt_DIR}/src/Common/IpLibraryLoader.cpp 
                           ${Ipopt_DIR}/src/Common/IpJournalist.cpp
                           ${Ipopt_DIR}/src/Common/IpObserver.cpp
                           ${Ipopt_DIR}/src/Common/IpOptionsList.cpp
                           ${Ipopt_DIR}/src/Common/IpRegOptions.cpp
                           ${Ipopt_DIR}/src/Common/IpTaggedObject.cpp
                           ${Ipopt_DIR}/src/Common/IpUtils.cpp)

set (IPOPT_SRC_INTERFACES_LIST ${Ipopt_DIR}/src/Interfaces/IpInterfacesRegOp.cpp
                               ${Ipopt_DIR}/src/Interfaces/IpIpoptApplication.cpp
                               ${Ipopt_DIR}/src/Interfaces/IpSolveStatistics.cpp
                               ${Ipopt_DIR}/src/Interfaces/IpStdCInterface.cpp
                               ${Ipopt_DIR}/src/Interfaces/IpStdFInterface.c
                               ${Ipopt_DIR}/src/Interfaces/IpStdInterfaceTNLP.cpp
			       ${Ipopt_DIR}/src/Interfaces/IpTNLP.cpp
                               ${Ipopt_DIR}/src/Interfaces/IpTNLPAdapter.cpp
                               ${Ipopt_DIR}/src/Interfaces/IpTNLPReducer.cpp)

set (IPOPT_SRC_LINALG_LIST ${Ipopt_DIR}/src/LinAlg/IpBlas.cpp
                           ${Ipopt_DIR}/src/LinAlg/IpCompoundMatrix.cpp
                           ${Ipopt_DIR}/src/LinAlg/IpCompoundSymMatrix.cpp
                           ${Ipopt_DIR}/src/LinAlg/IpCompoundVector.cpp
                           ${Ipopt_DIR}/src/LinAlg/IpDenseGenMatrix.cpp
                           ${Ipopt_DIR}/src/LinAlg/IpDenseSymMatrix.cpp
                           ${Ipopt_DIR}/src/LinAlg/IpDenseVector.cpp
                           ${Ipopt_DIR}/src/LinAlg/IpDiagMatrix.cpp
                           ${Ipopt_DIR}/src/LinAlg/IpExpandedMultiVectorMatrix.cpp
                           ${Ipopt_DIR}/src/LinAlg/IpExpansionMatrix.cpp
                           ${Ipopt_DIR}/src/LinAlg/IpIdentityMatrix.cpp
                           ${Ipopt_DIR}/src/LinAlg/IpLapack.cpp
                           ${Ipopt_DIR}/src/LinAlg/IpLowRankUpdateSymMatrix.cpp
                           ${Ipopt_DIR}/src/LinAlg/IpMatrix.cpp
                           ${Ipopt_DIR}/src/LinAlg/IpMultiVectorMatrix.cpp
                           ${Ipopt_DIR}/src/LinAlg/IpScaledMatrix.cpp
                           ${Ipopt_DIR}/src/LinAlg/IpSumMatrix.cpp
                           ${Ipopt_DIR}/src/LinAlg/IpSumSymMatrix.cpp
                           ${Ipopt_DIR}/src/LinAlg/IpSymScaledMatrix.cpp
                           ${Ipopt_DIR}/src/LinAlg/IpTransposeMatrix.cpp
                           ${Ipopt_DIR}/src/LinAlg/IpVector.cpp
                           ${Ipopt_DIR}/src/LinAlg/IpZeroMatrix.cpp
                           ${Ipopt_DIR}/src/LinAlg/IpZeroSymMatrix.cpp)

set (IPOPT_SRC_LINALG_TMATRICES ${Ipopt_DIR}/src/LinAlg/TMatrices/IpGenTMatrix.cpp
                                ${Ipopt_DIR}/src/LinAlg/TMatrices/IpSymTMatrix.cpp
                                ${Ipopt_DIR}/src/LinAlg/TMatrices/IpTripletHelper.cpp)

set (IPOPT_SRC_LIST ${IPOPT_SRC_ALGORITHM_LIST}
                    ${IPOPT_SRC_ALGORITHM_LINEARSOLVERS_LIST}
                    ${IPOPT_SRC_APPS_CUTERINTERFACE_LIST}
                    ${IPOPT_SRC_APPS_AMPLSOLVER_LIST}
                    ${IPOPT_SRC_CONTRIB_CGPENALTY_LIST}
                    ${IPOPT_SRC_COMMON_LIST}
                    ${IPOPT_SRC_INTERFACES_LIST}
                    ${IPOPT_SRC_LINALG_LIST}
                    ${IPOPT_SRC_LINALG_TMATRICES})

if (IPOPT_ENABLE_INEXACT)
  set(IPOPT_SRC_LIST ${IPOPT_SRC_LIST}
                     ${IPOPT_SRC_ALGORITHM_INEXACT_LIST})
endif ()

macro(set_include_directories TARGET)
  target_include_directories(${TARGET} BEFORE PRIVATE ${CMAKE_BINARY_DIR}/Ipopt/include)
endmacro ()

include_directories(${Ipopt_DIR}/src/Algorithm)
include_directories(${Ipopt_DIR}/src/Algorithm/LinearSolvers)
include_directories(${Ipopt_DIR}/src/Algorithm/Inexact)
include_directories(${Ipopt_DIR}/src/contrib/CGPenalty)
include_directories(${Ipopt_DIR}/src/contrib/LinearSolverLoader)
include_directories(${Ipopt_DIR}/src/Interfaces)
include_directories(${Ipopt_DIR}/src/Common)
include_directories(${Ipopt_DIR}/src/LinAlg)
include_directories(${Ipopt_DIR}/src/Apps/AmplSolver)
include_directories(${Ipopt_DIR}/src/LinAlg/TMatrices)

if (WIN32)
  add_definitions(-D_CRT_SECURE_NO_WARNINGS -D_CRT_SECURE_NO_DEPRECATE)
endif ()

if (IPOPT_HAS_PARDISO)
  add_definition(-DHAVE_PARDISO=1)
  if (IPOPT_HAS_PARDISO_MKL)
    add_definition(-DHAVE_PARDISO_MKL=1)
  endif ()
  if (IPOPT_HAS_PARDISO_OLDINTERFACE)
    add_definition(-DHAVE_PARDISO_OLDINTERFACE=1)
  endif ()
  if (IPOPT_HAS_PARDISO_PARALLEL)
    add_definition(-DHAVE_PARDISO_PARALLEL=1)
  endif ()
endif ()

if (IPOPT_HAS_AMPL)
  set(IPOPT_SRC_LIST ${IPOPT_SRC_LIST}
                     ${Ipopt_DIR}/src/Apps/AmplSolver/AmplTNLP.cpp)
endif ()

if (ENABLE_SHARED_LIBRARIES)
  add_library(libipopt SHARED ${IPOPT_SRC_LIST})
else ()
  add_library(libipopt STATIC ${IPOPT_SRC_LIST})
endif ()
set_target_properties(libipopt PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON)
set_target_properties(libipopt PROPERTIES OUTPUT_NAME ${IPOPT_OUTPUT_NAME})

if (COIN_COMPILE_LTO)
  set_target_properties(libipopt PROPERTIES INTERPROCEDURAL_OPTIMIZATION true)
endif ()
if (NOT WIN32)
  set_target_properties(libipopt PROPERTIES PREFIX "")
endif ()
set_include_directories(libipopt)

if (IPOPT_HAS_MUMPS)
  target_link_libraries(libipopt dmumps mumps_common)
endif ()

if (COIN_HAS_LAPACK OR COIN_ENABLE_DOWNLOAD_LAPACK OR COIN_USE_SYSTEM_LAPACK)
  target_link_libraries(libipopt lapack blas)
endif ()

if (IPOPT_HAS_AMPL)
  set (IPOPT_AMPL_SRC_LIST ${Ipopt_DIR}/src/Apps/AmplSolver/ampl_ipopt.cpp)
  
  add_definitions(-DIPOPTAMPL_BUILD)
  
  add_executable(ipopt ${IPOPT_AMPL_SRC_LIST})
  
  target_link_libraries(ipopt libipopt)
  if (COIN_HAS_MUMPS)
    target_link_libraries(ipopt dmumps mumps_common seq pthread)
  endif ()
  if (COIN_ENABLE_COMPILE_HSL)
    if (IPOPT_ENABLE_LINEARSOLVERLOADER)
      target_link_libraries(ipopt hsl)
    else ()
      target_link_libraries(ipopt hsl-static)
    endif ()
    if (COIN_HAS_HSL_OTHER)
      target_link_libraries(ipopt hsl-other)
    endif ()
  endif ()
  if (MKL_FOUND)
    target_link_libraries(ipopt ${COIN_MKL_LIBS})
  else ()
    if (COIN_HAS_LAPACK OR COIN_ENABLE_DOWNLOAD_LAPACK OR COIN_USE_SYSTEM_LAPACK)
      target_link_libraries(ipopt lapack blas)
    endif ()
    if (COIN_ENABLE_DOWNLOAD_CLAPACK)
      target_link_libraries(ipopt f2c)
    endif ()
  endif ()
  if (COIN_ENABLE_COMPILE_HSL OR COIN_ENABLE_DOWNLOAD_LAPACK OR COIN_ENABLE_DOWNLOAD_MUMPS OR COIN_ENABLE_COMPILE_HSL OR COIN_HAS_MUMPS OR COIN_USE_SYSTEM_LAPACK)
    target_link_libraries(ipopt gfortran)
  endif ()
  if ((IPOPT_ENABLE_LINEARSOLVERLOADER OR COIN_ENABLE_DOWNLOAD_ASL OR ENABLE_SHARED_LIBRARIES) AND UNIX)
    target_link_libraries(ipopt dl)
  endif ()
  if (COIN_ENABLE_DOWNLOAD_ASL)
    target_link_libraries(ipopt amplsolver)
  endif ()
  if (COIN_ENABLE_DOWNLOAD_METIS)
    target_link_libraries(ipopt metis)
  endif ()
  if (IPOPT_HAS_WSMP)
    target_link_libraries(ipopt wsmp)
  endif ()
  if (IPOPT_HAS_PARDISO)
    target_link_libraries(ipopt wsmp)
    if (WIN32)
      if (CMAKE_SIZEOF_VOID_P EQUAL 4)
	target_link_libraries(ipopt mkl_intel_c.lib mkl_sequential.lib mkl_core.lib)
      else ()
	target_link_libraries(ipopt mkl_intel_lp64.lib mkl_sequential.lib mkl_core.lib)
      endif ()
    else ()
      set(MKL_TMP_LIB "-Wl,--start-group -lmkl_core")
      if (CMAKE_SIZEOF_VOID_P EQUAL 4)
	set(MKL_TMP_LIB "${MKL_TMP_LIB} -lmkl_intel")
      else ()
	set(MKL_TMP_LIB "${MKL_TMP_LIB} -lmkl_intel_lp64")
      endif ()
      if (IPOPT_HAS_PARDISO_PARALLEL)
	set(MKL_TMP_LIB "${MKL_TMP_LIB} -lmkl_intel_thread")
      else ()
	set(MKL_TMP_LIB "${MKL_TMP_LIB} -lmkl_sequential")
      endif ()
      set(MKL_TMP_LIB "${MKL_TMP_LIB} -Wl,--end-group")
      
      target_link_libraries(ipopt ${MKL_TMP_LIB})
    endif ()
  endif ()
  
  set_include_directories(ipopt)
  
  install(TARGETS ipopt
          DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR})
  
  include(${CMAKE_SOURCE_DIR}/ThirdParty/IpoptTests.cmake)
endif ()

if (IPOPT_BUILD_EXAMPLES)
  set(ScalableProblems_SRCS ${Ipopt_DIR}/examples/ScalableProblems/LuksanVlcek1.cpp
                            ${Ipopt_DIR}/examples/ScalableProblems/LuksanVlcek2.cpp
                            ${Ipopt_DIR}/examples/ScalableProblems/LuksanVlcek3.cpp
                            ${Ipopt_DIR}/examples/ScalableProblems/LuksanVlcek4.cpp
                            ${Ipopt_DIR}/examples/ScalableProblems/LuksanVlcek5.cpp
                            ${Ipopt_DIR}/examples/ScalableProblems/LuksanVlcek6.cpp
                            ${Ipopt_DIR}/examples/ScalableProblems/LuksanVlcek7.cpp
                            ${Ipopt_DIR}/examples/ScalableProblems/MittelmannBndryCntrlDiri3Dsin.cpp
                            ${Ipopt_DIR}/examples/ScalableProblems/MittelmannBndryCntrlDiri3D_27.cpp
                            ${Ipopt_DIR}/examples/ScalableProblems/MittelmannBndryCntrlDiri3D.cpp
                            ${Ipopt_DIR}/examples/ScalableProblems/MittelmannDistCntrlDiri.cpp
                            ${Ipopt_DIR}/examples/ScalableProblems/MittelmannBndryCntrlDiri.cpp
                            ${Ipopt_DIR}/examples/ScalableProblems/MittelmannDistCntrlNeumA.cpp
                            ${Ipopt_DIR}/examples/ScalableProblems/MittelmannDistCntrlNeumB.cpp
                            ${Ipopt_DIR}/examples/ScalableProblems/MittelmannBndryCntrlNeum.cpp
                            ${Ipopt_DIR}/examples/ScalableProblems/RegisteredTNLP.cpp
                            ${Ipopt_DIR}/examples/ScalableProblems/solve_problem.cpp)
    
  add_executable(solve_problem ${ScalableProblems_SRCS})
  target_link_libraries(solve_problem libipopt)
  if (COIN_COMPILE_LTO)
    set_target_properties(solve_problem PROPERTIES INTERPROCEDURAL_OPTIMIZATION true)
  endif ()
  if (COIN_HAS_MUMPS)
    target_link_libraries(solve_problem dmumps mumps_common seq pthread)
  endif ()
  if (COIN_ENABLE_COMPILE_HSL)
    if (IPOPT_ENABLE_LINEARSOLVERLOADER)
      target_link_libraries(solve_problem hsl)
    else ()
      target_link_libraries(solve_problem hsl-static)
    endif ()
    if (COIN_HAS_HSL_OTHER)
      target_link_libraries(solve_problem hsl-other)
    endif ()
  endif ()
  if (MKL_FOUND)
    target_link_libraries(solve_problem ${COIN_MKL_LIBS})
  else ()
    if (COIN_HAS_LAPACK OR COIN_ENABLE_DOWNLOAD_LAPACK OR COIN_USE_SYSTEM_LAPACK)
      target_link_libraries(solve_problem lapack blas)
    endif ()
    if (COIN_ENABLE_DOWNLOAD_CLAPACK)
      target_link_libraries(solve_problem f2c)
    endif ()
  endif ()
  if (COIN_LINK_GFORTRAN AND (COIN_ENABLE_COMPILE_HSL OR COIN_ENABLE_DOWNLOAD_LAPACK OR COIN_ENABLE_COMPILE_HSL OR COIN_ENABLE_DOWNLOAD_MUMPS OR COIN_HAS_MUMPS OR COIN_USE_SYSTEM_LAPACK))
    target_link_libraries(solve_problem gfortran)
  endif ()
  if ((IPOPT_ENABLE_LINEARSOLVERLOADER OR COIN_ENABLE_DOWNLOAD_ASL OR ENABLE_SHARED_LIBRARIES) AND UNIX)
    target_link_libraries(solve_problem dl)
  endif ()
  if (COIN_ENABLE_DOWNLOAD_METIS)
    target_link_libraries(solve_problem metis)
  endif ()
  include_directories(${Ipopt_DIR}/examples/ScalableProblems)
  set_include_directories(solve_problem)
  
  add_test(NAME ipopt_example_luksan_LukVlE1
           COMMAND $<TARGET_FILE:solve_problem> LukVlE1 10)
  set_tests_properties(ipopt_example_luksan_LukVlE1 PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_LukVlE1 PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_LukVlE2
           COMMAND $<TARGET_FILE:solve_problem> LukVlE2 14)
  set_tests_properties(ipopt_example_luksan_LukVlE2 PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_LukVlE2 PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_LukVlE3
           COMMAND $<TARGET_FILE:solve_problem> LukVlE3 10)
  set_tests_properties(ipopt_example_luksan_LukVlE3 PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_LukVlE3 PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_LukVlE4
           COMMAND $<TARGET_FILE:solve_problem> LukVlE4 10)
  set_tests_properties(ipopt_example_luksan_LukVlE4 PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_LukVlE4 PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_LukVlE5
           COMMAND $<TARGET_FILE:solve_problem> LukVlE5 10)
  set_tests_properties(ipopt_example_luksan_LukVlE5 PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_LukVlE5 PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_LukVlE6
           COMMAND $<TARGET_FILE:solve_problem> LukVlE6 10)
  set_tests_properties(ipopt_example_luksan_LukVlE6 PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_LukVlE6 PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_LukVlE7
           COMMAND $<TARGET_FILE:solve_problem> LukVlE7 4)
  set_tests_properties(ipopt_example_luksan_LukVlE7 PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_LukVlE7 PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_LukVlI1
           COMMAND $<TARGET_FILE:solve_problem> LukVlI1 10)
  set_tests_properties(ipopt_example_luksan_LukVlI1 PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_LukVlI1 PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_LukVlI2
           COMMAND $<TARGET_FILE:solve_problem> LukVlI2 14)
  set_tests_properties(ipopt_example_luksan_LukVlI2 PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_LukVlI2 PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_LukVlI3
           COMMAND $<TARGET_FILE:solve_problem> LukVlI3 10)
  set_tests_properties(ipopt_example_luksan_LukVlI3 PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_LukVlI3 PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_LukVlI4
           COMMAND $<TARGET_FILE:solve_problem> LukVlI4 10)
  set_tests_properties(ipopt_example_luksan_LukVlI4 PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_LukVlI4 PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_LukVlI5
           COMMAND $<TARGET_FILE:solve_problem> LukVlI5 10)
  set_tests_properties(ipopt_example_luksan_LukVlI5 PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_LukVlI5 PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_LukVlI6
           COMMAND $<TARGET_FILE:solve_problem> LukVlI6 10)
  set_tests_properties(ipopt_example_luksan_LukVlI6 PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_LukVlI6 PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_LukVlI7
           COMMAND $<TARGET_FILE:solve_problem> LukVlI7 4)
  set_tests_properties(ipopt_example_luksan_LukVlI7 PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_LukVlI7 PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_MBndryCntrl1
           COMMAND $<TARGET_FILE:solve_problem> MBndryCntrl1 10)
  set_tests_properties(ipopt_example_luksan_MBndryCntrl1 PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_MBndryCntrl1 PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_MBndryCntrl2
           COMMAND $<TARGET_FILE:solve_problem> MBndryCntrl2 14)
  set_tests_properties(ipopt_example_luksan_MBndryCntrl2 PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_MBndryCntrl2 PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_MBndryCntrl3
           COMMAND $<TARGET_FILE:solve_problem> MBndryCntrl3 10)
  set_tests_properties(ipopt_example_luksan_MBndryCntrl3 PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_MBndryCntrl3 PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_MBndryCntrl4
           COMMAND $<TARGET_FILE:solve_problem> MBndryCntrl4 10)
  set_tests_properties(ipopt_example_luksan_MBndryCntrl4 PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_MBndryCntrl4 PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_MBndryCntrl5
           COMMAND $<TARGET_FILE:solve_problem> MBndryCntrl5 10)
  set_tests_properties(ipopt_example_luksan_MBndryCntrl5 PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_MBndryCntrl5 PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_MBndryCntrl6
           COMMAND $<TARGET_FILE:solve_problem> MBndryCntrl6 10)
  set_tests_properties(ipopt_example_luksan_MBndryCntrl6 PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_MBndryCntrl6 PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_MBndryCntrl7
           COMMAND $<TARGET_FILE:solve_problem> MBndryCntrl7 10)
  set_tests_properties(ipopt_example_luksan_MBndryCntrl7 PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_MBndryCntrl7 PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_MBndryCntrl8
           COMMAND $<TARGET_FILE:solve_problem> MBndryCntrl8 10)
  set_tests_properties(ipopt_example_luksan_MBndryCntrl8 PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_MBndryCntrl8 PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_MBndryCntrl_3D
           COMMAND $<TARGET_FILE:solve_problem> MBndryCntrl_3D 10)
  set_tests_properties(ipopt_example_luksan_MBndryCntrl_3D PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_MBndryCntrl_3D PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_MBndryCntrl_3D_27
           COMMAND $<TARGET_FILE:solve_problem> MBndryCntrl_3D_27 10)
  set_tests_properties(ipopt_example_luksan_MBndryCntrl_3D_27 PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_MBndryCntrl_3D_27 PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_MBndryCntrl_3D_27BT
           COMMAND $<TARGET_FILE:solve_problem> MBndryCntrl_3D_27BT 10)
  set_tests_properties(ipopt_example_luksan_MBndryCntrl_3D_27BT PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_MBndryCntrl_3D_27BT PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_MBndryCntrl_3Dsin
           COMMAND $<TARGET_FILE:solve_problem> MBndryCntrl_3Dsin 10)
  set_tests_properties(ipopt_example_luksan_MBndryCntrl_3Dsin PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_MBndryCntrl_3Dsin PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_MDistCntrl1
           COMMAND $<TARGET_FILE:solve_problem> MDistCntrl1 10)
  set_tests_properties(ipopt_example_luksan_MDistCntrl1 PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_MDistCntrl1 PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_MDistCntrl2
           COMMAND $<TARGET_FILE:solve_problem> MDistCntrl2 10)
  set_tests_properties(ipopt_example_luksan_MDistCntrl2 PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_MDistCntrl2 PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_MDistCntrl3
           COMMAND $<TARGET_FILE:solve_problem> MDistCntrl3 10)
  set_tests_properties(ipopt_example_luksan_MDistCntrl3 PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_MDistCntrl3 PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_MDistCntrl3a
           COMMAND $<TARGET_FILE:solve_problem> MDistCntrl3a 10)
  set_tests_properties(ipopt_example_luksan_MDistCntrl3a PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_MDistCntrl3a PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_MDistCntrl4
           COMMAND $<TARGET_FILE:solve_problem> MDistCntrl4 10)
  set_tests_properties(ipopt_example_luksan_MDistCntrl4 PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_MDistCntrl4 PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_MDistCntrl4a
           COMMAND $<TARGET_FILE:solve_problem> MDistCntrl4a 10)
  set_tests_properties(ipopt_example_luksan_MDistCntrl4a PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_MDistCntrl4a PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_MDistCntrl5
           COMMAND $<TARGET_FILE:solve_problem> MDistCntrl5 10)
  set_tests_properties(ipopt_example_luksan_MDistCntrl5 PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_MDistCntrl5 PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_MDistCntrl5a
           COMMAND $<TARGET_FILE:solve_problem> MDistCntrl5a 10)
  set_tests_properties(ipopt_example_luksan_MDistCntrl5a PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_MDistCntrl5a PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_MDistCntrl6
           COMMAND $<TARGET_FILE:solve_problem> MDistCntrl6 10)
  set_tests_properties(ipopt_example_luksan_MDistCntrl6 PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_MDistCntrl6 PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_MDistCntrl6a
           COMMAND $<TARGET_FILE:solve_problem> MDistCntrl6a 10)
  set_tests_properties(ipopt_example_luksan_MDistCntrl6a PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_MDistCntrl6a PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_MPara5_1
           COMMAND $<TARGET_FILE:solve_problem> MPara5_1 10)
  set_tests_properties(ipopt_example_luksan_MPara5_1 PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_MPara5_1 PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_MPara5_2_1
           COMMAND $<TARGET_FILE:solve_problem> MPara5_2_1 10)
  set_tests_properties(ipopt_example_luksan_MPara5_2_1 PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_MPara5_2_1 PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_MPara5_2_2
           COMMAND $<TARGET_FILE:solve_problem> MPara5_2_2 10)
  set_tests_properties(ipopt_example_luksan_MPara5_2_2 PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_MPara5_2_2 PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  add_test(NAME ipopt_example_luksan_MPara5_2_3
           COMMAND $<TARGET_FILE:solve_problem> MPara5_2_3 10)
  set_tests_properties(ipopt_example_luksan_MPara5_2_3 PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_luksan_MPara5_2_3 PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")

  set(Cpp_example_SRCS ${Ipopt_DIR}/examples/Cpp_example/cpp_example.cpp
                       ${Ipopt_DIR}/examples/Cpp_example/MyNLP.cpp)
  
  add_executable(cpp_example ${Cpp_example_SRCS})
  target_link_libraries(cpp_example libipopt)
  if (COIN_COMPILE_LTO)
    set_target_properties(cpp_example PROPERTIES INTERPROCEDURAL_OPTIMIZATION true)
  endif ()
  if (COIN_HAS_MUMPS)
    target_link_libraries(cpp_example dmumps mumps_common seq pthread)
  endif ()
  if (COIN_ENABLE_COMPILE_HSL)
    if (IPOPT_ENABLE_LINEARSOLVERLOADER)
      target_link_libraries(cpp_example hsl)
    else ()
      target_link_libraries(cpp_example hsl-static)
    endif ()
    if (COIN_HAS_HSL_OTHER)
      target_link_libraries(cpp_example hsl-other)
    endif ()
  endif ()
  if (MKL_FOUND)
    target_link_libraries(cpp_example ${COIN_MKL_LIBS})
  else ()
    if (COIN_HAS_LAPACK OR COIN_ENABLE_DOWNLOAD_LAPACK OR COIN_USE_SYSTEM_LAPACK)
      target_link_libraries(cpp_example lapack blas)
    endif ()
    if (COIN_ENABLE_DOWNLOAD_CLAPACK)
      target_link_libraries(cpp_example f2c)
    endif ()
  endif ()
  if (COIN_LINK_GFORTRAN AND (COIN_ENABLE_COMPILE_HSL OR COIN_ENABLE_DOWNLOAD_LAPACK OR COIN_ENABLE_COMPILE_HSL OR COIN_ENABLE_DOWNLOAD_MUMPS OR COIN_HAS_MUMPS OR COIN_USE_SYSTEM_LAPACK))
    target_link_libraries(cpp_example gfortran)
  endif ()
  if ((IPOPT_ENABLE_LINEARSOLVERLOADER OR COIN_ENABLE_DOWNLOAD_ASL OR ENABLE_SHARED_LIBRARIES) AND UNIX)
    target_link_libraries(cpp_example dl)
  endif ()
  if (COIN_ENABLE_DOWNLOAD_METIS)
    target_link_libraries(cpp_example metis)
  endif ()
  if (UNIX)
    target_link_libraries(cpp_example m)
  endif ()
  set_include_directories(cpp_example)
  
  add_test(NAME ipopt_example_cpp_example
           COMMAND $<TARGET_FILE:cpp_example>)
  set_tests_properties(ipopt_example_cpp_example PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_cpp_example PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")


  set(hs071_c_SRCS ${Ipopt_DIR}/examples/hs071_c/hs071_c.c)
  
  add_executable(hs071_c ${hs071_c_SRCS})
  target_link_libraries(hs071_c libipopt)
  if (COIN_COMPILE_LTO)
    set_target_properties(hs071_c PROPERTIES INTERPROCEDURAL_OPTIMIZATION true)
  endif ()
  if (COIN_HAS_MUMPS)
    target_link_libraries(hs071_c dmumps mumps_common seq pthread)
  endif ()
  if (COIN_ENABLE_COMPILE_HSL)
    if (IPOPT_ENABLE_LINEARSOLVERLOADER)
      target_link_libraries(hs071_c hsl)
    else ()
      target_link_libraries(hs071_c hsl-static)
    endif ()
    if (COIN_HAS_HSL_OTHER)
      target_link_libraries(hs071_c hsl-other)
    endif ()
  endif ()
  if (MKL_FOUND)
    target_link_libraries(hs071_c ${COIN_MKL_LIBS})
  else ()
    if (COIN_HAS_LAPACK OR COIN_ENABLE_DOWNLOAD_LAPACK OR COIN_USE_SYSTEM_LAPACK)
      target_link_libraries(hs071_c lapack blas)
    endif ()
    if (COIN_ENABLE_DOWNLOAD_CLAPACK)
      target_link_libraries(hs071_c f2c)
    endif ()
  endif ()
  if (COIN_LINK_GFORTRAN AND (COIN_ENABLE_COMPILE_HSL OR COIN_ENABLE_DOWNLOAD_LAPACK OR COIN_ENABLE_COMPILE_HSL OR COIN_ENABLE_DOWNLOAD_MUMPS OR COIN_HAS_MUMPS OR COIN_USE_SYSTEM_LAPACK))
    target_link_libraries(hs071_c gfortran)
  endif ()
  if ((IPOPT_ENABLE_LINEARSOLVERLOADER OR COIN_ENABLE_DOWNLOAD_ASL OR ENABLE_SHARED_LIBRARIES) AND UNIX)
    target_link_libraries(hs071_c dl)
  endif ()
  if (COIN_ENABLE_DOWNLOAD_METIS)
    target_link_libraries(hs071_c metis)
  endif ()
  if (UNIX)
    target_link_libraries(hs071_c m)
  endif ()
  set_include_directories(hs071_c)

  add_test(NAME ipopt_example_hs071_c
           COMMAND $<TARGET_FILE:hs071_c>)
  set_tests_properties(ipopt_example_hs071_c PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_hs071_c PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")
  
  
  set(hs071_cpp_SRCS ${Ipopt_DIR}/examples/hs071_cpp/hs071_main.cpp
                     ${Ipopt_DIR}/examples/hs071_cpp/hs071_nlp.cpp)
  
  add_executable(hs071_cpp ${hs071_cpp_SRCS})
  target_link_libraries(hs071_cpp libipopt)
  if (COIN_COMPILE_LTO)
    set_target_properties(hs071_cpp PROPERTIES INTERPROCEDURAL_OPTIMIZATION true)
  endif ()
  if (COIN_HAS_MUMPS)
    target_link_libraries(hs071_cpp dmumps mumps_common seq gfortran pthread)
  endif ()
  if (COIN_ENABLE_COMPILE_HSL)
    if (IPOPT_ENABLE_LINEARSOLVERLOADER)
      target_link_libraries(hs071_cpp hsl)
    else ()
      target_link_libraries(hs071_cpp hsl-static)
    endif ()
    if (COIN_HAS_HSL_OTHER)
      target_link_libraries(hs071_cpp hsl-other)
    endif ()
  endif ()
  if (MKL_FOUND)
    target_link_libraries(hs071_cpp ${COIN_MKL_LIBS})
  else ()
    if (COIN_HAS_LAPACK OR COIN_ENABLE_DOWNLOAD_LAPACK OR COIN_USE_SYSTEM_LAPACK)
      target_link_libraries(hs071_cpp lapack blas)
    endif ()
    if (COIN_ENABLE_DOWNLOAD_CLAPACK)
      target_link_libraries(hs071_cpp f2c)
    endif ()
  endif ()
  if (COIN_LINK_GFORTRAN AND (COIN_ENABLE_COMPILE_HSL OR COIN_ENABLE_DOWNLOAD_LAPACK OR COIN_ENABLE_COMPILE_HSL OR COIN_ENABLE_DOWNLOAD_MUMPS OR COIN_HAS_MUMPS OR COIN_USE_SYSTEM_LAPACK))
    target_link_libraries(hs071_cpp gfortran)
  endif ()
  if ((IPOPT_ENABLE_LINEARSOLVERLOADER OR COIN_ENABLE_DOWNLOAD_ASL OR ENABLE_SHARED_LIBRARIES) AND UNIX)
    target_link_libraries(hs071_cpp dl)
  endif ()
  if (COIN_ENABLE_DOWNLOAD_METIS)
    target_link_libraries(hs071_cpp metis)
  endif ()
  if (UNIX)
    target_link_libraries(hs071_cpp m)
  endif ()
  set_include_directories(hs071_cpp)
  
  add_test(NAME ipopt_example_hs071_cpp
           COMMAND $<TARGET_FILE:hs071_cpp>)
  set_tests_properties(ipopt_example_hs071_cpp PROPERTIES TIMEOUT 30)
  set_tests_properties(ipopt_example_hs071_cpp PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")
  

  if (NOT "${CMAKE_Fortran_COMPILER}" STREQUAL "")
    if (HAVE_64_BIT)
      set(BIT32FCOMMENT "C")
      set(BIT64FCOMMENT "")
    else ()
      set(BIT32FCOMMENT "")
      set(BIT64FCOMMENT "C")
    endif ()
    
    configure_file(${Ipopt_DIR}/examples/hs071_f/hs071_f.f.in ${CMAKE_BINARY_DIR}/hs071_f.f)
    set(hs071_f_SRCS ${CMAKE_BINARY_DIR}/hs071_f.f)
    
    add_executable(hs071_f ${hs071_f_SRCS})
    target_link_libraries(hs071_f libipopt)
    if (COIN_COMPILE_LTO)
      set_target_properties(hs071_f PROPERTIES INTERPROCEDURAL_OPTIMIZATION true)
    endif ()
    if (COIN_HAS_MUMPS)
      target_link_libraries(hs071_f dmumps mumps_common seq pthread)
    endif ()
    if (COIN_ENABLE_COMPILE_HSL)
      if (IPOPT_ENABLE_LINEARSOLVERLOADER)
	target_link_libraries(hs071_f hsl)
      else ()
	target_link_libraries(hs071_f hsl-static)
      endif ()
      if (COIN_HAS_HSL_OTHER)
	target_link_libraries(hs071_f hsl-other)
      endif ()
    endif ()
    if (MKL_FOUND)
      target_link_libraries(hs071_f ${COIN_MKL_LIBS})
    else ()
      if (COIN_HAS_LAPACK OR COIN_ENABLE_DOWNLOAD_LAPACK OR COIN_USE_SYSTEM_LAPACK)
        target_link_libraries(hs071_f lapack blas)
      endif ()
      if (COIN_ENABLE_DOWNLOAD_CLAPACK)
        target_link_libraries(hs071_f f2c)
      endif ()
    endif ()
    if (COIN_LINK_GFORTRAN AND (COIN_ENABLE_COMPILE_HSL OR COIN_ENABLE_DOWNLOAD_LAPACK OR COIN_ENABLE_COMPILE_HSL OR COIN_ENABLE_DOWNLOAD_MUMPS OR COIN_HAS_MUMPS OR COIN_USE_SYSTEM_LAPACK))
      target_link_libraries(hs071_f gfortran)
    endif ()
    if ((IPOPT_ENABLE_LINEARSOLVERLOADER OR COIN_ENABLE_DOWNLOAD_ASL OR ENABLE_SHARED_LIBRARIES) AND UNIX)
      target_link_libraries(hs071_f dl)
    endif ()
    if (COIN_ENABLE_DOWNLOAD_METIS)
      target_link_libraries(hs071_f metis)
    endif ()
    if (UNIX)
      target_link_libraries(hs071_f m)
    endif ()
    set_include_directories(hs071_f)
    add_test(NAME ipopt_example_hs071_f
            COMMAND $<TARGET_FILE:hs071_f>)
    set_tests_properties(ipopt_example_hs071_f PROPERTIES TIMEOUT 30)
    set_tests_properties(ipopt_example_hs071_f PROPERTIES PASS_REGULAR_EXPRESSION "EXIT: Optimal Solution Found.")
  endif ()
endif ()

#
# Install part
#

set(LINALG_HDRS ${Ipopt_DIR}/src/LinAlg/IpMatrix.hpp
                ${Ipopt_DIR}/src/LinAlg/IpSymMatrix.hpp
		${Ipopt_DIR}/src/LinAlg/IpExpansionMatrix.hpp
		${Ipopt_DIR}/src/LinAlg/IpVector.hpp
		${Ipopt_DIR}/src/LinAlg/IpDenseVector.hpp
		${Ipopt_DIR}/src/LinAlg/IpCompoundVector.hpp
		${Ipopt_DIR}/src/LinAlg/IpCompoundMatrix.hpp
		${Ipopt_DIR}/src/LinAlg/IpCompoundSymMatrix.hpp
		${Ipopt_DIR}/src/LinAlg/IpSumSymMatrix.hpp
		${Ipopt_DIR}/src/LinAlg/IpDiagMatrix.hpp
		${Ipopt_DIR}/src/LinAlg/IpIdentityMatrix.hpp
		${Ipopt_DIR}/src/LinAlg/IpScaledMatrix.hpp
		${Ipopt_DIR}/src/LinAlg/IpSymScaledMatrix.hpp
		${Ipopt_DIR}/src/LinAlg/IpZeroSymMatrix.hpp
		${Ipopt_DIR}/src/LinAlg/IpBlas.hpp
		${Ipopt_DIR}/src/LinAlg/IpLapack.hpp)

set(TMATRICES_HDRS ${Ipopt_DIR}/src/LinAlg/TMatrices/IpGenTMatrix.hpp
	           ${Ipopt_DIR}/src/LinAlg/TMatrices/IpSymTMatrix.hpp
	           ${Ipopt_DIR}/src/LinAlg/TMatrices/IpTripletHelper.hpp)

set(INTERFACES_HDRS ${Ipopt_DIR}/src/Interfaces/IpAlgTypes.hpp
	            ${Ipopt_DIR}/src/Interfaces/IpIpoptApplication.hpp
		    ${Ipopt_DIR}/src/Interfaces/IpNLP.hpp
		    ${Ipopt_DIR}/src/Interfaces/IpReturnCodes.h
		    ${Ipopt_DIR}/src/Interfaces/IpReturnCodes.hpp
		    ${Ipopt_DIR}/src/Interfaces/IpReturnCodes_inc.h
		    ${Ipopt_DIR}/src/Interfaces/IpReturnCodes.inc
		    ${Ipopt_DIR}/src/Interfaces/IpSolveStatistics.hpp
		    ${Ipopt_DIR}/src/Interfaces/IpStdCInterface.h
		    ${Ipopt_DIR}/src/Interfaces/IpTNLP.hpp
		    ${Ipopt_DIR}/src/Interfaces/IpTNLPAdapter.hpp
		    ${Ipopt_DIR}/src/Interfaces/IpTNLPReducer.hpp)

set(COMMON_HDRS ${Ipopt_DIR}/src/Common/IpCachedResults.hpp
	        ${Ipopt_DIR}/src/Common/IpDebug.hpp
		${Ipopt_DIR}/src/Common/IpException.hpp
		${Ipopt_DIR}/src/Common/IpJournalist.hpp
		${Ipopt_DIR}/src/Common/IpLibraryLoader.hpp
		${Ipopt_DIR}/src/Common/IpObserver.hpp
		${Ipopt_DIR}/src/Common/IpOptionsList.hpp
		${Ipopt_DIR}/src/Common/IpReferenced.hpp
		${Ipopt_DIR}/src/Common/IpRegOptions.hpp
		${Ipopt_DIR}/src/Common/IpSmartPtr.hpp
		${Ipopt_DIR}/src/Common/IpTaggedObject.hpp
		${Ipopt_DIR}/src/Common/IpTimedTask.hpp
		${Ipopt_DIR}/src/Common/IpTypes.h
		${Ipopt_DIR}/src/Common/IpTypes.hpp
		${Ipopt_DIR}/src/Common/IpUtils.hpp)

set(ALGORITHMS_HDRS ${Ipopt_DIR}/src/Algorithm/IpIpoptCalculatedQuantities.hpp
                    ${Ipopt_DIR}/src/Algorithm/IpIpoptData.hpp
		    ${Ipopt_DIR}/src/Algorithm/IpIteratesVector.hpp
		    ${Ipopt_DIR}/src/Algorithm/IpTimingStatistics.hpp
		    ${Ipopt_DIR}/src/Algorithm/IpIpoptNLP.hpp
		    ${Ipopt_DIR}/src/Algorithm/IpOrigIpoptNLP.hpp
		    ${Ipopt_DIR}/src/Algorithm/IpNLPScaling.hpp
		    ${Ipopt_DIR}/src/Algorithm/IpAlgBuilder.hpp
		    ${Ipopt_DIR}/src/Algorithm/IpIpoptAlg.hpp
		    ${Ipopt_DIR}/src/Algorithm/IpAlgStrategy.hpp
		    ${Ipopt_DIR}/src/Algorithm/IpSearchDirCalculator.hpp
		    ${Ipopt_DIR}/src/Algorithm/IpLineSearch.hpp
		    ${Ipopt_DIR}/src/Algorithm/IpMuUpdate.hpp
		    ${Ipopt_DIR}/src/Algorithm/IpConvCheck.hpp
		    ${Ipopt_DIR}/src/Algorithm/IpIterateInitializer.hpp
		    ${Ipopt_DIR}/src/Algorithm/IpIterationOutput.hpp
		    ${Ipopt_DIR}/src/Algorithm/IpHessianUpdater.hpp
		    ${Ipopt_DIR}/src/Algorithm/IpEqMultCalculator.hpp
		    ${Ipopt_DIR}/src/Algorithm/IpAugSystemSolver.hpp
		    ${Ipopt_DIR}/src/Algorithm/IpPDSystemSolver.hpp)

set(LINEARSOLVERS_HDRS ${Ipopt_DIR}/src/Algorithm/LinearSolvers/IpSymLinearSolver.hpp)

set(ALL_HDRS ${LINALG_HDRS}
             ${TMATRICES_HDRS}
	     ${INTERFACES_HDRS}
	     ${COMMON_HDRS}
	     ${ALGORITHMS_HDRS}
	     ${LINEARSOLVERS_HDRS}
             ${CMAKE_BINARY_DIR}/Ipopt/include/install/IpoptConfig.h)

install(FILES ${ALL_HDRS} 
        DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR}/coin-or)

install(TARGETS libipopt
        RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR})

