/*! \mainpage ColPack
 *
 * <CENTER><H2>Assefaw H. Gebremedhin, Duc Nguyen, Arijit Tarafdar, Md. Mostofa Ali Patwary, Alex Pothen</H2></CENTER>
 *
 * \section INTRODUCTION
 *
 * ColPack is a package comprising of implementation of algorithms for specialized vertex coloring problems
 * that arise in sparse derivative computation. It is written in an object-oriented fashion heavily using
 * the Standard Template Library (STL). It is designed to be simple, modular, extenable and efficient.
 *
 * \section SAMPLE_CODES SAMPLE CODES
 *
 * Sample codes (with comments) that quickly illustrate how ColPack interface functions are used
 * are available in the directory SampleDriver.<BR>
 * Click on <a href="files.html">"Files"</a> tab and then pick the files you want to look at and click on the [code] link.<BR>
 * <BR>
 * To compile all sample drivers on UNIX: make test<BR>
 * To run all sample drivers on UNIX: make run-test<BR>
 * Notes:<BR>
 * - The make command could also be run with parameters: "make EXECUTABLE=(desired name. Optional, default name is ColPack) INSTALL_DIR=(directory where the compiled program will be placed. Optional, default dir is ./)".
 * - On multi-processors computer, add flag "-j" for faster result.
 *
 * \section DOWNLOAD
 *
 * <a href="http://www.cscapes.org/download/ColPack/"> ColPack</a><BR>
 * <a href="http://www.cscapes.org/download/MM_Collection.zip"> Graph Collection in Matrix Market format</a><BR>
 * <a href="http://www.cscapes.org/download/MeTiS_Collection.zip"> Graph Collection in MeTis format</a><BR>
 * To decompress .zip files on UNIX, run "unzip (targeted .zip file)"<BR>
 *
 * \section CONTACT
 *
 * Email Assefaw Gebremedhin at agebreme [at] purdue [dot] edu or Duc Nguyen at nguyend [at] purdue [dot] edu .
 *
 */

/** @defgroup group1 Classes for Graphs
 Based on functionalities, the general graph coloring part of ColPack is divided into five classes -
GraphCore, GraphInputOutput, GraphOrdering, GraphColoring and GraphColoringInterface. In the
methods described below if no return type is specifed, it would be an int by default. Most ColPack
methods return TRUE on success, which has an integer value of 1.
 */

/**
 *  @defgroup group2 Classes for Bipartite Graphs
 */

/** @defgroup group21 Classes for Bipartite Graphs Partial Coloring
 *  @ingroup group2
 */

/** @defgroup group22 Classes for Bipartite Graphs BiColoring
 *  @ingroup group2
 */

/** @defgroup group5 Recovery Classes
 */

/** @defgroup group4 Auxiliary Classes
 */

